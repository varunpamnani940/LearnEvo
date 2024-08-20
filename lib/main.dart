import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'StudentFlow/dashboard_Student.dart';
import 'dashboard_teacher.dart';
import 'login.dart';
String? studid;
String? tid;
void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  @override
  Future<void> getsudentid() async{
    final SharedPreferences studentid  = await SharedPreferences.getInstance();
    String? studentsid;
    String? teacherids;
    final SharedPreferences  teacherid = await SharedPreferences.getInstance();
    studentsid = studentid.getString("studentid");
    teacherids = studentid.getString("teacher");
    setState(() {
      studid = studentsid;
      tid = teacherids;
    });
  }
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 1),
            ()=>getsudentid().whenComplete(() async{
            if(studid==null && tid ==null){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=>GetStarted()));
            }
            else if(studid == null){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=>TeacherDashboard()));
            }
            else if(tid==null){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=>StudentDashboard()));

            }
            }),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child:CircularProgressIndicator()
    );
  }
}
class GetStarted extends StatefulWidget {
  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: Stack(
        children: [
          Container(
            alignment: Alignment.topCenter,
             width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height*0.70,
            decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(140))),
            child: Container(
                child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 70, top: 170),
                  child: Image.asset('assets/images/books.png',width: 600,height: 300,),
                )
              ],
            )),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.blue[700],
              width:  MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height*0.35,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height*0.35,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(140))),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      "Learning is Everything",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height*0.01),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40,vertical: 10),
                    child: Text(
                      "Learning with  Pleasure with  Dear programer, Wherever you are",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
      
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height*0.01),
                  Material(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));
                      },
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20,horizontal: 120),
                          child:  Text("Get Started" , style: TextStyle(
                              color: Colors.white,fontWeight: FontWeight.w700,fontSize: 22
                          ),),
      
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
