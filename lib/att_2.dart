import 'dart:async';
import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'att.dart';
import 'dashboard_teacher.dart';

class att_2 extends StatefulWidget {
  String? Courseid ;
  String? date;
  att_2(String? courseid,String? Date){
    Courseid = courseid;
    date = Date;

  }
  @override
  State<StatefulWidget> createState() {
    return att_2State(Courseid,date);

  }
}

class att_2State extends State<att_2> {
  String? Courseid ;
  String? date;

  att_2State(String? CourseId,String? Date){
    Courseid = CourseId;
    date = Date;


  }
  List student =[];


  Future<void> GetStudentData() async{
    String uri = "http://192.168.216.112/flutter/getstudentdata.php";
    var res = await http.post(Uri.parse(uri),body: {
      "courseid" : Courseid
    }) ;
    setState(() {
      student = jsonDecode(res.body);
      print(student);

    });
  }
  var jso ;
  String? encoded_absentids ;
  String? encoded_studentis ;
  Codec<String, String> stringToBase64 = utf8.fuse(base64);
  Future<void> uploadAttendence () async{

    String  uri = "http://192.168.216.112/flutter/uploadattendence.php";
    var res = await http.post(Uri.parse(uri), body: {
     "absentarray":encoded_absentids,
      "studentdata":encoded_studentis,
      "date" : date,
      "courseid":Courseid
    });
   setState(() {
     print(res.body);
   });
  }

bool a = false;
  List<String> absentids =[];
  List <int> lint =[];


  @override
  void initState() {
    super.initState();
    GetStudentData();

  }
  void _onSelected(bool selected, String dataName) {
    if (selected == false) {
      setState(() {
        absentids.add(dataName);
      });
    } else {
      setState(() {
        absentids.remove(dataName);
      });
    }
   setState(() {
     List <int> absentidslist = absentids.map(int.parse).toList();
     List<int> studentIds = student.map((student) {
       var id = student['studentid'];
       return int.parse(id); // Ensure id is parsed as an int
     }).toList();

     print(studentIds);
     encoded_studentis = base64Url.encode(utf8.encode(studentIds.toString()));

     encoded_absentids = base64Url.encode(utf8.encode(absentidslist.toString()));
     print(encoded_absentids);
     print(absentidslist);
   });


  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Attendence Upload",
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
                        MaterialPageRoute(
                            builder: (context) => att()));
                  },
                  child: Icon(
                    Icons.arrow_circle_left_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              title:  Container(
                child: Row(
                  children: [
                    Text(
                      "Attendence Upload",
                      style: TextStyle(color: Colors.white),
                    ),
                    Material(
                      color: Colors.blue[700],
                      child: InkWell(
                        onTap: () {
                          uploadAttendence();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 90),
                          child: Icon(
                            Icons.cloud_upload,
                            color: Colors.white,
                            size: 40,
                          ),
                        )
                      ),
                    ),

                  ],
                ),
              )
            ),
          ),
          body: Stack(
              children: [
                Container(
                  height: 200,
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(color: Colors.blue[700]),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  height: 900,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(120),
                          topLeft: Radius.circular(120))),
                  child:  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                    child:ListView.separated(
                        separatorBuilder: (context, index) {
                          return Divider();
                        },
                        itemCount: student.length,

                        itemBuilder: (context, i) {
                          return ListTile(
                              title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 100.0,),
                                      child: Text( student[i]["studentname"]),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [

                                        Container(
                                          alignment: Alignment.topRight,
                                          child: Checkbox(
                                            value: !absentids.contains(student[i]["studentid"]),
                                            onChanged: (val) {
                                              _onSelected(val!, student[i]["studentid"]);
                                            },
                                          ),
                                        ),
                                        //
                                      ],
                                    ),
                                  ],
                                ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[300],
                                child: Text( student[i]["studentid"]),
                              ),
                            // trailing:
                          );
                        })
                  ),
                ),
              ],
          )
    ),
    );
  }
}
