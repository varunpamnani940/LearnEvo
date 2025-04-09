import 'dart:convert';
import 'package:flutter/material.dart';
import 'AddCourse.dart';
import 'package:http/http.dart' as http;
import '../login.dart';

class AviableCourse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AviableCourseState();
  }
}

class AviableCourseState extends State<AviableCourse> {
  List CourseData = [];
  bool isLoading = true;

  Future<void> getData() async {
    try {
      String uri = "http://$ipAddress/flutter/viewcourse.php";
      var res = await http.post(Uri.parse(uri), body: {});
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

  Future<void> Delette_course(a) async {
    try {
      String uri = "http://$ipAddress/flutter/deletecourse.php";
      var res = await http.post(Uri.parse(uri), body: {"inactive": a});
      print(jsonDecode(res.body));
      await getData();
    } catch (e) {
      print(e);
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
        title: "Add Course",
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(150.0),
              child: AppBar(
                title: Text(
                  "Available Courses",
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
                        Navigator.pop(context, MaterialPageRoute(builder: (context) => AddCourse()));
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
            body: Stack(
              children: [
                Container(
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
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Padding(
                      padding: EdgeInsets.all(10),
                      child: ListView.builder(
                          itemCount: CourseData.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Material(
                                child: InkWell(
                                  onTap: () async {
                                    await Delette_course(CourseData[index]["courseid"]);
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              title: Text(CourseData[index]["courseid"]),
                              subtitle: Text(CourseData[index]["coursename"]),
                              trailing: IconButton(
                                icon: Icon(
                                  CourseData[index]["activestatus"] == "1"
                                      ? Icons.toggle_on
                                      : Icons.toggle_off,
                                  color: CourseData[index]["activestatus"] == "1"
                                      ? Colors.green
                                      : Colors.red,
                                  size: 40, // Adjust the size here to make the icon bigger
                                ),
                                onPressed: () {
                                  // Here, toggle the course status locally
                                  setState(() {
                                    CourseData[index]["activestatus"] =
                                    CourseData[index]["activestatus"] == "1" ? "0" : "1";
                                  });

                                  // Optionally, make a backend request to update the status
                               change_course(CourseData[index]["courseid"]);
                                },
                              ),
                            );
                          }),
                    ))
              ],
            )));
  }

  Future<void> change_course(courseData) async{

  }
}
