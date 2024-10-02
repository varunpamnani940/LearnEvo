import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _is2FAEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings or additional actions
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(),

            SizedBox(height: 20),

            // Edit Personal Information Button
            Text(
              "Personal Information",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildEditPersonalInfoButton(),

            SizedBox(height: 20),

            // Dual-Factor Authentication Settings
            Text(
              "Security Settings",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            _build2FAToggle(),

            // Change Password Setting
            ListTile(
              leading: Icon(Icons.lock),
              title: Text("Change Password"),
              onTap: () {
                _showChangePasswordDialog();
              },
            ),

            Spacer(),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _saveSettings();
                },
                child: Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Profile header with picture and name
  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage('assets/profile_pic.png'), // Add your profile image path
        ),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "John Doe", // Can be dynamic if needed
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "johndoe@example.com", // Can be dynamic if needed
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  // Button for editing personal information
  Widget _buildEditPersonalInfoButton() {
    return ListTile(
      leading: Icon(Icons.edit),
      title: Text('Edit Personal Information'),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        // Navigate to the Edit Personal Information screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditPersonalInfoPage()),
        );
      },
    );
  }

  // Dual-Factor Authentication Toggle
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
          },
        ),
      ],
    );
  }

  // Function to show the Change Password dialog
  void _showChangePasswordDialog() {
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

  // Save settings (including 2FA)
  void _saveSettings() {
    // Logic for saving settings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  // Function to handle password change
  void _changePassword(
      String otp, String newPassword, String confirmPassword) {
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

  @override
  void initState() {
    super.initState();
    // Pre-populate fields with existing data (replace with actual data from the backend)
    _nameController.text = "John Doe";
    _emailController.text = "johndoe@example.com";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
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
                _savePersonalInfo();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _savePersonalInfo() {
    String name = _nameController.text;
    String email = _emailController.text;

    // Add logic to save these details to your backend

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Personal information updated!')),
    );
    Navigator.of(context).pop();
  }
}
