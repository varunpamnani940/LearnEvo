import 'dart:convert';
import 'package:dreamclass/dashboard_teacher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class Addsubject extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddsubjectState();
  }
}

class AddsubjectState extends State<Addsubject> {
  String? SelectCourse;
  List CourseData = [];
  TextEditingController subjectName = TextEditingController();


  Future<void> getCourseData() async {
    String uri = "http://${IpStorage.ipAddress}/flutter/viewcourse.php";
    var res = await http.post(Uri.parse(uri));
    var response = jsonDecode(res.body);
    setState(() {
      CourseData = jsonDecode(res.body);
      print(CourseData);

    });
  }
  Future<void> uploadSubjectData() async{
    String uri = "http://192.168.216.112/flutter/addsubject.php";
     var res = await http.post(Uri.parse(uri),body: {
       "cid" : SelectCourse,
       "subjectname" : subjectName.text
     });
     var response = jsonDecode(res.body);
    if(response['recordInserted']=="true"){
      var alert = AlertDialog(content: Text("Recored Inserted",));
      showDialog(context: context, builder: (context){
        return alert;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getCourseData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Add Subject",
      home: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(150.0),
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
                "Add Subject",
                style: TextStyle(color: Colors.white),
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
                  height: 400,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(120),
                          topLeft: Radius.circular(120))),
                  child: Column(
                    children: [
                      SizedBox(height: 30,),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                    child:  Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey,width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                      child: DropdownButton(
                        underline: SizedBox(),
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down_circle_outlined,size: 40,),
                          value: SelectCourse,
                          hint: Text("Select Course to Add Subject"),
                          items: CourseData.map((e) {
                            return DropdownMenuItem(
                              child: Text(e["coursename"]),
                              value:e['coursename'] ,
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              SelectCourse = value.toString();
                            });
                          }),
                    ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                      child:   TextField(
                        decoration: InputDecoration(
                          enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade400)
                          ),
                          fillColor: Colors.grey.shade200,
                          filled: true,
                          hintText: "Subject Name",
                          prefixIcon: Icon(Icons.subject_rounded),
                        ),
                        controller: subjectName,
                      ),
                    ),
                      SizedBox(height: 30,),
                      Material(
                        color: Colors.blue[700],
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: (){
                            setState(() {
                              uploadSubjectData();
                            });

                          },
                          child: Container(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 50 ,vertical: 10),
                                child: Icon(Icons.upload,color: Colors.white,size: 60,)
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
