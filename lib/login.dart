import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'StudentFlow/dashboard_Student.dart';
import 'dashboard_teacher.dart';
import 'package:shared_preferences/shared_preferences.dart';
class IpStorage {
  static String ipAddress = '192.168.61.228';
}
class Login extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}
class LoginState extends State<Login>{
  bool a = false;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<void> check() async{
    try {
        String? uri = "http://${IpStorage.ipAddress}/flutter/login.php";
        var res = await http.post(Uri.parse(uri), body: {
          "name": email.text,
          "pwd": password.text
        });
        var response = jsonDecode(res.body);
        print(response);
        if (response['admin'] == "true") {
          final SharedPreferences  sp = await SharedPreferences.getInstance();
          sp.setString("teacher",email.text);
          print("done");
          setState(() {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => TeacherDashboard()));
          });
        }
        else if (response['student'] == "true") {
          print("done");
          final SharedPreferences  sp = await SharedPreferences.getInstance();
          sp.setString("studentid",email.text);
          setState(() {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => StudentDashboard()));
          });
        } else {
          setState(() {
            a = false;
            var alert = new AlertDialog(
              content: Text("LoginID Or Password is incorrect"),
            );
            showDialog(context: context, builder: (BuildContext context) {
              return alert;
            });
          });
        }
      }
      catch(e){
        print(e);
      }



  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Login",
        home: Scaffold(
          body: Stack(
            children: [
              Container(
                alignment: Alignment.topCenter,
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height*0.50,
                decoration: BoxDecoration(
                 borderRadius: BorderRadius.only(bottomRight: Radius.circular(140)),
                    color: Colors.blue[700]
                ),
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    Image.asset("assets/images/login2.png",
                    width: 250,)
                  ],
                ),
              ),
             Align(
               alignment: Alignment.bottomCenter,
                child:  Container(
                  width:  MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height*0.55,
                  decoration: BoxDecoration(
                      color: Colors.blue[700]
                  ),
                ),
             ),
              Align(
                alignment: Alignment.bottomCenter,
                child:  Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height*0.55,
                  decoration: BoxDecoration(
                      color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(140))
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.sizeOf(context).height*0.04),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 50),
                      child: TextField(
                        decoration: InputDecoration(
                            enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400)),
                            fillColor: Colors.grey.shade200,
                            filled: true,
                            hintText: "Email",
                          prefixIcon: Icon(Icons.email),

                        ),
                        controller:email ,

                      ),
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height*0.03),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 50),
                        child: TextField(
                          decoration: InputDecoration(
                              enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.shade400)),
                              fillColor: Colors.grey.shade200,
                              filled: true,
                              hintText: "Password",
                              prefixIcon: Icon(Icons.password_rounded)
                          ),
                          controller: password,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(padding: EdgeInsets.only(right: 30,top: 10),
                          child: Text("ForgetPassword?"),
                          )
                        ],
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height*0.03),
                      Material(
                        color: Colors.blue[700],
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: (){
                            setState(() {
                              check();
                              if(a){

                              }
                              else
                                {
                                  final snackBar = SnackBar(
                                    content: const Text('Yay! A SnackBar!'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () {
                                        // Some code to undo the change.
                                      },
                                    ),
                                  );
                                }


                            });

                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 50 ,vertical: 10),
                              child: Icon(Icons.login_rounded,color: Colors.white,size: 40,)
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
    );
  }
}
