import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_admin.dart';
import '../login.dart';

class AddCourse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddCourseState();
  }
}

class AddCourseState extends State<AddCourse> {
  final _formKey = GlobalKey<FormState>();
  String? _activeStatus;
  TextEditingController _courseNameController = TextEditingController();
  TextEditingController _courseFeesController = TextEditingController();
  List<dynamic> CourseData = [];
  bool isLoading = true;

  Future<void> addCourse(BuildContext context) async {
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Course Has Been Added Successfully!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          getData();
        }
      } catch (e) {
        print(e);
      }
    }
  }
  Future<void> deleteCourse(String courseId, BuildContext context) async {
    try {
      String uri = "http://$ipAddress/flutter/deletecourse.php";
      var res = await http.post(Uri.parse(uri), body: {"inactive": courseId});
      var response = jsonDecode(res.body);
      print(res.body);
      if (response['recored'] == "true") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Course deleted successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        await getData(); // Refresh course list after deletion
        setState(() {}); // Ensure UI updates
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete course."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }



  Future<void> getData() async {
    try {
      String uri = "http://$ipAddress/flutter/viewcourse.php";
      var res = await http.get(Uri.parse(uri));
      setState(() {
        CourseData = jsonDecode(res.body);
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Add Course",
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: AppBar(
            title: Text(
              "Add Course",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: Colors.blue[700],
            leading: IconButton(
              icon: Icon(Icons.arrow_back, size: 40, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: Builder( // Wrap with Builder to get the right context
          builder: (BuildContext scaffoldContext) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 100,
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(color: Colors.blue[700]),
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(80),
                            topRight: Radius.circular(80),
                          ),
                        ),
                        padding: EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: "Course Name",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  prefixIcon: Icon(Icons.add_circle_outline_rounded),
                                ),
                                controller: _courseNameController,
                                validator: (value) =>
                                value!.isEmpty ? 'Please enter the course name' : null,
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: "Course Fee",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  prefixIcon: Icon(Icons.monetization_on_outlined),
                                ),
                                controller: _courseFeesController,
                                keyboardType: TextInputType.number,
                                validator: (value) =>
                                value!.isEmpty ? 'Please enter the course fee' : null,
                              ),
                              SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: _activeStatus,
                                hint: Text("Select Status for Course"),
                                items: [
                                  DropdownMenuItem(child: Text("Active"), value: "1"),
                                  DropdownMenuItem(child: Text("Inactive"), value: "0"),
                                ],
                                onChanged: (newValue) {
                                  setState(() {
                                    _activeStatus = newValue;
                                  });
                                },
                                validator: (value) =>
                                value == null ? 'Please select a status' : null,
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  addCourse(scaffoldContext); // Pass correct context
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 50),
                                  textStyle:
                                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
                                ),
                                child: Text("Add Course",style:  TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),),
                              ),
                              SizedBox(height: 20),
                              Divider(),
                              _buildCourseList(scaffoldContext), // Pass correct context
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildCourseList(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Available Courses",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue[900],
            ),
          ),
          Divider(color: Colors.blue[900]),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : CourseData.isEmpty
              ? Center(
            child: Text("No courses added yet",
                style: TextStyle(fontSize: 14)),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: CourseData.length,
            itemBuilder: (context, index) {
              var course = CourseData[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  leading: Icon(Icons.book, color: Colors.blue),
                  title: Text(
                    course['coursename'],
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "Fees: \$${course['coursefees']} | Status: ${course['activestatus'] == "1" ? "Active" : "Inactive"}",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  trailing:  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _editCourseDialog(course);
                          // _editSubjectDialog(subject);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _confirmDelete(course['courseid'],context);
                        },
                      ),
                    ],
                  ),
                  // IconButton(
                  //   icon: Icon(Icons.delete, color: Colors.red),
                  //   onPressed: () {
                  //     _confirmDelete(course['courseid'], context);
                  //   },
                  // ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  void _editCourseDialog(Map<String, dynamic> course) {
    TextEditingController _courseNameController =
    TextEditingController(text: course['coursename']);
    TextEditingController _courseFeesController =
    TextEditingController(text: course['coursefees']);
    String? _activeStatus = course['activestatus'];
    bool isUpdating = false; // Track loading state

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit Course"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _courseNameController,
                    decoration: InputDecoration(labelText: "Course Name"),
                  ),
                  TextField(
                    controller: _courseFeesController,
                    decoration: InputDecoration(labelText: "Course Fee"),
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _activeStatus,
                    hint: Text("Select Status"),
                    items: [
                      DropdownMenuItem(child: Text("Active"), value: "1"),
                      DropdownMenuItem(child: Text("Inactive"), value: "0"),
                    ],
                    onChanged: (newValue) {
                      setState(() {
                        _activeStatus = newValue;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  isUpdating
                      ? Center(child: CircularProgressIndicator()) // Show loader
                      : SizedBox.shrink(),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
                TextButton(
                  child: Text("Update"),
                  onPressed: () async {
                    setState(() {
                      isUpdating = true; // Start loading
                    });

                    await updateCourse(
                      course['courseid'],
                      _courseNameController.text,
                      _courseFeesController.text,
                      _activeStatus!,
                    );

                    Navigator.pop(dialogContext); // Close dialog
                    getData(); // Refresh the list
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> updateCourse(
      String courseId, String name, String fees, String status) async {
    try {
      String uri = "http://$ipAddress/flutter/edit_course.php";
      var res = await http.post(Uri.parse(uri), body: {
        "courseid": courseId,
        "coursename": name,
        "coursefees": fees,
        "activestatus": status,
      });

      var response = jsonDecode(res.body);
      print(response);

      if (response['updated'] == 'true') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Course updated successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await getData(); // Refresh the course list after update
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update course."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }




  void _confirmDelete(String courseId, BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Delete Course"),
          content: Text("Are you sure you want to delete this course?"),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(dialogContext);
                deleteCourse(courseId, context); // Now passing context correctly
              },
            ),
          ],
        );
      },
    );
  }




}