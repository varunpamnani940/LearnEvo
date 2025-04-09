
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dashboard_admin.dart';
import 'package:http/http.dart' as http;

class Editstudent extends StatefulWidget {
  const Editstudent({super.key});

  @override
  State<Editstudent> createState() => _EditstudentState();
}

class _EditstudentState extends State<Editstudent> {
  List collagedata=[];
  String? SelectedCollage;
  List CourseData = [];
  String? SelectedCourse;
  Future<void> getcourse() async {
    String uri = "http://localhost/flutter/viewcourse.php";
    var res = await http.post(Uri.parse(uri), body: {});
    CourseData = jsonDecode(res.body);
    setState(() {
      CourseData = jsonDecode(res.body);
      print(CourseData);
    });
  }

  Future<void> getcollageid() async {

    String uri = "http://localhost/flutter/viewcollage.php";
    var res = await http.post(Uri.parse(uri), body: {});

    setState(() {
      collagedata = jsonDecode(res.body);
      print(collagedata);
    });
  }

  String Values="";
  @override
  void initState() {
    getcollageid();
    getcollageid();
    getcourse();
    super.initState();
  }
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Edit Students",
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(150.0),
          child: AppBar(
            title: Text(
              "Edit Students",
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
                  onTap: (){
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

        body:
        SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                height: 100,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(color: Colors.blue[700]),
              ),
              Container(
                height: 700,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(80),
                        topRight: Radius.circular(80))
                ),

                padding: EdgeInsets.all(25),
                child:Scaffold(
                  body:Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: 100.0,
                            child: TextField(
                              decoration: InputDecoration(labelText: 'Name'),
                            ),
                          ),

                          SizedBox(width: 55,),
                          Padding(padding: EdgeInsets.all(25),
                            child:
                            Row(children: [
                              Container(
                                width: 100.0,
                                child: TextField(
                                  decoration: InputDecoration(labelText: 'Phone No.',
                                  ),
                                ),
                              ),
                            ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width: 100.0,
                                child: TextField(
                                  decoration: InputDecoration(labelText: 'Email'),
                                ),
                              ),

                              SizedBox(width: 55,),
                              Padding(padding: EdgeInsets.all(25),
                                child:
                                Row(children: [
                                  Container(
                                    width: 100.0,
                                    child: TextField(
                                      decoration: InputDecoration(labelText: 'Password',
                                      ),
                                    ),
                                  ),
                                ],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                      width: 100.0,
                                      child: DropdownButton(
                                        underline: SizedBox(),
                                        value: SelectedCollage,

                                        hint: Text(
                                          "Select Collage",
                                          style: TextStyle(fontSize: 30),
                                        ),
                                        icon: Icon(Icons.arrow_downward),
                                        iconSize: 24,
                                        elevation: 16,
                                        isExpanded: true,
                                        items: collagedata.map((e) {
                                          return DropdownMenuItem(
                                            child: Text(e['collagename']),
                                            value: e['collageid'],
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            SelectedCollage = value.toString();
                                          });
                                        },
                                      ),
                                  ),

                                  SizedBox(width: 55,),
                                  Padding(padding: EdgeInsets.all(25),
                                    child:Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                            width: 100.0,
                                            child:DropdownButton(
                                              value: SelectedCourse,
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
                                                  SelectedCourse = value.toString();
                                                });
                                              },
                                            ),)

                                      ],),
                                  ),
                                ],
                              ),


                              Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          width: 100.0,
                                          child: TextField(
                                            decoration: InputDecoration(labelText: 'Adhar No.'),
                                          ),
                                        ),

                                        SizedBox(width: 55,),
                                        Padding(padding: EdgeInsets.all(25),
                                          child:
                                          Row(children: [
                                            Container(
                                              width: 100.0,
                                              child: TextField(
                                                decoration: InputDecoration(labelText: 'Parents No.',
                                                ),
                                              ),
                                            ),
                                          ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                           Container(
                                                width: 100.0,
                                                child:DropdownButton(
                                                  value: SelectedCollage,
                                                  isExpanded: true,
                                                  underline: SizedBox(),
                                                  itemHeight: 50,
                                                  hint: Text(
                                                    "Select Card ID",
                                                    style: TextStyle(fontSize: 30),
                                                  ),
                                                  icon: Icon(Icons.arrow_downward),
                                                  iconSize: 24,
                                                  elevation: 16,
                                                  items: collagedata.map((e) {
                                                    return DropdownMenuItem(
                                                      child: Text(e['collagename']),
                                                      value: e['collagename'],
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      SelectedCollage = value.toString();
                                                    });
                                                  },
                                                )
                                            ),

                                            SizedBox(height: 10,),
                                            Padding(padding: EdgeInsets.all(25),
                                              child:Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                 Container(
                                                      width: 100.0,
                                                      child:DropdownButton(
                                                        value: SelectedCollage,
                                                        isExpanded: true,
                                                        underline: SizedBox(),
                                                        itemHeight: 50,
                                                        hint: Text(
                                                          "Select Batch",
                                                          style: TextStyle(fontSize: 30),
                                                        ),
                                                        icon: Icon(Icons.arrow_downward),
                                                        iconSize: 24,
                                                        elevation: 16,
                                                        items: collagedata.map((e) {
                                                          return DropdownMenuItem(
                                                            child: Text(e['collagename']),
                                                            value: e['collagename'],
                                                          );
                                                        }).toList(),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            SelectedCollage = value.toString();
                                                          });
                                                        },
                                                      )
                                                  ),

                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20,),
                                        Material(
                                          color: Colors.blue[700],
                                          borderRadius: BorderRadius.circular(10),
                                          child: InkWell(
                                            onTap: (){

                                            },
                                            child: Container(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 15,horizontal: 80),
                                                  child:  Text("Edit Details" , style: TextStyle(
                                                      color: Colors.white,fontWeight: FontWeight.w700,fontSize: 18
                                                  ),),

                                                )
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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