import 'dart:convert';
import 'package:dreamclass/admin/AddCourse.dart';
import 'package:dreamclass/admin/DeviceManager.dart';
import 'package:dreamclass/admin/EditStudent.dart';
import 'package:dreamclass/admin/addnotes.dart';
import 'package:dreamclass/admin/addstudent.dart';
import 'package:dreamclass/admin/addsubject.dart';
import 'package:dreamclass/admin/permision.dart';
import 'package:dreamclass/admin/profile.dart';
import 'package:dreamclass/admin/removestudent.dart';
import 'package:dreamclass/admin/resultUpload.dart';
import 'package:dreamclass/admin/stats.dart';
import 'package:dreamclass/admin/teacher.dart';
import 'package:dreamclass/admin/transfer.dart';
import 'package:dreamclass/admin/web_admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../login.dart';
import 'Availablestudent.dart';
import 'addExam.dart';
import 'add_admin.dart';
import 'add_faculty.dart';
import 'att.dart';
import 'edit_att.dart';
import 'fees.dart';
import 'inquiry.dart';
import '../main.dart';
import 'package:http/http.dart' as http;

class admin_dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return admin_dashboardState();
  }
}
class admin_dashboardState extends State<admin_dashboard> {
  int _current_Index = 0;
  List<Widget> bottomNavigationBarItems = [
    Home(),
    Fees(),
    Categories(),
  ];
  bool isWeb = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => checkPlatform());
  }
  String? formattedEmail;
  String teacherEmail = "";


  void checkPlatform() {
    setState(() {
      isWeb = MediaQuery.of(context).size.width > 600;
    });
  }
  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 600;
    if (isLargeScreen) {
      return AdminDashboardWeb();
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dashboard",
      home: Scaffold(
        drawer:Drawer(
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
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[300], // Placeholder background color
                      child: ClipOval(
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/images/loading_2.gif', // Local loading animation
                          image: "http://$ipAddress/flutter/admin_image/$formattedEmail.jpg",
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, size: 40, color: Colors.grey); // Default icon on error
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 15),

                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.admin_panel_settings, color: Colors.white),
                title: const Text("Add Admin",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Close the drawer
                  Navigator.push(context,MaterialPageRoute(builder: (context)=> InsertUserPage()));
                  // Navigate to a screen related to Option 1 if needed
                },
              ),

              // Profile Option
              ListTile(
                leading: Icon(Icons.account_circle_rounded, color: Colors.white),
                title: Text("Profile", style: TextStyle(color: Colors.white, fontSize: 16)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                },
              ),

              Divider(color: Colors.white54, thickness: 1, indent: 15, endIndent: 15),

              // Logout Option
              ListTile(
                leading: Icon(Icons.logout_outlined, color: Colors.white),
                title: Text("Logout", style: TextStyle(color: Colors.white, fontSize: 16)),
                onTap: () async {
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.remove("teacher");
                  prefs.remove("emailt");
                  prefs.remove("email");
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>MyApp()));
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

              padding: EdgeInsets.only(left: MediaQuery.sizeOf(context).width*0.1),
              child:const Text("LearnEvo Central", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 25)),
            ),
          )
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width,
                height:  MediaQuery.sizeOf(context).height*0.30,
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(100)),
                    color: Colors.blue[700]),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  decoration: BoxDecoration(color: Colors.blue[700]),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    width:  MediaQuery.sizeOf(context).width,
                    height:  MediaQuery.sizeOf(context).height*0.78,
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

  @override
  Widget build(BuildContext context) {
    return ListView(

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
                      DashboardButton(label: "Inquiry", imagePath: "assets/images/inquiry.png", destination: Inquiry()),
                      DashboardButton(label: "Add Student", imagePath: "assets/images/adduser.png", destination: AddStudent()),
                      DashboardButton(label: "Remove Student", imagePath: "assets/images/delete2.png", destination: Removestudent()),
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
                    DashboardButton(label: "  Add Teacher", imagePath: "assets/images/teacher.jpg", destination: Addfac()),
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
                    itemCount: 9, // Total items
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
                        DashboardButton(
                          label: "Students",
                          imagePath: "assets/images/report.png",
                          destination: Availablestudent(),
                        ),
                        DashboardButton(
                          label: "Device Management",
                          imagePath: "assets/images/device1.png",
                          destination: DeviceManager(),
                        ),
                        DashboardButton(
                          label: " Transfer",
                          imagePath: "assets/images/transfer.png",
                          destination: Transfer(),
                        ),
                        DashboardButton(
                          label: "Manage teacher Permisions",
                          imagePath: "assets/images/teacher.jpg",
                          destination: TeacherListPage(),
                        ),
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
        padding: const EdgeInsets.all(11.0),
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
