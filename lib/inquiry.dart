import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_teacher.dart';
import 'login.dart';

class Inquiry extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return InquiryState();
  }
}

class InquiryState extends State<Inquiry> {
  final _formKey = GlobalKey<FormState>();
  String? selectCourseId;
  List courseData = [];
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  Future<void> uploadInquiry() async {
    if (_formKey.currentState?.validate() ?? false) {
      String uri = "http://$ipAddress/flutter/inquiry.php";
      var res = await http.post(Uri.parse(uri), body: {
        "courseid": selectCourseId,
        "studentName": studentNameController.text,
        "phonenumber": phoneNumberController.text,
      });
      var r = jsonDecode(res.body);
      if (r["inserted"] == "true") {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("Inquiry Added"),
            );
          },
        ).then((_) {
          // Clear the form fields after showing the alert
          _formKey.currentState?.reset();
          setState(() {
            selectCourseId = null;
          });
        });
      }
    }
  }

  Future<void> fetchCourses() async {
    String uri = "http://$ipAddress/flutter/viewcourse.php";
    var res = await http.post(Uri.parse(uri));
    var r = jsonDecode(res.body);
    setState(() {
      courseData = r;
      print(courseData);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Inquiry",
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: AppBar(
            backgroundColor: Colors.blue[700],
            leading: Material(
              color: Colors.blue[700],
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TeacherDashboard()),
                  );
                },
                child: Icon(
                  Icons.arrow_circle_left_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            title: Text(
              "Add Inquiry",
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
                height: 800,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(120),
                    topLeft: Radius.circular(120),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: DropdownButtonFormField(
                            isExpanded: true,
                            value: selectCourseId,
                            decoration: InputDecoration(
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none
                            ),
                            hint: Text("Select Course to Add Inquiry"),
                            items: courseData.map((e) {
                              return DropdownMenuItem(
                                child: Text(e['coursename']),
                                value: e['courseid'],
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectCourseId = newValue.toString();
                              });
                            },
                            validator: (value) {
                              if (value == null ) {
                                return 'Please select a course';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: TextFormField(
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade400)),
                              fillColor: Colors.grey.shade200,
                              filled: true,
                              hintText: "Student Name",
                              prefixIcon: Icon(Icons.person),
                            ),
                            controller: studentNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the student name';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: TextFormField(
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade400)),
                              fillColor: Colors.grey.shade200,
                              filled: true,
                              hintText: "Phone Number",
                              prefixIcon: Icon(Icons.phone),
                            ),
                            controller: phoneNumberController,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the phone number';
                              }
                              if (!RegExp(r'^\+?1?\d{9,15}$').hasMatch(value)) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 30),
                        Material(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: () {
                              uploadInquiry();
                            },
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 10),
                                child: Icon(
                                  Icons.upload,
                                  color: Colors.white,
                                  size: 60,
                                ),
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
