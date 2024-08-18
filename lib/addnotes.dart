import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_teacher.dart';

class AddNotes extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddNotesState();
  }
}


class AddNotesState extends State<AddNotes> {
  List CourseData = [];
  List SubjectData= [];
  String? selectItem ;
  TextEditingController link = TextEditingController();
  String? selectSubject;
  Future<void> getCourseData() async{
    String uri = "http://192.168.216.112/flutter/viewcourse.php";
    var res =  await http.post(Uri.parse(uri));


    setState(() {
      CourseData = jsonDecode(res.body);

      print(CourseData);
    });

  }
  Future<void > uploadNotes() async {
    String uri = "http://192.168.216.112/flutter/addnotes.php";
    var respone = await http.post(Uri.parse(uri),body: {
      "courseid" : selectItem,
      "link" : link.text,
      "subjectid" : selectSubject
    });
    var res = jsonDecode(respone.body);
    if(res["noteuploaded"]=="true"){
      var alert = AlertDialog(content: Text("Note's Uploaded"),);
      showDialog(context: context, builder: (BuildContext context){
        return alert;
      });
    }
    print(res);
  }
  Future<void> getSubjectData() async{
    String uri = "http://192.168.216.112/flutter/viewsubject.php";
    var res =  await http.post(Uri.parse(uri));


    setState(() {
      SubjectData = jsonDecode(res.body);

      print(SubjectData);
    });

  }
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    getCourseData();
    getSubjectData();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        title: "Add Notes",
        home: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(150.0),
            child: AppBar(
              title: Text(
                "Add Notes",
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
                  child: Column(
                    children: [
                      SizedBox(height: 20,),
                     Padding(padding: EdgeInsets.symmetric(horizontal: 40),
                     child:  Container(
                       padding: EdgeInsets.symmetric(horizontal: 20),
                       decoration: BoxDecoration(
                           border: Border.all(color: Colors.grey,width: 1),
                           borderRadius: BorderRadius.all(Radius.circular(20))
                       ),
                       child: DropdownButton(
                           isExpanded: true,
                           value: selectItem,
                           hint: Text("Select Course to Upload Notes"),
                           items: CourseData.map((e) {
                             return DropdownMenuItem(child: Text(e['coursename']),value: e['courseid'],);
                           }).toList(),
                           onChanged: (newvalue ){
                             setState(() {
                               selectItem = newvalue.toString();
                             });
                           }
                       ),
                     ),
                     ),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 40,vertical: 20),
                        child:  Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey,width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          child: DropdownButton(
                              isExpanded: true,
                              value: selectSubject,
                              hint: Text("Select Subject to Upload Notes"),
                              items: SubjectData.map((e) {
                                return DropdownMenuItem(child: Text(e['subjectname']),value: e['subjectid'],);
                              }).toList(),
                              onChanged: (newvalue ){
                                setState(() {
                                  selectSubject = newvalue.toString();
                                });
                              }
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 50),
                        child: TextField(
                          decoration: InputDecoration(
                              enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.shade400)),
                              fillColor: Colors.grey.shade200,
                              filled: true,
                              hintText: "Link",
                              prefixIcon: Icon(Icons.link)
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Material(
                        color: Colors.blue[700],
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: (){
                           uploadNotes();
                          },
                          child: Container(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20,horizontal: 120),
                                child:  Text("Add Notes" , style: TextStyle(
                                    color: Colors.white,fontWeight: FontWeight.w700,fontSize: 22
                                ),),

                              )
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
