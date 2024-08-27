import 'package:flutter/material.dart';

class profile extends StatefulWidget {

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Fee's Details",
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: AppBar(
            title: Text(
              "Fee's Details",
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
                padding: EdgeInsets.all(10),
                child: Column(children: [
                  SizedBox(height: 20,),
                  TextField(
                    decoration: InputDecoration(
                        labelText: 'Name',
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    decoration: I,
                  )
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