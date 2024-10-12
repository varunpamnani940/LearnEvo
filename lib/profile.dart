import 'dart:convert';
import 'package:dreamclass/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

List data = [];
bool _is2FAEnabled = false; // Default value to prevent LateInitializationError

class _ProfilePageState extends State<ProfilePage> {
  Future<void> getdata() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String uri = "http://$ipAddress/flutter/profile_get_data.php";
    var res = await http.post(Uri.parse(uri), body: {
      "email": sp.getString("teacher"),
    });
    setState(() {
      data = jsonDecode(res.body);
      print(data);
      // Initialize _is2FAEnabled based on API response
      _is2FAEnabled = data.isNotEmpty && data[0]["auth"] == "1";
    });
  }

  @override
  void initState() {
    super.initState();
    getdata(); // Fetch data on initialization
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_circle_down),
            onPressed: getdata,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            SizedBox(height: 20),
            Text(
              "Personal Information",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildEditPersonalInfoButton(),
            SizedBox(height: 20),
            Text(
              "Security Settings",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _build2FAToggle(),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text("Change Password"),
              onTap: (){
                otp();
                _showChangePasswordDialog();
              },
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<Map<String, dynamic>>  otp() async {
    String uri = "http://$ipAddress/flutter/passwordreset.php";
    final SharedPreferences sp = await SharedPreferences.getInstance();
    var res = await http.post(Uri.parse(uri), body: {
      "email": sp.getString("teacher")
    });
    otp_ = jsonDecode(res.body);
    Otp = otp_["otp"];
    print(Otp);
    return jsonDecode(res.body); // Return the response for verification
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          // Add your profile image path
        ),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.isNotEmpty ? data[0]["name"] : '',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              data.isNotEmpty ? data[0]["email"] : '',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditPersonalInfoButton() {
    return ListTile(
      leading: Icon(Icons.edit),
      title: Text('Edit Personal Information'),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditPersonalInfoPage()),
        );
      },
    );
  }

  Widget _build2FAToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Enable Dual-Factor Authentication",
          style: TextStyle(fontSize: 18),
        ),
        Switch(
          value: _is2FAEnabled,
          onChanged: (bool value) {
            setState(() {
              _is2FAEnabled = value;
            });
            _updateAuth(value);
          },
        ),
      ],
    );
  }

  Future<void> _updateAuth(bool enable) async {
    String uri = "http://$ipAddress/flutter/update_auth.php";
    final SharedPreferences sp = await SharedPreferences.getInstance();
    var res = await http.post(Uri.parse(uri), body: {
      "email": sp.getString("teacher"),
      "status": enable ? "1" : "0",
    });
    print(res.body);
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication settings updated!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update settings.')),
      );
    }
  }
  late var otp_ ;
  late var Otp ;
  void _showChangePasswordDialog() {

    Future<void> pass(String  pwd,String email) async {
      String uri="http://$ipAddress/flutter/Update_password.php";
      var res= await http.post(Uri.parse(uri),
          body: {
            "password": pwd,
            "email":email
          }
      );
      print(jsonDecode(res.body));
      var response = jsonDecode(res.body);
    }
    TextEditingController otpController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: otpController,
                decoration: InputDecoration(labelText: 'Enter OTP'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _changePassword(otpController.text, newPasswordController.text,
                    confirmPasswordController.text);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _saveSettings() {
    // Save the current state of 2FA
    _updateAuth(_is2FAEnabled);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  void _changePassword(String otp, String newPassword, String confirmPassword) {
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the OTP.')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    // Call your API to change the password here

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password changed successfully!')),
    );
    Navigator.of(context).pop();
  }
}

class EditPersonalInfoPage extends StatefulWidget {
  @override
  _EditPersonalInfoPageState createState() => _EditPersonalInfoPageState();
}

class _EditPersonalInfoPageState extends State<EditPersonalInfoPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> update() async {
    String uri = "http://$ipAddress/flutter/profile_update.php";
    final SharedPreferences sp = await SharedPreferences.getInstance();
    var res = await http.post(Uri.parse(uri), body: {
      "oldemail": sp.getString("teacher"),
      "newname": _nameController.text,
      "newemail": _emailController.text
    });
    print(res.body);
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = data.isNotEmpty ? data[0]["name"] : '';
    _emailController.text = data.isNotEmpty ? data[0]["email"] : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Personal Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                update();
                _savePersonalInfo();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _savePersonalInfo() async {
    // Logic to save these details to your backend
    await getdata();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Personal information updated!')),
    );
  }

  Future<void> getdata() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String uri = "http://$ipAddress/flutter/profile_get_data.php";
    var res = await http.post(Uri.parse(uri), body: {
      "email": sp.getString("teacher"),
    });

    setState(() {
      data = jsonDecode(res.body);
      print(data);
      Navigator.of(context).pop();
    });
  }
}
