import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'StudentFlow/dashboard_Student.dart';
import 'dashboard_teacher.dart';
import 'package:shared_preferences/shared_preferences.dart';

String ipAddress = '192.168.11.165';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<Login> {
  bool _isLoading = false; // Loading state variable
  bool _isSendingOtp = false;
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<void> check() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show the loader
      });

      try {
        String uri = "http://$ipAddress/flutter/login.php";
        var res = await http.post(Uri.parse(uri), body: {
          "name": email.text,
          "pwd": password.text,
        });
        var response = jsonDecode(res.body);
        print(response);

        if (response['admin'] == "true") {
          final SharedPreferences sp = await SharedPreferences.getInstance();
          sp.setString("teacher", email.text);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => TeacherDashboard()));
        }
        else if (response['status'] == "success"){
          _OtpVerficationDialog(response);
        }
        else if (response['student'] == "true") {
          final SharedPreferences sp = await SharedPreferences.getInstance();
          sp.setString("email", email.text);
          getstudentid();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => StudentDashboard()));
        } else {
          _showErrorDialog("Login ID or Password is incorrect");
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
  late var otp_ ;
  late var Otp ;
  Future<Map<String, dynamic>>  otp(String email) async {
    String uri = "http://$ipAddress/flutter/passwordreset.php";
    var res = await http.post(Uri.parse(uri), body: {
      "email": email
    });
    otp_ = jsonDecode(res.body);
    Otp = otp_["otp"];
    print(Otp);
  return jsonDecode(res.body); // Return the response for verification
  }


  Future<void> getstudentid() async {
    String uri = "http://$ipAddress/flutter/StudentFlowapis/getstudentid.php";
    final SharedPreferences sp = await SharedPreferences.getInstance();

    var res = await http.post(Uri.parse(uri), body: {
      "studentemail": sp.getString("email")
    });
    setState(() {
      sp.setString("studentid", res.body);
    });
  }

  Future<void> pass(String  pwd,String email) async
  {
    String uri="http://$ipAddress/flutter/Update_password.php";
    var res= await http.post(Uri.parse(uri),
        body: {
          "password": pwd,
          "email":email
        }
    );
    print(jsonDecode(res.body));
    var response = jsonDecode(res.body);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController emailController = TextEditingController();

        return AlertDialog(
          title: Text("Forgot Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Please enter your email address to reset your password."),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              if (_isSendingOtp) // Show progress indicator if sending OTP
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String email = emailController.text.trim();
                if (email.isNotEmpty) {
                  setState(() {
                    _isSendingOtp = true; // Start loading
                  });
                  var response = await otp(email); // Await OTP sending
                  setState(() {
                    _isSendingOtp = false; // Stop loading
                  });
                  if (response['status'] == "success") {
                    Navigator.of(context).pop(); // Close the email input dialog
                    _showOtpDialog(email); // Show OTP dialog
                  } else {
                    _showErrorDialog("Failed to send OTP. Please try again.");
                  }
                } else {
                  _showErrorDialog("Please enter a valid email address");
                }
              },
              child: Text("Send Reset Link"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
  void _OtpVerficationDialog(var res) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController emailController = TextEditingController();

        return AlertDialog(
          title: Text("Dual Factor Authentication OTP"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter Your OTP."),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "OTP",
                  border: OutlineInputBorder(),
                ),
              ),
              if (_isSendingOtp) // Show progress indicator if sending OTP
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                  print(res["otp"]);
                  if (res['otp'].toString() == emailController.text) {
                    final SharedPreferences sp = await SharedPreferences.getInstance();
                    sp.setString("teacher", email.text);
                    print(sp.getString("teacher"));
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => TeacherDashboard()));
                  }
              },
              child: Text("Check OTP"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }


  void _showOtpDialog(String email) {
    TextEditingController otpController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    bool _isVerifyingOtp = false; // State for verifying OTP

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter OTP and New Password"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Please enter the OTP sent to $email."),
                SizedBox(height: 10),
                TextField(
                  controller: otpController,
                  decoration: InputDecoration(
                    hintText: "OTP",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    hintText: "New Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    hintText: "Confirm Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                if (_isVerifyingOtp) // Show progress indicator if verifying OTP
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String otp = otpController.text.trim();
                String newPassword = newPasswordController.text.trim();
                String confirmPassword = confirmPasswordController.text.trim();

                if (otp.isNotEmpty && newPassword.isNotEmpty && confirmPassword.isNotEmpty) {
                  if (newPassword == confirmPassword) {
                    setState(() {
                      _isVerifyingOtp = true; // Start loading for verification
                    });

                    // Here, you should call an API to verify the OTP
                    // For now, let's simulate it:
                    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
                    print(Otp);
                    print(otp);
                    // Simulated OTP verification logic
                    if (otp == Otp.toString()) { // Replace with actual OTP verification
                      // Call API to reset password here if needed


                       await pass( newPassword,email);
                       _showSuccessDialog("Password reset successfully!");
                       // Close the OTP dialog
                    } else {
                      _showErrorDialog("Invalid OTP!");
                    }

                    setState(() {
                      _isVerifyingOtp = false; // Stop loading
                    });
                  } else {
                    _showErrorDialog("Passwords do not match!");
                  }
                } else {
                  _showErrorDialog("Please fill in all fields!");
                }
              },
              child: Text("Reset Password"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
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
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(140)),
                color: Colors.blue[700],
              ),
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
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.55,
                decoration: BoxDecoration(color: Colors.blue[700]),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(140)),
                ),
                child: Form(
                  key: _formKey, // Assign the form key
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.04),
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
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                            prefixIcon: Icon(Icons.password_rounded),
                          ),
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
                            child: GestureDetector(
                              onTap: _showForgotPasswordDialog, // Call the dialog on tap
                              child: Text(
                                "Forget Password?",
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      Material(
                        color: Colors.blue[700],
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: _isLoading ? null : check, // Call API on button tap
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