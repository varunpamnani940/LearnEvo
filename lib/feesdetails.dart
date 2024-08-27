import 'package:dreamclass/feesstudent.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class feesdetail extends StatefulWidget {

  @override
  State<feesdetail> createState() => _feesdetailsState();
}

class _feesdetailsState extends State<feesdetail> {
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
                  onTap: () async{
                    final SharedPreferences sp = await SharedPreferences.getInstance();
                    Navigator.pop(context, MaterialPageRoute(builder: (BuildContext context)=> feesstud( sp.getString("coursename")) ));
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
                        labelText: 'Search',
                        suffixIcon: Icon(Icons.search)
                    ),
                  ),
                  SizedBox(height: 20,
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(10),
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            onTap: () {

                            },
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ("CourseName"),

                                ),
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    Text("Total Fee's: "),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Paid Fee's: "),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Unpaid Fee's: "),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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