import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../login.dart';

class TeacherListPage extends StatefulWidget {
  @override
  _TeacherListPageState createState() => _TeacherListPageState();
}

class EditPermissionDialog extends StatefulWidget {
  final Map teacher;
  EditPermissionDialog({required this.teacher});

  @override
  _EditPermissionDialogState createState() => _EditPermissionDialogState();
}

class _EditPermissionDialogState extends State<EditPermissionDialog> {
  late bool studentManage;
  late bool feeManage;
  late bool facultyManage;

  @override
  void initState() {
    super.initState();
    studentManage = widget.teacher["student_manage_p"] == "1";
    feeManage = widget.teacher["fee_manage_p"] == "1";
    facultyManage = widget.teacher["faculty_manage_p"] == "1";
  }

  Future<void> updatePermissions() async {
    String uri = "http://$ipAddress/flutter/edit_permision.php";
    var response = await http.post(Uri.parse(uri), body: {
      "td_email": widget.teacher["td_email"],
      "student_manage_p": studentManage ? "1" : "0",
      "fee_manage_p": feeManage ? "1" : "0",
      "faculty_manage_p": facultyManage ? "1" : "0",
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Permissions"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            value: studentManage,
            onChanged: (val) => setState(() => studentManage = val),
            title: Text("Student Management"),
          ),
          SwitchListTile(
            value: feeManage,
            onChanged: (val) => setState(() => feeManage = val),
            title: Text("Fee Management"),
          ),
          SwitchListTile(
            value: facultyManage,
            onChanged: (val) => setState(() => facultyManage = val),
            title: Text("Faculty Management"),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
        ElevatedButton(onPressed: updatePermissions, child: Text("Update")),
      ],
    );
  }
}
class _TeacherListPageState extends State<TeacherListPage> {
  TextEditingController searchController = TextEditingController();
  List teachers = [];
  List filteredTeachers = [];


  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }
  Future<void> deleteTeacher(String email) async {
    String uri = "http://$ipAddress/flutter/delete_teacher.php";
    var response = await http.post(Uri.parse(uri), body: {
      "td_id": email,
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Teacher deleted successfully")),
      );
      await fetchTeachers(); // refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete teacher")),
      );
    }
  }
  Future<void> fetchTeachers() async {
    String uri = "http://$ipAddress/flutter/get_teachers.php";
    var response = await http.get(Uri.parse(uri));
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        teachers = json.decode(response.body);
        filteredTeachers = teachers;
      });
    }
  }

  void filterTeachers(String query) {
    setState(() {
      filteredTeachers = teachers
          .where((teacher) => teacher["td_name"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Teachers"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Teachers",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: filterTeachers,
            ),
            SizedBox(height: 10),
            Expanded(
              child: filteredTeachers.isEmpty
                  ? Center(child: Text("No Teachers Available"))
                  : ListView.builder(
                itemCount: filteredTeachers.length,
                itemBuilder: (context, index) {
                  var teacher = filteredTeachers[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[300], // Placeholder background color
                        child: ClipOval(
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/images/loading_2.gif', // Local loading animation
                            image: "http://$ipAddress/flutter/teacherimage/${filteredTeachers[index]["td_name"]}.jpg",
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            imageErrorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.person, size: 40, color: Colors.grey); // Default icon on error
                            },
                          ),
                        ),
                      ),

                      title: Text(teacher['td_name'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(teacher['td_email']),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            showDialog(
                              context: context,
                              builder: (context) => EditPermissionDialog(teacher: teacher),
                            );
                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Confirm Delete"),
                                  content: Text("Are you sure you want to delete this teacher?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                        deleteTeacher(teacher['td_id']); // Your deletion logic
                                      },
                                      child: Text("Delete"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),

                    ),

                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
