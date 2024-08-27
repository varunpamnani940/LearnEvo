import 'package:flutter/material.dart';


class attendene extends StatefulWidget {

  @override
  State<attendene> createState() => attendene_state();
}

class attendene_state extends State<attendene> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Attendence",
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(150.0),
          child: AppBar(
            title: Text(
              "Attendence",
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
                child: ListView(children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: ListTile(
                      title: Text('subject name'),
                      subtitle: Text("batch"),
                      trailing: CircleAvatar(
                        backgroundColor: Colors.greenAccent,
                      ),
                      leading:Material(color: Colors.grey[200],
                        child: InkWell(
                          child: Column(
                            children: [
                              Text("Month"),
                              Column(children: [Text("1")],)

                            ],
                          ),
                        ),
                      ) ,

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
