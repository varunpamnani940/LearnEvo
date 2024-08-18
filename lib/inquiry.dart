import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_teacher.dart';
class Inquiry extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return inquiryState();
  }
}
class inquiryState extends State<Inquiry>{
  String? SelectCourseid;
  List Coursedata = [];
  TextEditingController studname = TextEditingController();
  TextEditingController PhoneNumber = TextEditingController();
  Future<void> Uploadinquiry() async{
    String uri = "http://192.168.216.112/flutter/inquiry.php";


    var res =  await  http.post(Uri.parse(uri),body: {
      "courseid" : SelectCourseid,
      "studentName": studname.text,
      "phonenumber" : PhoneNumber.text
    });
    var r = jsonDecode(res.body);
    if(r["inserted"]=="true"){
      var alert = AlertDialog(content: Text("Inquiry Addedd"),);
      showDialog(context: context, builder: (BuildContext context){
        return alert;

      });

    }
  }
  Future<void> course() async{
    String uri = "http://192.168.216.112/flutter/viewcourse.php";

    var res =  await  http.post(Uri.parse(uri));
    var r = jsonDecode(res.body);
   setState(() {
     Coursedata = r;
     print(Coursedata);
   });

  }
  @override
  void initState() {
    super.initState();

    course();

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Inquriy",
      home: Scaffold(

        appBar: PreferredSize(

            preferredSize: Size.fromHeight(100.0), // here the desired height
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
                "Add Inquiry",
                style: TextStyle(color: Colors.white),
              ),

              // ...
            )
        ),
        body:SingleChildScrollView(
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
                    Padding(padding: EdgeInsets.symmetric(horizontal: 40),
                      child:  Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey,width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                        child: DropdownButton(
                            isExpanded: true,
                            value: SelectCourseid,
                            hint: Text("Select Course to  Add Inquiry"),
                            items: Coursedata.map((e) {
                              return DropdownMenuItem(child: Text(e['coursename']),value: e['courseid'],);
                            }).toList(),
                            onChanged: (newvalue ){
                              setState(() {
                                SelectCourseid = newvalue.toString();
                              });
                            }
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
                      child:   TextField(
                        decoration: InputDecoration(
                          enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade400)),
                          fillColor: Colors.grey.shade200,
                          filled: true,
                          hintText: "Student Name",
                          prefixIcon: Icon(Icons.subject_rounded),
                        ),
                        controller: studname,
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
                      child:   TextField(
                        decoration: InputDecoration(
                          enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade400)),
                          fillColor: Colors.grey.shade200,
                          filled: true,
                          hintText: "Phone Number",
                          prefixIcon: Icon(Icons.subject_rounded),
                        ),
                        controller: PhoneNumber,
                      ),
                    ),
                    SizedBox(height: 30,),
                    Material(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: (){
                          setState(() {
                            Uploadinquiry ();
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
        ),
      ),
    );
  }

}