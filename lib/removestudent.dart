import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dashboard_teacher.dart';
import 'EditStudent.dart';
import 'login.dart';

class Removestudent extends StatefulWidget {
  @override
  State<Removestudent> createState() => RemovestudentState();
}

class RemovestudentState extends State<Removestudent> {
  List student = [];
  List<Map<String, dynamic>> CourseData = [];
  List<String> courseNames = [];
  List filteredStudents = [];
  String selectedCourse = 'All Courses';
  String selectedYear = 'All Years';
  String selectedDepartment = 'All Departments';
  String searchQuery = '';

  Future<void> getData() async {
    try {
      String uri = "http://$ipAddress/flutter/viewcourse.php";
      var res = await http.post(Uri.parse(uri), body: {});
      setState(() {
        CourseData = jsonDecode(res.body).cast<Map<String, dynamic>>();
        // Add 'All Courses' option to the beginning of the list
        courseNames = ['All Courses'] +
            CourseData.map((course) => course['coursename'] as String).toList();
        print(CourseData);
        print(courseNames);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> getstudentdata() async {
    String uri = "http://$ipAddress/flutter/getallstudentdata.php";
    var res = await http.post(Uri.parse(uri), body: {});
    setState(() {
      student = jsonDecode(res.body);
      filteredStudents =
          student; // Initialize filteredStudents with all students
      print(student);
    });
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

  Future<void> delete(int index) async {
    String uri = "http://$ipAddress/flutter/deletestudent.php";
    var res = await http.post(Uri.parse(uri), body: {
      "studentid": filteredStudents[index]["studentid"],
    });
  }

  void show(int index) {
    showDialog(context: context, builder: (BuildContext) {
      return AlertDialog(
        title: Text("Upload Attendence"),
        content: Container(
          height: 100,
          child: Column(
            children: [
              Text("Are you Sure you want Delete the Student Records ",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),),

            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await delete(index);
              await getstudentdata();
              await getData();
              filterStudents();
              Navigator.pop(context); // Close the dialog
            },
            child: Text("Submit"),
          ),
        ],
      );
    });
  }

  @override
  void initState() {
    super.initState();
    getstudentdata();
    getData();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Remove Students",
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: AppBar(
            title: Text(
              "Remove Students",
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                            filterStudents();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by student name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
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
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedYear,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedYear = newValue!;
                                  filterStudents();
                                });
                              },
                              underline: SizedBox(),
                              items: <String>[
                                'All Years',
                                '2021',
                                '2022',
                                '2023',
                                '2024'
                              ]
                                  .map<DropdownMenuItem<String>>((
                                  String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              isExpanded: true,
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                    // Student List
                    ListView.builder(
                      padding: EdgeInsets.all(0),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      // Disable scrolling for the ListView
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) =>
                          Padding(
                            padding: EdgeInsets.all(5.0),
                            child: ListTile(
                              tileColor: Colors.white,
                              leading: CircleAvatar(),
                              trailing: Material(
                                child: InkWell(
                                  child: Icon(
                                    Icons.delete, color: Colors.red[300],),
                                  onTap: () {
                                    show(index);
                                  },
                                ),
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
                          ),
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

}
