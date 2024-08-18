import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dashboard_teacher.dart';
import 'package:http/http.dart' as http;

class AddStudent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddStudentState();
  }
}

class AddStudentState extends State<AddStudent> {
  List collagedata = [];
  List CourseData = [];
  String? SelectedCollage;
  String? SelectedCourse;
  TextEditingController name =TextEditingController();
  TextEditingController pno = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController adh = TextEditingController();
  TextEditingController ppno = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController  cardid = TextEditingController();
  List card = [];
  String Card_uid = "";

  Future<void> getcard() async{
    String  uri = "http://192.168.216.112/flutter/studentcard.php";
    var res = await http.post(Uri.parse(uri));
    setState(() {
      card = jsonDecode(res.body);
      Card_uid  = card[0];
      print(Card_uid);


    });
  }
  Future<void> getcollageid() async {
    String uri = "http://192.168.216.112/flutter/viewcollage.php";
    var res = await http.post(Uri.parse(uri), body: {});
    collagedata = jsonDecode(res.body);
    setState(() {
      print(collagedata);
    });
  }

  Future<void> getcourse() async {
    String uri = "http://192.168.216.112/flutter/viewcourse.php";
    var res = await http.post(Uri.parse(uri), body: {});
    CourseData = jsonDecode(res.body);
    setState(() {
      CourseData = jsonDecode(res.body);
      print(CourseData);
    });
  }
  Future<void> uploadData() async{
    String uri = "http://192.168.216.112/flutter/addstudent.php";
    print(SelectedCollage);
    print(SelectedCourse);
    var res = await http.post(Uri.parse(uri),body: {
      "name": name.text,
      "password":password.text,
      "pnumber": pno.text,
      "email":email.text,
      "collageid": SelectedCollage,
      "adcard":adh.text,
      "ppno":ppno.text,
      "coursename":SelectedCourse,
      "card" : cardid.text
    });
    var response = jsonDecode(res.body);
    if(response["recordInserted"]=="true"){
      var alert = AlertDialog(
        content: Text("Student Recored Inserted"),
      );
      showDialog(context: context, builder: (BuildContext context){
        return alert;
      });
    }
  }

  @override
  void initState() {
    getcollageid();
    getcourse();
    getcard();
    super.initState();
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
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: TextField(
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade400)),
                                fillColor: Colors.grey.shade200,
                                filled: true,
                                hintText: "Name",
                                prefixIcon: Icon(Icons.person_rounded),
                              ),
                              controller: name,
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: TextField(
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.white)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade400)),
                                fillColor: Colors.grey.shade200,
                                filled: true,
                                hintText: "Card UID",
                                prefixIcon: Icon(Icons.person_rounded),
                              ),
                             readOnly: true,
                              controller: cardid,
                              onTap: (){
                               setState(() {
                                 getcard();
                                 cardid.text = Card_uid;
                               });
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: TextField(
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade400)),
                                fillColor: Colors.grey.shade200,
                                filled: true,
                                hintText: "Phone Number",
                                prefixIcon: Icon(Icons.contact_page_outlined),
                              ),
                              controller: pno,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: TextField(
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade400)),
                                fillColor: Colors.grey.shade200,
                                filled: true,
                                hintText: "Email",
                                prefixIcon: Icon(Icons.email),
                              ),
                              controller: email,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey,width: 1),
                                borderRadius: BorderRadius.circular(20)
                              ),
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
                            )
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey,width: 1),
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child:  DropdownButton(
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
                              ),
                            )
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: TextField(
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.white)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade400)),
                                fillColor: Colors.grey.shade200,
                                filled: true,
                                hintText: "Adhar Card number",
                                prefixIcon: Icon(Icons.confirmation_num_rounded),
                              ),
                              controller: adh,
                            ),

                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: TextField(
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.white)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade400)),
                                fillColor: Colors.grey.shade200,
                                filled: true,
                                hintText: "Parent's Phone Number",
                                prefixIcon: Icon(Icons.contact_page_outlined),
                              ),
                              controller: ppno,
                            ),
                          ),
                          SizedBox(height: 20,),
                          Material(
                            color: Colors.blue[700],
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: (){
                                uploadData();
                              },
                              child: Container(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20,horizontal: 120),
                                    child:  Text("Add Student" , style: TextStyle(
                                        color: Colors.white,fontWeight: FontWeight.w700,fontSize: 22
                                    ),),

                                  )
                              ),
                            ),
                          ),
                          SizedBox(height: 20,)
                        ],
                      ),
                    )),
              ],
            )));
  }
}
