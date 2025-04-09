import 'dart:async';
import 'dart:convert';

import 'package:dreamclass/admin/AddCourse.dart';
import 'package:dreamclass/admin/per_noti.dart';
import 'package:dreamclass/admin/profile_teacher.dart';
import 'package:dreamclass/admin/removestudent.dart';
import 'package:dreamclass/admin/transfer.dart';
import 'package:dreamclass/admin/web_admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'Availablestudent.dart';
import 'DeviceManager.dart';
import 'addExam.dart';
import 'add_admin.dart';
import 'add_faculty.dart';
import 'addnotes.dart';
import 'addstudent.dart';
import 'addsubject.dart';
import 'att.dart';
import 'edit_att.dart';
import 'fees.dart';
import 'inquiry.dart';
import 'meeting.dart';
import 'resultUpload.dart';
import 'teacher.dart';
import '../login.dart';

import '../main.dart';
import 'package:http/http.dart' as http;
var data ;
List p = [];
class TeacherDashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TeacherDashboardState();
  }
}
bool isLoading_s = true;
class TeacherDashboardState extends State<TeacherDashboard> {

  Future<void> per()async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String uri = "http://51.20.10.147//flutter/get_teacher_p.php";
    var res = await http.post(Uri.parse(uri),body: {
      "email":sp.getString("emailt").toString()
    });
    print(res.body);
   setState(() {
     isLoading_s = false;
     data = jsonDecode(res.body);
     p = [
       data["student_manage_p"].toString(),
       data["fee_manage_p"].toString() ,
       data["faculty_manage_p"].toString(),
     ];


     print("Data List: $data");
     print("Permissions List: $p[0]");
     print("Permissions List: $p[1]");
     print("Permissions List: $p[2]");


   });
  }
  int _current_Index = 0;
  List<Widget> bottomNavigationBarItems = [
    Home(),
    (p.isNotEmpty && p[1] == '1')
        ? Fees() // If permission for fee is granted, show Fees
        : PermissionDeniedPage(),
    Categories(),
  ];
  bool isWeb = false;

  @override
  void initState() {
    super.initState();
    loadTeacherData();
      per();
    WidgetsBinding.instance.addPostFrameCallback((_) => checkPlatform());
  }

  String? formattedEmail;
  String teacherEmail = "";

  Future<void> loadTeacherData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      teacherEmail = prefs.getString('teacher') ?? "No Email Found";
      if (teacherEmail.endsWith("@gmail.com")) {
        formattedEmail =
            teacherEmail.replaceAll("@gmail.com", "gmail").replaceAll('.', '_');
        String imageUrl = "http://13.60.85.45/flutter/admin_image/$formattedEmail.jpg";
        print(imageUrl);
      } else {
        print("Not a Gmail user, skipping...");
      }
    });
  }

  void checkPlatform() {
    setState(() {
      isWeb = MediaQuery
          .of(context)
          .size
          .width > 600;
    });
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dashboard",
      home: Scaffold(
        drawer: Drawer(
          backgroundColor: Colors.blue[700],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Drawer Header with Profile Info
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue[800]),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // CircleAvatar(
                    //   radius: 25,
                    //   backgroundColor: Colors.grey[300],
                    //   // Placeholder background color
                    //   child: ClipOval(
                    //     child: FadeInImage.assetNetwork(
                    //       placeholder: 'assets/images/loading_2.gif',
                    //       // Local loading animation
                    //       image: "http://$ipAddress/flutter/admin_image/$formattedEmail.jpg",
                    //       fit: BoxFit.cover,
                    //       width: 50,
                    //       height: 50,
                    //       imageErrorBuilder: (context, error, stackTrace) {
                    //         return Icon(Icons.person, size: 40,
                    //             color: Colors.grey); // Default icon on error
                    //       },
                    //     ),
                    //   ),
                    // ),
                    SizedBox(width: 15),

                  ],
                ),
              ),


              // Profile Option
              ListTile(
                leading: Icon(
                    Icons.account_circle_rounded, color: Colors.white),
                title: Text("Profile",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TeacherProfilePage()));
                },
              ),

              Divider(color: Colors.white54,
                  thickness: 1,
                  indent: 15,
                  endIndent: 15),

              // Logout Option
              ListTile(
                leading: Icon(Icons.logout_outlined, color: Colors.white),
                title: Text("Logout",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                onTap: () async {
                  final SharedPreferences prefs = await SharedPreferences
                      .getInstance();
                  prefs.remove("teacher");
                  prefs.remove("emailt");
                  prefs.remove("email");

                  Navigator.push(context, MaterialPageRoute(
                      builder: (BuildContext context) => MyApp()));
                },
              ),
            ],
          ),
        ),


        appBar: AppBar(
            backgroundColor: Colors.blue[700],
            leading: Builder(
              builder: (context) {
                return IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: Icon(
                      Icons.dehaze_outlined,
                      color: Colors.white,
                      size: 40,
                    ));
              },
            ),
            title: Container(
              child: Padding(

                padding: EdgeInsets.only(left: MediaQuery
                    .sizeOf(context)
                    .width * 0.1),
                child: const Text("LearnEvo Central", style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25)),
              ),
            )
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                width: MediaQuery
                    .sizeOf(context)
                    .width,
                height: MediaQuery
                    .sizeOf(context)
                    .height * 0.30,
                decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(100)),
                    color: Colors.blue[700]),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery
                      .sizeOf(context)
                      .width,
                  height: MediaQuery
                      .sizeOf(context)
                      .height,
                  decoration: BoxDecoration(color: Colors.blue[700]),
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      width: MediaQuery
                          .sizeOf(context)
                          .width,
                      height: MediaQuery
                          .sizeOf(context)
                          .height * 0.78,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(100),
                            topRight: Radius.circular(100)),
                      ),
                      child: Container(
                        child: bottomNavigationBarItems[_current_Index],
                      )

                  )),

            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _current_Index,
          onTap: (int? newIndex) {
            setState(() {
              _current_Index = newIndex!;
            });
          },
          items: [
            BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
            BottomNavigationBarItem(
                label: "fee's", icon: Icon(Icons.monetization_on_outlined)),
            BottomNavigationBarItem(
                label: "Categories", icon: Icon(Icons.dashboard)),
          ],
        ),
      ),
    );
  }
}
class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}
class HomeState extends State<Home> {
  Future<void> per()async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String uri = "http://51.20.10.147//flutter/get_teacher_p.php";
    var res = await http.post(Uri.parse(uri),body: {
      "email":sp.getString("email").toString()
    });
    print(res.body);
    setState(() {
      isLoading_s = false;
      data = jsonDecode(res.body);
      p = [
        data["student_manage_p"].toString(),
        data["fee_manage_p"].toString() ,
        data["faculty_manage_p"].toString(),
      ];


      print("Data List: $data");
      print("Permissions List: $p[0]");
      print("Permissions List: $p[1]");
      print("Permissions List: $p[2]");


    });
  }

  @override
  void initState() {
    super.initState();
    per();
  }
  @override
  Widget build(BuildContext context) {
       return isLoading_s
        ? Center(child: CircularProgressIndicator()):ListView(

        children:[ Column(
          children: [
            SizedBox(height: 45,),
            Container(
              height: MediaQuery.sizeOf(context).height*0.390,
              child: AdminStats(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                (p.isNotEmpty && p[0] == '1') // Check if p is not empty before accessing index 0
                    ? DashboardButton(label: "Add Student", imagePath: "assets/images/adduser.png", destination: AddStudent())
                    :  DashboardButton(label: "Add Student", imagePath: "assets/images/adduser.png", destination: PermissionDeniedPage()),
                DashboardButton(label: "Inquiry", imagePath: "assets/images/inquiry.png", destination: Inquiry()),
                (p.isNotEmpty && p[0] == '1') // Check if p is not empty before accessing index 0
                    ?  DashboardButton(label: "Remove Student", imagePath: "assets/images/delete2.png", destination: Removestudent())
                    :   DashboardButton(label: "Remove Student", imagePath: "assets/images/delete2.png", destination: PermissionDeniedPage()),

              ],
            ),
            SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ImageButtonHomeNotes(),
                // ImageButtonHomeAdd(),
                DashboardButton(label: "Upload Notes", imagePath: "assets/images/notes.png", destination: AddNotes()),
                DashboardButton(label: "Manage Courses", imagePath: "assets/images/add.png", destination: AddCourse()),
                // ImageButtonTeacher(),
                (p.isNotEmpty && p[2] == '1') // Check if p is not empty before accessing index 0
                    ? DashboardButton(label: "  Add Teacher", imagePath: "assets/images/teacher.jpg", destination: Addfac())
                    :  DashboardButton(label: "Add Teacher", imagePath: "assets/images/teacher.jpg", destination: PermissionDeniedPage()) ,

              ],
            ),

          ],

        ),

        ]
    );
  }
}

class Categories extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CategoriesState();
  }
}

class CategoriesState extends State<Categories> {
  Future<void> per()async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String uri = "http://51.20.10.147//flutter/get_teacher_p.php";
    var res = await http.post(Uri.parse(uri),body: {
      "email":sp.getString("email").toString()
    });
    print(res.body);
    setState(() {
      isLoading_s = false;
      data = jsonDecode(res.body);
      p = [
        data["student_manage_p"].toString(),
        data["fee_manage_p"].toString() ,
        data["faculty_manage_p"].toString(),
      ];


      print("Data List: $data");
      print("Permissions List: $p[0]");
      print("Permissions List: $p[1]");
      print("Permissions List: $p[2]");


    });
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background Sloped Blue Container
          Container(
            height: screenHeight * 0.02, // Covers top 40% of the screen
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),

          // Scrollable Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Side margins
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.01), // Space for sloped background
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: screenWidth > 600 ? 3 : 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1,
                    ),
                    itemCount: 10, // Total items
                    itemBuilder: (context, index) {
                      List<Widget> buttons = [
                        DashboardButton(
                          label: "Add Subject",
                          imagePath: "assets/images/addsub.png",
                          destination: AddSubject(),
                        ),
                        DashboardButton(
                          label: "Results",
                          imagePath: "assets/images/result.png",
                          destination: ResponsivePage(),
                        ),
                        DashboardButton(
                          label: "Attendance",
                          imagePath: "assets/images/att.png",
                          destination: att(),
                        ),

                        (p.isNotEmpty && p[0] == '1') // Check if p is not empty before accessing index 0
                            ?   DashboardButton(
                      label: "Students",
                      imagePath: "assets/images/report.png",
                      destination: Availablestudent(),
                      ) :  DashboardButton(label: "Students", imagePath: "assets/images/report.png", destination: PermissionDeniedPage()) ,

                        DashboardButton(
                          label: "Device Management",
                          imagePath: "assets/images/device1.png",
                          destination: DeviceManager(),
                        ),
                        (p.isNotEmpty && p[0] == '1') // Check if p is not empty before accessing index 0
                            ?  DashboardButton(
                      label: " Transfer",
                      imagePath: "assets/images/transfer.png",
                      destination: Transfer(),
                      )
                         :  DashboardButton(label: "Transfer", imagePath: "assets/images/transfer.png", destination: PermissionDeniedPage()) ,


                        (p.isNotEmpty && p[2] == '1') // Check if p is not empty before accessing index 0
                            ? DashboardButton(
                      label: "Manage teacher Permisions",
                      imagePath: "assets/images/teacher.jpg",
                      destination: TeacherListPage(),
                      ) :  DashboardButton(label: "Manage teacher Permisions", imagePath: "assets/images/teacher.jpg", destination: PermissionDeniedPage()) ,


                        DashboardButton(
                          label: "Add Exam",
                          imagePath: "assets/images/exam.png",
                          destination: AddExam(),
                        ),
                        DashboardButton(
                          label: "Edit Attendence",
                          imagePath: "assets/images/att.png",
                          destination: EditAttendance(),
                        ),
                        DashboardButton(
                          label: "Meetings",
                          imagePath: "assets/images/meeting.png",
                          destination: MeetingPage(),
                        ),
                      ];
                      return buttons[index];
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminStats extends StatefulWidget {
  @override
  State<AdminStats> createState() => _AdminStatsState();
}

class _AdminStatsState extends State<AdminStats> {

  var Count_student,Count_teacher,Count_c,Count_i;
  bool isLoading = true;
  stats() async{
    setState(() {
      isLoading = true;
    });
    var student_count = "http://$ipAddress//flutter/count_students.php";
    var counts = await  http.post(Uri.parse(student_count));

    var teacher_count = "http://$ipAddress//flutter/count_f.php";
    var countt = await  http.post(Uri.parse(teacher_count));

    var course_count = "http://$ipAddress//flutter/count_course.php";
    var countc = await  http.post(Uri.parse(course_count));

    var inquiry_count = "http://$ipAddress//flutter/count_inquiry.php";
    var counti = await  http.post(Uri.parse(inquiry_count));

    setState(() {
      Count_c =  jsonDecode(countc.body);
      Count_teacher =  jsonDecode(countt.body);
      Count_student =  jsonDecode(counts.body);
      Count_i =  jsonDecode(counti.body);
      isLoading = false;
    });
  }

  @override
  void initState() {
    stats();
    super.initState();
  }
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator()):
    Container(
      padding: EdgeInsets.all(12),
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height*0.10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header Title/ Stats Grid
          GridView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 cards per row
              crossAxisSpacing: 10,
              mainAxisSpacing: 25,
              childAspectRatio: 2.4, // Card size ratio
            ),
            children: [
              _buildStatCard(
                title: "Total Students",
                value: Count_student.toString(),
                color: Colors.blue,
                icon: Icons.people_alt,
              ),
              _buildStatCard(
                title: "Teachers",
                value: Count_teacher.toString(),
                color: Colors.green,
                icon: Icons.person,
              ),
              _buildStatCard(
                title: "Courses",
                value: Count_c.toString(),
                color: Colors.orange,
                icon: Icons.menu_book,
              ),
              _buildStatCard(
                title: "Fees Pending",
                value: "90%",
                color: Colors.red,
                icon: Icons.currency_rupee,
              ),
              _buildStatCard(
                title: "Fees Recevied",
                value: "10%",
                color: Colors.indigoAccent,
                icon: Icons.currency_rupee,
              ),
              _buildStatCard(
                title: "Inquiry",
                value: Count_i.toString(),
                color: Colors.black,
                icon: Icons.person,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 0,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon Section
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 20,
              child: Icon(
                icon,
                size: 50,
                color: color,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Stat Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // Stat Value
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class DashboardButton extends StatelessWidget {
  final String label;
  final String imagePath;
  final Widget destination;

  DashboardButton({required this.label, required this.imagePath, required this.destination});

  @override
  Widget build(BuildContext context) {
    double avatarSize = MediaQuery.of(context).size.width * 0.150;
    double imageSize = avatarSize * 3;

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      },
      borderRadius: BorderRadius.circular(1),
      child: Column(
        children: [
          CircleAvatar(
            radius: avatarSize,
            backgroundColor: Colors.blue[100],
            child: Image.asset(
              imagePath,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.contain,
            ),
          ),

          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
