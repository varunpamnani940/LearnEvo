import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'att_2.dart';
import 'dashboard_teacher.dart';
import 'machine_Att_upload.dart';

class att extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return attState();
  }
}

class attState extends State<att> {
  String? selectitem ;
  List CourseData = [];
  TextEditingController DateController = TextEditingController();
  Future<void> datepicker() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(21000));
    if (picked != null) {
      setState(() {
        DateController.text = picked.toString().split(" ")[0];
      });
    }
  }

  Future<void> getcourse() async {
    String uri = "http://192.168.216.112/flutter/viewcourse.php";
    var res = await http.post(Uri.parse(uri), body: {});
    setState(() {
      CourseData = jsonDecode(res.body);
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getcourse();
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
                            builder: (context) => TeacherDashboard()));
                  },
                  child: Icon(
                    Icons.arrow_circle_left_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              title: Text(
                "Attendence Upload",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Stack(
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
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 60, vertical: 30),
                        child: TextField(
                          controller: DateController,
                          decoration: InputDecoration(
                              labelText: "Select Date",
                              filled: true,
                              prefixIcon: Icon(Icons.calendar_month),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade400))),
                          readOnly: true,
                          onTap: () {
                            datepicker();
                          },
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 60, vertical: 10),
                          child: DropdownButton(
                            value: selectitem,
                              hint: Text("Select Course To Upload Attendence"),
                              items: CourseData.map((e) {
                                return DropdownMenuItem(
                                  child: Text(e['coursename']),
                                  value: e['courseid'],
                                );
                              }).toList(),
                              onChanged: (Newvalue) {
                              setState(() {
                                selectitem = Newvalue.toString();
                              });
                              })
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10),child:
                        Material(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 90, vertical: 10),
                            child: InkWell(
                              child: Container(

                                child: Center(
                                  child: Text("Get Student Data",style: TextStyle( color: Colors.white),),
                                ),
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.all(Radius.circular(20))
                                ),
                              ),
                              onTap: (){

                                var alert = new AlertDialog(
                                  title: Text("Upload Attendence"),
                                  content: Container(
                                    height: 100,
                                    child: Column(
                                      children: [
                                        Text("Select Mode For attendence Upload",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 15),),
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                                              child: Material(
                                                color: Colors.blue[700],
                                                borderRadius: BorderRadius.circular(10),
                                                child: InkWell(
                                                  onTap: (){

                                                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  IotAttupload(selectitem)));

                                                  },
                                                  child: Container(
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                                                        child:  Text("Automated" , style: TextStyle(
                                                            color: Colors.white,fontWeight: FontWeight.w700,fontSize: 15
                                                        ),),

                                                      )
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12.0,horizontal: 20),
                                              child: Material(
                                                color: Colors.blue[700],
                                                borderRadius: BorderRadius.circular(10),
                                                child: InkWell(
                                                  onTap: (){

                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => att_2(selectitem,DateController.text)));

                                                  },
                                                  child: Container(
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                                                        child:  Text("Manual" , style: TextStyle(
                                                            color: Colors.white,fontWeight: FontWeight.w700,fontSize: 15
                                                        ),),


                                                      )
                                                  ),
                                                ),
                                              ),
                                            ),

                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                                showDialog(context: context, builder: (BuildContext context) {
                                  return alert;
                                });
                              },
                            ),
                          ),
                        ),)
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
