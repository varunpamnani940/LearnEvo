import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_teacher.dart';
import 'login.dart';

class Addsubject extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddsubjectState();
  }
}

class AddsubjectState extends State<Addsubject> {
  String? selectCourse;
  List courseData = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController subjectNameController = TextEditingController();

  Future<void> getCourseData() async {
    String uri = "http://$ipAddress/flutter/viewcourse.php";
    var res = await http.post(Uri.parse(uri));
    var response = jsonDecode(res.body);
    setState(() {
      courseData = response;
      print(courseData);
    });
  }

  Future<void> uploadSubjectData() async {
    if (_formKey.currentState?.validate() ?? false) {
      String uri = "http://$ipAddress/flutter/addsubject.php";
      var res = await http.post(Uri.parse(uri), body: {
        "cid": selectCourse,
        "subjectname": subjectNameController.text,
      });
      var response = jsonDecode(res.body);
      if (response['recordInserted'] == "true") {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text("Record Inserted"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getCourseData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Add Subject",
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(150.0),
          child: AppBar(
            backgroundColor: Colors.blue[700],
            leading: Material(
              color: Colors.blue[700],
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TeacherDashboard()));
                },
                child: Icon(
                  Icons.arrow_circle_left_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            title: Text(
              "Add Subject",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                height: 400,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(color: Colors.blue[700]),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                height: 400,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(120),
                        topLeft: Radius.circular(120))),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius:
                              BorderRadius.all(Radius.circular(20))),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            ),
                            isExpanded: true,
                            value: selectCourse,
                            hint: Text("Select Course to Add Subject"),
                            items: courseData.map((e) {
                              return DropdownMenuItem<String>(
                                child: Text(e["coursename"]),
                                value: e['courseid'].toString(),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectCourse = value;
                              });
                            },
                            validator: (value) =>
                            value == null ? 'Please select a course' : null,
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400)),
                            fillColor: Colors.grey.shade200,
                            filled: true,
                            hintText: "Subject Name",
                            prefixIcon: Icon(Icons.subject_rounded),
                          ),
                          controller: subjectNameController,
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter a subject name' : null,
                        ),
                        SizedBox(height: 30),
                        Material(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: uploadSubjectData,
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                                child: Icon(Icons.upload, color: Colors.white, size: 60),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
