import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../login.dart';

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({Key? key}) : super(key: key);

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  List data = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String uri = "http://$ipAddress/flutter/edit_tea_pf.php";
    var res = await http.post(Uri.parse(uri), body: {
      "email": sp.getString("emailt"),
    });

    if (res.statusCode == 200) {
      setState(() {
        data = jsonDecode(res.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ChangePasswordDialog(email: data[0]['td_email']),
              );
            },
            tooltip: "Change Password",
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => EditTeacherDialog(
                  data: data[0],
                  onSave: getData,
                ),
              );
            },
            tooltip: "Edit Profile",
          ),
        ],
      ),
      body: data.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileImage(data[0]['teacher_image']),
            const SizedBox(height: 16),
            _infoTile("Name", data[0]['td_name']),
            _infoTile("Email", data[0]['td_email']),
            _infoTile("Phone", data[0]['td_phone']),
            _infoTile("Aadhaar", data[0]['adhhar_card']),
            const Divider(height: 32),
            const Text("Permissions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _permissionTile("Student Management", data[0]['student_manage_p'].toString()),
            _permissionTile("Fee Management", data[0]['fee_manage_p'].toString()),
            _permissionTile("Faculty Management", data[0]['faculty_manage_p'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String imageName) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey[300],
      child: ClipOval(
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/images/loading_2.gif',
          image: "http://$ipAddress/flutter/teacherimage/$imageName",
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          imageErrorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person, size: 40, color: Colors.grey);
          },
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return ListTile(
      leading: const Icon(Icons.info),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  Widget _permissionTile(String title, String value) {
    return ListTile(
      leading: const Icon(Icons.security),
      title: Text(title),
      trailing: Icon(
        value == "1" ? Icons.check_circle : Icons.cancel,
        color: value == "1" ? Colors.green : Colors.red,
      ),
    );
  }
}

class EditTeacherDialog extends StatefulWidget {
  final Map data;
  final VoidCallback onSave;

  const EditTeacherDialog({Key? key, required this.data, required this.onSave})
      : super(key: key);

  @override
  State<EditTeacherDialog> createState() => _EditTeacherDialogState();
}

class _EditTeacherDialogState extends State<EditTeacherDialog> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController aadhaarController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data['td_name']);
    phoneController = TextEditingController(text: widget.data['td_phone']);
    aadhaarController = TextEditingController(text: widget.data['adhhar_card']);
  }

  Future<void> updateProfile() async {
    String uri = "http://$ipAddress/flutter/update_teacher.php";

    var res = await http.post(Uri.parse(uri), body: {
      "email": widget.data['td_email'],
      "name": nameController.text,
      "phone": phoneController.text,
      "aadhaar": aadhaarController.text,
    });

    if (res.statusCode == 200 && res.body.trim() == "success") {
      Navigator.pop(context);
      widget.onSave();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Profile"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone",
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: aadhaarController,
              decoration: const InputDecoration(
                labelText: "Aadhaar",
                prefixIcon: Icon(Icons.credit_card),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: updateProfile, child: const Text("Save")),
      ],
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  final String email;
  const ChangePasswordDialog({Key? key, required this.email}) : super(key: key);

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController oldPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  bool isLoading = false;

  Future<void> updatePassword() async {
    if (newPassController.text != confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New passwords do not match")),
      );
      return;
    }

    setState(() => isLoading = true);

    String uri = "http://$ipAddress/flutter/edit_t_p.php";
    var res = await http.post(Uri.parse(uri), body: {
      "email": widget.email,
      "old_password": oldPassController.text,
      "new_password": newPassController.text,
    });
    print(res.body);
    setState(() => isLoading = false);

    if (res.statusCode == 200 && res.body.trim() == "success") {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password update  Successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Change Password"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Old Password"),
            ),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm Password"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: isLoading ? null : updatePassword,
          child: isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Update"),
        ),
      ],
    );
  }
}
