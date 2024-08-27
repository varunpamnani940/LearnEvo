import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'dashboard_teacher.dart';

class DeviceManager extends StatefulWidget {
  const DeviceManager({super.key});

  @override
  State<DeviceManager> createState() => _DeviceManagerState();
}

class _DeviceManagerState extends State<DeviceManager> {
  List collagedata=[];
  String? SelectedCollage;
  Future<void> getcourse() async {
    String uri = "http://localhost/flutter/viewcourse.php";
    var res = await http.post(Uri.parse(uri), body: {});

  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Device Manager",
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(150.0),
          child: AppBar(
            title: Text(
              "Device Manager",
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
                height: 800,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(80),
                        topRight: Radius.circular(80))
                ),
                child:Column(
                    children: [

                          Container(
                            width: 250.0,
                            child: TextField(
                              decoration: InputDecoration(labelText: 'Device Token'),
                            ),
                          ),

                          SizedBox(width: 55,),
                          Padding(padding: EdgeInsets.all(50),
                            child:
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [

                                    Container(
                                      width: 150.0,
                                      child: DropdownButton(

                                        value: SelectedCollage,

                                        hint: Text("Select Collage",
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
                                  ],),
                              ],),
                          ),
                          SizedBox(height: 0.1,),
                          Padding(padding: EdgeInsets.all(5),
                            child:
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [

                                    Container(
                                      width: 150.0,
                                      child: DropdownButton(

                                        value: SelectedCollage,

                                        hint: Text("Select Collage",),
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
                                  ],),
                              ],),
                          ),
                  // SizedBox(height: 20,),
                  Material(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: (){

                      },
                      child: Container(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 15,horizontal: 80),
                            child:  Text("Submit" , style: TextStyle(
                                color: Colors.white,fontWeight: FontWeight.w700,fontSize: 18
                            ),),

                          )
                      ),
                    ),
                  ),
                 ],
                  ),
                ),

              ],
          ),
        ),
      ),
    );
  }
}