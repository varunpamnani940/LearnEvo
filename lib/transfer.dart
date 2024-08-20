import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dashboard_teacher.dart';
import 'EditStudent.dart';
import 'login.dart';

class Transfer extends StatefulWidget {
  @override
  State<Transfer> createState() => TransferState();
}

class TransferState extends State<Transfer> {
  List student = [];
  List<Map<String, dynamic>> courseData = [];
  List<String> courseNames = [];
  List filteredStudents = [];
  Map<int, bool> uncheckedStudents = {}; // To store unchecked students only
  String selectedYear = 'All Years';
  String selectedDepartment = 'All Departments';
  String? selectedCourse;
  String? selectedCourse2;
  String enocdedids="";
  String searchQuery = '';
  List CourseData = [];
  Future<void> upload() async{
    String uri = "http://${ipAddress}/flutter/transfer.php";
    print("to$selectedCourse2");
    print("from$selectedCourse");
    print(enocdedids);
    var res = await http.post(Uri.parse(uri),body: {
      "transfer_to_courseid":selectedCourse2,
      "from_courseid":selectedCourse,
      "encodeuncheckedstudent":enocdedids

    });
    setState(() {
      print(res.body);
    });
  }
  Future<void> getCoruse() async {
    try {
      String uri = "http://$ipAddress/flutter/viewcourse.php";
      var res = await http.post(Uri.parse(uri), body: {});
      setState(() {
        CourseData = jsonDecode(res.body);
        print(CourseData);
      });
    } catch (e) {
      print(e);
    }
  }
  Future<void> getData() async {
    try {
      String uri = "http://${ipAddress}/flutter/viewcourse.php";
      var res = await http.post(Uri.parse(uri), body: {});
      setState(() {
        courseData = jsonDecode(res.body).cast<Map<String, dynamic>>();
        courseNames = ['All Courses'] +
            courseData.map((course) => course['coursename'] as String).toList();
        print(courseData);
        print(courseNames);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> getStudentData() async {
    try {
      String uri = "http://${ipAddress}/flutter/getallstudentdata.php";
      var res = await http.post(Uri.parse(uri), body: {});
      setState(() {
        student = jsonDecode(res.body);
        filteredStudents = student;
        print(student);
      });
    } catch (e) {
      print(e);
    }
  }

  void filterStudents() {
    setState(() {
      filteredStudents = student.where((s) {
        final matchesCourse = selectedCourse == 'All Courses' ||
            s['coursename'] == selectedCourse;
        final matchesYear = selectedYear == 'All Years' ||
            s['year'] == selectedYear;
        final matchesDepartment = selectedDepartment == 'All Departments' ||
            s['department'] == selectedDepartment;
        final matchesSearchQuery = searchQuery.isEmpty ||
            s['studentname'].toLowerCase().contains(searchQuery.toLowerCase());
        return matchesCourse && matchesYear && matchesDepartment &&
            matchesSearchQuery;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getStudentData();
    getData();
    getCoruse();
    List<dynamic> ids = extractIds(uncheckedStudents);
    print(ids);
    setState(() {
      enocdedids = base64Url.encode(utf8.encode(ids.toString()));
    });
    print(enocdedids);

  }
  List<dynamic> extractIds(Map<dynamic, bool>? map) {
    if (map == null) {
      return [];
    }
    return map.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Available Students",
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Transfer Student",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 100),
                Expanded(
                  child: Material(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        showCheckedStudentsDialog(context);
                      },
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Icon(Icons.cloud_upload, color: Colors.white,
                              size: 50),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blue[700],
            leading: Container(
              child: Material(
                color: Colors.blue[700],
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context, MaterialPageRoute(
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
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    // Search Bar

                    // DropDown Buttons in a Row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedCourse,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedCourse = newValue!;
                                  filterStudents();
                                });
                              },
                              underline: SizedBox(),
                              items: courseNames.map<DropdownMenuItem<String>>((
                                  courseName) {
                                return DropdownMenuItem<String>(
                                  value: courseName,
                                  child: Text(courseName),
                                );
                              }).toList(),
                              isExpanded: true,
                              hint: Text("From "),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: DropdownButton(
                              value: selectedCourse2,
                              isExpanded: true,
                              underline: SizedBox(),
                              itemHeight: 50,
                              hint: Text(
                                "Select Course",
                                style: TextStyle(fontSize: 30),
                              ),
                              icon: Icon(Icons.arrow_downward),
                              iconSize: 24,
                              elevation: 16,
                              items: CourseData.map((e) {
                                return DropdownMenuItem(
                                  child: Text(e['coursename']),
                                  value: e['courseid'],
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCourse2 = value.toString();
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                    // Student List
                    ListView.builder(
                      padding: EdgeInsets.all(0),
                      shrinkWrap: true, // Disable scrolling for the ListView
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        int studentId = int.parse(
                            filteredStudents[index]['studentid'].toString());
                        bool isChecked = !uncheckedStudents.containsKey(
                            studentId);

                        return Padding(
                          padding: EdgeInsets.all(5.0),
                          child: ListTile(
                            tileColor: Colors.white,
                            leading: CircleAvatar(),
                            trailing: Checkbox(
                              value: isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    uncheckedStudents.remove(studentId);
                                  } else {
                                    uncheckedStudents[studentId] = true;
                                  }
                                  print(uncheckedStudents);

                                  List<dynamic> ids = extractIds(uncheckedStudents);
                                  print(ids);
                                  enocdedids = base64Url.encode(utf8.encode(ids.toString()));
                                  print(enocdedids);

                                });
                              },
                            ),
                            title: Text(
                              filteredStudents[index]["studentname"],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                                filteredStudents[index]["coursename"]),
                            onTap: () {
                              // Implement onTap action
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }

  void showCheckedStudentsDialog(BuildContext context) {
    List checkedStudents = filteredStudents.where((student) {
      int studentId = int.parse(student['studentid'].toString());
      return !uncheckedStudents.containsKey(studentId);
    }).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Checked Students"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: checkedStudents.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(),
                  title: Text(
                    checkedStudents[index]["studentname"],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(checkedStudents[index]["coursename"]),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              onPressed: () {
                upload();
                // Implement your upload functionality here

              },
              child: Text("Upload"),
            ),
          ],
        );
      },
    );
  }
  void uploadCheckedStudents(List checkedStudents) {
    // Implement your logic to upload the checked students
    // This could involve sending the data to a server, saving it locally, etc.
    // For now, let's just print the checked students:
    print("Uploading the following students:");
    checkedStudents.forEach((student) {
      print(student["studentname"]);
    });
  }
}