import 'dart:convert';
import 'package:flutter/material.dart';
import 'AddCourse.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class AviableCourse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AviableCourseState();
  }
}

class AviableCourseState extends State<AviableCourse> {
  List CourseData = [];
  Future<void> getData() async {
    try {
      String uri = "http://$ipAddress/flutter/viewcourse.php";
      var res = await http.post(Uri.parse(uri), body: {});
      setState(() {
        CourseData = jsonDecode(res.body);
        print(CourseData);
      });
    } catch (e) {
      print(e);
    }
  }
Future<void> changestatus (a) async{
    try{
      String uri = "http://$ipAddress/flutter/deletecourse.php";
      var res = await http.post(Uri.parse(uri), body: {
        "inactive":a
      });
      print( jsonDecode(res.body));
    }catch(e){

    }
}
  @override
  void initState() {
    getData();
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
                  "Avaible Course",
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
                                builder: (context) => AddCourse()));
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
                  child: Padding(padding: EdgeInsets.all(10),
                  child: ListView.builder(
                      itemCount: CourseData.length,
                      itemBuilder: (context,index){
                    return ListTile(
                      leading: Material(
                        child: InkWell(
                          onTap: () async{

                             changestatus(CourseData[index]["courseid"]);
                             await getData();
                             setState(() {
                               getData();
                             });

                          },
                          child:  Icon(Icons.delete),
                        ),
                      ),
                      title: Text(CourseData[index]["courseid"]),
                      subtitle: Text(CourseData[index]["coursename"]),
                     trailing: c(CourseData[index]["activestatus"].toString(),index)
                    );
                  })
                    ,)
                )
              ],
            )));
  }


}
class c  extends StatefulWidget{
  String a;
  int index;

  c(this.a,this.index);

  @override
  State<StatefulWidget> createState() {
    return cs(a,index);
  }
}
class cs extends State<c>{
  String a;
  @override
  Widget build(BuildContext context) {
  if(a=="1"){
    return CircleAvatar(
      backgroundColor: Colors.green,
    );

  }
  else{
    return CircleAvatar(
      backgroundColor: Colors.red,
    );
  }
  }

  cs(this.a,int index);

}
