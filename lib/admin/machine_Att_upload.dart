import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dashboard_admin.dart';
class IotAttupload extends StatefulWidget{
  String? courseid;

  @override
  State<StatefulWidget> createState() {
   return IotAttuploadState(courseid);
  }

  IotAttupload(this.courseid);
}
class IotAttuploadState extends State<IotAttupload>{
  String? Courseid;
  List student = [];
  String? encoded_studentcardis;
  Future<void> GetStudentData() async{
    String uri = "http://192.168.216.112/flutter/getstudentdata.php";
    var res = await http.post(Uri.parse(uri),body: {
      "courseid" : Courseid
    }) ;
    setState(() {
      student = jsonDecode(res.body);
      print(student);
      List<dynamic> studentcardids = student.map((student) {
        return   student['carduid'];
      // Ensure id is parsed as an int
      }).toList();
      print(studentcardids);
      encoded_studentcardis = base64Url.encode(utf8.encode(studentcardids.toString()));
      print(encoded_studentcardis);

    });
  }

  @override
  void initState() {
    GetStudentData();
    super.initState();
  }
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Add Course",
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(150.0),
              child: AppBar(
                title: Text(
                  "Add Student",
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
                                builder: (context) => admin_dashboard()));
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
                            topRight: Radius.circular(80))
                    ),
                  child: Container(
                 //   child: ,
                  ),

                )

   ]          )));
  }

  IotAttuploadState(this.Courseid);
}
