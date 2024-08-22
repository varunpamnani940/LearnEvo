import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'StudentFlow/dashboard_Student.dart';
import 'dashboard_teacher.dart';
import 'package:shared_preferences/shared_preferences.dart';
String ipAddress = '192.168.66.112';
class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}
class LoginState extends State<Login> {
  bool a = false;
  bool _isLoading = false; // Loading state variable
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<void> check() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show the loader
      });

      try {
        String? uri = "http://$ipAddress/flutter/login.php";
        var res = await http.post(Uri.parse(uri), body: {
          "name": email.text,
          "pwd": password.text,
        });
        var response = jsonDecode(res.body);
        print(response);

        if (response['admin'] == "true") {
          final SharedPreferences sp = await SharedPreferences.getInstance();
          sp.setString("teacher", email.text);
          print("done");
          setState(() {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => TeacherDashboard()));
          });
        } else if (response['student'] == "true") {
          print("done");
          final SharedPreferences sp = await SharedPreferences.getInstance();
          sp.setString("email", email.text);
          getstudentid();
          setState(() {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => StudentDashboard()));
          });
        } else {
          setState(() {
            a = false;
            var alert = AlertDialog(
              content: Text("LoginID Or Password is incorrect"),
            );
            showDialog(context: context, builder: (BuildContext context) {
              return alert;
            });
          });
        }
      } catch (e) {
        print(e);
      } finally {
        setState(() {
          _isLoading = false; // Hide the loader
        });
      }
    }
  }
  Future<void> getstudentid() async{
    String uri = "http://$ipAddress/flutter/StudentFlowapis/getstudentid.php";
    final SharedPreferences sp = await SharedPreferences.getInstance();

    var res = await http.post(Uri.parse(uri),body: {
      "studentemail":sp.getString("email")
    });
    setState(() {
      sp.setString("studentid", res.body);
    });
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
              height: MediaQuery.sizeOf(context).height * 0.50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(140)),
                  color: Colors.blue[700]),
              child: Column(
                children: [
                  SizedBox(height: 40),
                  Image.asset(
                    "assets/images/login2.png",
                    width: 250,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height * 0.55,
                decoration: BoxDecoration(color: Colors.blue[700]),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height * 0.55,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(140))),
                child: Form(
                  key: _formKey, // Assign the form key
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.04),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        child: TextFormField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400)),
                            fillColor: Colors.grey.shade200,
                            filled: true,
                            hintText: "Email",
                            prefixIcon: Icon(Icons.email),
                          ),
                          controller: email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        child: TextFormField(
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.shade400)),
                              fillColor: Colors.grey.shade200,
                              filled: true,
                              hintText: "Password",
                              prefixIcon: Icon(Icons.password_rounded)),
                          controller: password,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 30, top: 10),
                            child: Text("ForgetPassword?"),
                          )
                        ],
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
                      Material(
                        color: Colors.blue[700],
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: _isLoading
                              ? null
                              : () {
                            check(); // Call API on button tap
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                                  : Icon(
                                Icons.login_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
