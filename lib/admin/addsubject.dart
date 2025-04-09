import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../login.dart';

class AddSubject extends StatefulWidget {
  @override
  _AddSubjectState createState() => _AddSubjectState();
}

class _AddSubjectState extends State<AddSubject> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCourse;
  List<Map<String, dynamic>> courseData = [];
  List<Map<String, dynamic>> subjectData = [];
  TextEditingController subjectNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCourses();
    fetchsubject();
  }

  Future<void> fetchCourses() async {
    String uri = "http://$ipAddress/flutter/viewcourse.php";
    var res = await http.get(Uri.parse(uri));
    if (res.statusCode == 200) {
      setState(() {
        courseData = List<Map<String, dynamic>>.from(json.decode(res.body));
      });
    }
  }
  Future<void> fetchsubject() async {
    String uri = "http://$ipAddress/flutter/view_all_subject.php";
    var res = await http.get(Uri.parse(uri));
    if (res.statusCode == 200) {
      setState(() {
        subjectData = List<Map<String, dynamic>>.from(json.decode(res.body));
      });
    }
  }
  Future<void> editSubject(String subjectId, String newName) async {
    String uri = "http://$ipAddress/flutter/edit_subject.php";
    var res = await http.post(Uri.parse(uri), body: {
      "subjectid": subjectId,
      "subjectname": newName,
    });
    print(res.body);
    fetchsubject();
    var response = jsonDecode(res.body);
    print(response);
    if (response['recordUpdated'] == "true") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Subject Updated Successfully")),
      );
    }
  }
  void _showEditDialog(Map<String, dynamic> subject) {
    TextEditingController editController =
    TextEditingController(text: subject["subjectname"]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Subject"),
        content: TextFormField(
          controller: editController,
          decoration: InputDecoration(
            labelText: "Subject Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              editSubject(subject["subjectid"], editController.text);
              Navigator.pop(context);
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }
  Future<void> deleteSubject(String subjectId) async {
    String uri = "http://$ipAddress/flutter/delete_subject.php";
    var res = await http.post(Uri.parse(uri), body: {
      "subjectid": subjectId,
    });

    print("Raw response: ${res.body}"); // Debugging line

    try {
      var response = jsonDecode(res.body);
      print("Decoded response: $response"); // Debugging line

      if (response['recordDeleted'] == "true") {
        setState(() {
          subjectData.removeWhere((subject) => subject["subjectid"] == subjectId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Subject Deleted Successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete subject")),
        );
      }
    } catch (e) {
      print("Error decoding JSON: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid JSON response")),
      );
    }
  }

  Future<void> uploadSubject() async {
    if (_formKey.currentState?.validate() ?? false) {
      String uri = "http://$ipAddress/flutter/addsubject.php";
      var res = await http.post(Uri.parse(uri), body: {
        "cid": selectedCourse,
        "subjectname": subjectNameController.text,
      });
      fetchsubject();
      var response = jsonDecode(res.body);
      if (response['recordInserted'] == "true") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Subject Added Successfully")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Container(
        color: Colors.blue[700],
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 10),
            Text(
              "Add Subject",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add a New Subject", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
              Divider(color: Colors.blue[900]),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildCourseDropdown(),
                      SizedBox(height: 10),
                      _buildTextField("Subject Name", Icons.subject, subjectNameController),
                      SizedBox(height: 20),
                      _buildSubmitButton(),
                      SizedBox(height: 20),
                      Text("Existing Subjects", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                      Divider(color: Colors.blue[900]),
                      _buildsubjectList()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue.shade400)),
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      validator: (value) => value!.isEmpty ? 'Please enter $hint' : null,
    );
  }

  Widget _buildCourseDropdown() {
    return DropdownButtonFormField(
      value: selectedCourse,
      hint: Text("Select Course"),
      items: courseData.map((course) {
        return DropdownMenuItem(
          value: course["courseid"],
          child: Text(course["coursename"]),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCourse = value.toString();
        });
      },
      validator: (value) => value == null ? 'Please select a course' : null,
    );
  }
  Widget _buildsubjectList() {
    return subjectData.isEmpty
        ? Center(child: Text("No inquiries found."))
        : ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: subjectData.length,
      itemBuilder: (context, index) {
        var inquiry = subjectData[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            title: Text(inquiry["subjectname"] ?? "Unknown"),
            subtitle: Text("Phone: ${inquiry["coursename"]}\nCourse ID: ${inquiry["courseid"]}"),
            trailing:  Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                     _showEditDialog(inquiry);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _confirmDeleteDialog(inquiry["subjectid"]);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _confirmDeleteDialog(String subjectId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Subject"),
        content: Text("Are you sure you want to delete this subject?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              deleteSubject(subjectId);
              Navigator.pop(context);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }


  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: uploadSubject,
      child: Text("Add Subject"),
    );
  }
}
