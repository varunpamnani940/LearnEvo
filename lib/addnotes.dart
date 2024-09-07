import 'dart:convert';
import 'login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_teacher.dart';

class AddNotes extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddNotesState();
  }
}

class AddNotesState extends State<AddNotes> {
  List CourseData = [];
  List SubjectData = [];
  String? selectItem;
  String? selectSubject;
  final TextEditingController link = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> getCourseData() async {
    String uri = "http://$ipAddress/flutter/viewcourse.php";
    var res = await http.post(Uri.parse(uri));

    setState(() {
      CourseData = jsonDecode(res.body);
      print(CourseData);
    });
  }

  Future<void> uploadNotes() async {
    if (_formKey.currentState?.validate() ?? false) {
      String uri = "http://$ipAddress/flutter/addnotes.php";
      var response = await http.post(Uri.parse(uri), body: {
        "courseid": selectItem,
        "link": link.text,
        "subjectid": selectSubject,
      });

      var res = jsonDecode(response.body);
      if (res["noteuploaded"] == "true") {
        var alert = AlertDialog(content: Text("Note's Uploaded"),);
        showDialog(context: context, builder: (BuildContext context) {
          return alert;
        });
      }
      print(res);
    }
  }

  Future<void> getSubjectData() async {
    String uri = "http://$ipAddress/flutter/viewsubject.php";
    var res = await http.post(Uri.parse(uri), body: {
      "courseod": selectItem
    });

    setState(() {
      SubjectData = jsonDecode(res.body);
      print(SubjectData);
    });
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
      title: "Add Notes",
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(150.0),
          child: AppBar(
            title: Text(
              "Add Notes",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: Colors.blue[700],
            leading: Container(
              child: Material(
                color: Colors.blue[700],
                child: InkWell(
                  onTap: () {
                    Navigator.pop(
                      context,
                      MaterialPageRoute(builder: (context) => TeacherDashboard()),
                    );
                  },
                  child: Icon(
                    Icons.arrow_circle_left_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                height: 100,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(color: Colors.blue[700]),
              ),
              Container(
                height: 700,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(80),
                    topRight: Radius.circular(80),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: InputDecoration(
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none
                            ),
                            value: selectItem,
                            hint: Text("Select Course to Upload Notes"),
                            items: CourseData.map((e) {
                              return DropdownMenuItem<String>(
                                child: Text(e['coursename']),
                                value: e['courseid'],
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectItem = newValue;
                                getSubjectData();
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a course';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: selectSubject,
                            hint: Text("Select Subject to Upload Notes"),
                            items: SubjectData.map((e) {
                              return DropdownMenuItem<String>(
                                child: Text(e['subjectname']),
                                value: e['subjectid'],
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectSubject = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a subject';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: link,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            fillColor: Colors.grey.shade200,
                            filled: true,
                            hintText: "Link",
                            prefixIcon: Icon(Icons.link),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a link';
                            }
                            // Add additional link validation if needed
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        Material(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: () {
                              uploadNotes();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 120),
                              child: Text(
                                "Add Notes",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22,
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
