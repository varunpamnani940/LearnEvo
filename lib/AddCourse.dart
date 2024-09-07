import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_teacher.dart';
import 'avaiblecourses.dart';
import 'login.dart';

class AddCourse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddCourseState();
  }
}

class AddCourseState extends State<AddCourse> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  String? _activeStatus;
  TextEditingController _courseNameController = TextEditingController();
  TextEditingController _courseFeesController = TextEditingController();

  Future<void> addCourse() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        String uri = "http://$ipAddress/flutter/addcourse.php";
        var res = await http.post(Uri.parse(uri), body: {
          "coursename": _courseNameController.text,
          "coursefees": _courseFeesController.text,
          "activestatus": _activeStatus ?? "",
        });
        var response = jsonDecode(res.body);
        print(response);
        if (response['recordInserted'] == 'true') {
          var alert = AlertDialog(
            content: Text("Course Added Successfully"),
          );
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return alert;
              });
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Add Course",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(150.0),
          child: AppBar(
            title: Text(
              "Add Course",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700),
            ),
            backgroundColor: Colors.blue[700],
            leading: Container(
              child: Material(
                color: Colors.blue[700],
                child: InkWell(
                  onTap: () {
                    Navigator.pop(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TeacherDashboard()));
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
                height: 400,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(color: Colors.blue[700]),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(80),
                        topRight: Radius.circular(80))),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: TextFormField(
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.grey.shade400)),
                              fillColor: Colors.grey.shade200,
                              filled: true,
                              hintText: "Course Name",
                              prefixIcon: Icon(Icons.add_circle_outline_rounded),
                            ),
                            controller: _courseNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the course name';
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
                                  borderSide:
                                  BorderSide(color: Colors.grey.shade400)),
                              fillColor: Colors.grey.shade200,
                              filled: true,
                              hintText: "Course Fee",
                              prefixIcon: Icon(Icons.monetization_on_outlined),
                            ),
                            controller: _courseFeesController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the course fee';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(20))),
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _activeStatus,
                              hint: Text("Select Status for Course"),
                              items: [
                                DropdownMenuItem(
                                  child: Text("Active"),
                                  value: "1",
                                ),
                                DropdownMenuItem(
                                  child: Text("Inactive"),
                                  value: "0",
                                ),
                              ],
                              onChanged: (newValue) {
                                setState(() {
                                  _activeStatus = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a status';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Material(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: () {
                              addCourse();
                            },
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 120),
                                child: Text(
                                  "Add Course",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ImageButtonHomeInquiry(),
                              SizedBox(width: 15),
                              ImageButtonHomeEdit(),
                            ],
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

class ImageButtonHomeInquiry extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ImageButtonHomeInquiryState();
  }
}

class ImageButtonHomeInquiryState extends State<ImageButtonHomeInquiry> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AviableCourse()));
          },
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: CircleAvatar(
                  child: Image.asset("assets/images/ava.png"),
                  radius: 65,
                ),
              ),
              Text(
                "Available Courses",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageButtonHomeEdit extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ImageButtonHomeEditState();
  }
}

class ImageButtonHomeEditState extends State<ImageButtonHomeEdit> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        child: InkWell(
          onTap: () {
            // Implement navigation or action here
          },
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: CircleAvatar(
                  child: Image.asset("assets/images/edit.png"),
                  radius: 65,
                  backgroundColor: Colors.blue[700],
                ),
              ),
              Text(
                "Edit Details",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
