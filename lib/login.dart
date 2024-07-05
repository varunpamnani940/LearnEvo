import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_teacher.dart';
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
        String? uri = "http://192.168.192.112/flutter/login.php";
        var res = await http.post(Uri.parse(uri), body: {
          "name": email.text,
          "pwd": password.text
        });
        var response = jsonDecode(res.body);
        print(response);
        if (response['valid']  == "true") {
          print("done");
          setState(() {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherDashboard()));
          });
        } else {
          print("some issue");
          setState(() {
            a = false;
            var alert = new AlertDialog(
              content: Text("LoginID Or Password is incorrect"),
            );
            showDialog(context: context, builder: (BuildContext context){
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
                width: 550,
                height: 300,
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
                  width: 550,
                  height: 600,
                  decoration: BoxDecoration(
                      color: Colors.blue[700]
                  ),
                ),
             ),
              Align(
                alignment: Alignment.bottomCenter,
                child:  Container(
                  width: 550,
                  height: 600,
                  decoration: BoxDecoration(
                      color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(140))
                  ),
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.only(top: 90,right: 250),
                      child: Text("",style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600
                      ),
                      ),
                      ),
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
                      SizedBox(height: 20),
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
                          Padding(padding: EdgeInsets.only(right: 50,top: 10),
                          child: Text("ForgetPassword?"),
                          )
                        ],
                      ),
                      SizedBox(height: 50),
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
                              child: Icon(Icons.login_rounded,color: Colors.white,size: 60,)
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
