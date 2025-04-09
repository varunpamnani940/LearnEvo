import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../login.dart';

class StudentProfilePage extends StatefulWidget {
  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  Map<String, dynamic>? studentData;
  bool isLoading = true;
  // Replace with your actual IP

  @override
  void initState() {
    super.initState();
    _fetchStudentProfile();
  }

  Future<void> _fetchStudentProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? studentId = prefs.getString("studentid")?.trim();

    final uri = Uri.parse("http://$ipAddress/flutter/get_student_id.php");
    final res = await http.post(uri, body: {"studentid": studentId});

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json["success"]) {
        setState(() {
          studentData = json["student"];
          isLoading = false;
        });
      } else {
        _showError("Student not found");
      }
    } else {
      _showError("Error fetching profile");
    }
  }

  void _showError(String msg) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: studentData!["studentname"]);
    final emailCtrl = TextEditingController(text: studentData!["email"]);
    final phoneCtrl = TextEditingController(text: studentData!["phonenumber"]);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Edit Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: "Phone")),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text("Save"),
                  onPressed: () async {
                    final res = await http.post(
                      Uri.parse("http://$ipAddress/flutter/edit_student.php"),
                      body: {
                        "studentid": studentData!["studentid"].toString(),
                        "studentname": nameCtrl.text,
                        "email": emailCtrl.text,
                        "phonenumber": phoneCtrl.text,
                      },
                    );
                    Navigator.pop(context);
                    final data = jsonDecode(res.body);
                    if (data["success"]) {
                      _fetchStudentProfile();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Update failed")));
                    }
                  },
                )
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }


  void _showChangePasswordDialog() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Change Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
                controller: oldPassCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: "Old Password")),
            TextField(
                controller: newPassCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: "New Password")),
            TextField(
                controller: confirmPassCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: "Confirm Password")),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text("Update"),
                  onPressed: () async {
                    if (newPassCtrl.text != confirmPassCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Passwords do not match")));
                      return;
                    }

                    final res = await http.post(
                      Uri.parse("http://$ipAddress/flutter/edit_pass_s.php"),
                      body: {
                        "studentid": studentData!["studentid"].toString(),
                        "old_password": oldPassCtrl.text,
                        "new_password": newPassCtrl.text,
                      },
                    );
                    print(res.body);
                    Navigator.pop(context);
                    final data = jsonDecode(res.body);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(data["message"] ?? "Error")),
                    );
                  },
                )
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Student Profile"),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _fetchStudentProfile),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : studentData == null
          ? Center(child: Text("No data found"))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileCard(),
            SizedBox(height: 20),
            _buildInfoCard(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.edit),
                  label: Text("Edit"),
                  onPressed: _showEditProfileDialog,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                OutlinedButton.icon(
                  icon: Icon(Icons.lock),
                  label: Text("Change Password"),
                  onPressed: _showChangePasswordDialog,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    String imageUrl = "http://$ipAddress/flutter/studentimage/${studentData!["studimage"]}";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: ClipOval(
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/images/loading_2.gif',
                  image: imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (_, __, ___) => Icon(Icons.person, size: 40),
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(studentData!["studentname"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(studentData!["email"], style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Personal Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(thickness: 1),
            _buildInfoTile("Phone", studentData!["phonenumber"]),
            _buildInfoTile("Aadhar", studentData!["AdhharCardNumber"]),
            _buildInfoTile("Email", studentData!["email"]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(Icons.arrow_right, color: Colors.blue),
          SizedBox(width: 10),
          Text("$label:", style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
