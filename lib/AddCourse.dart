import 'dart:async';
import 'dart:convert';
import 'package:dreamclass/avaiblecourses.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dashboard_teacher.dart';
import 'package:http/http.dart' as http;


class AddCourse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddCourseState();
  }
}

class AddCourseState extends State<AddCourse> {
  String? Active;
  String Drop = "Active";
  @override
  TextEditingController coursenamecontroller  = TextEditingController();
  TextEditingController coursefeescontroller  = TextEditingController();
  TextEditingController activestatuscontroller  = TextEditingController();
  Future<void> addcourse() async{
    try{
      String uri = "http://192.168.216.112/flutter/addcourse.php";
       var res = await http.post(Uri.parse(uri),body: {
         "coursename" : coursenamecontroller.text,
         "coursefees" : coursefeescontroller.text,
         "activestatus" :activestatuscontroller.text
       });
       var respone = jsonDecode(res.body);
       print(respone);
       if(respone['recordInserted'] == 'true'){
         var alert = AlertDialog(
           content: Text("Course Added Succesfully"),
         );
         showDialog(context: context, builder: (BuildContext context){
           return alert;
         });
       }
    }
    catch(e){
      print(e);
    }
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
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                          child: TextField(
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.grey.shade400)),
                              fillColor: Colors.grey.shade200,
                              filled: true,
                              hintText: "CourseName",
                              prefixIcon: Icon(Icons.add_circle_outline_rounded),
                            ),
                            controller:  coursenamecontroller ,
                          ),),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.grey.shade400)),
                              fillColor: Colors.grey.shade200,
                              filled: true,
                              hintText: "CourseFee's",
                              prefixIcon: Icon(Icons.monetization_on_outlined),
                            ),
                            controller:  coursefeescontroller ,

                          ),),
                        SizedBox(height: 10,),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 20),
                          child:  Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey,width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(20))
                            ),
                            child: DropdownButton(
                                isExpanded: true,
                                value: Active,
                                hint: Text("Select  Status for Course"),
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
                                onChanged: (newvalue ){
                                  setState(() {
                                    Active = newvalue.toString();
                                  });
                                }
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),
                        Material(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: (){
                              addcourse();
                            },
                            child: Container(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20,horizontal: 120),
                                  child:  Text("Add Course" , style: TextStyle(
                                      color: Colors.white,fontWeight: FontWeight.w700,fontSize: 22
                                  ),),

                                )
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 20),
                          child:  Column(
                            children: [
                              Row(
                                children: [
                                  Padding(padding: EdgeInsets.symmetric(horizontal: 15),
                                      child:ImageButtonHomeInquiry()),
                                  Padding(padding: EdgeInsets.symmetric(horizontal: 15),
                                      child:ImageButtonHomeEdit()),
                                ],
                              ),
                              SizedBox(height: 10,),
                              // Row(
                              //   children: [
                              //     Padding(padding: EdgeInsets.symmetric(horizontal: 15),
                              //         child:ImageButtonHomeInquiry()),
                              //     Padding(padding: EdgeInsets.symmetric(horizontal: 15),
                              //         child:ImageButtonHomeInquiry()),
                              //   ],
                              // ),


                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
        ));
  }
}
class ImageButtonHomeInquiry extends StatefulWidget{
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=>AviableCourse()));
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
                  "Avaiable Courses",
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 17),
                )
              ],
            ),
          ),
        )
    );
  }
}
class ImageButtonHomeEdit extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ImageButtonHomeEditstate();
  }
}
class ImageButtonHomeEditstate extends State<ImageButtonHomeEdit> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
          child: InkWell(
            onTap: () {

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
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 17),
                )
              ],
            ),
          ),
        )
    );
  }
}