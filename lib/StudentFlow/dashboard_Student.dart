import 'package:dreamclass/StudentFlow/studentfees.dart';
import 'package:dreamclass/StudentFlow/studentprofile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../Availablestudent.dart';
import '../login.dart';
import '../main.dart';
import 'atten.dart';
import 'coursedetails.dart';


String? studid ;
class StudentDashboard extends StatefulWidget {

  @override

  State<StatefulWidget> createState() {
    return StudentDashboardState();
  }

}

class StudentDashboardState extends State<StudentDashboard> {
  int _current_Index = 0;
  List<Widget> bottomNavigationBarItems = [
    Home(),
    studentfees(),
  ];
  @override

  @override
  void initState() {
    super.initState();

    // super.initState();
  }
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Student Dashboard",
      home: Scaffold(
        drawer: Drawer(
          backgroundColor: Colors.blue[700],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Container(
                      child: Column(
                        children: [

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                radius: 60,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )),
              ListTile(
                leading: Icon(
                  Icons.account_circle_rounded,
                  color: Colors.white,
                ),
                title: const Text(
                  'Profile',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                   Navigator.push(context,MaterialPageRoute(builder: (context)=> ProfilePage())); // Close the drawer
                  // Navigate to a screen related to Option 1 if needed
                },
              ),
              ListTile(
                leading: Icon(Icons.time_to_leave_rounded, color: Colors.white),
                title: const Text("Leave Application",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Navigate to a screen related to Option 1 if needed
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                title: const Text("Logout",
                    style: TextStyle(color: Colors.white)),
                onTap: ()  async {
                  final  SharedPreferences Logut =  await SharedPreferences.getInstance();
                  Logut.remove("studentid");
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
                    size: 30,
                  ));
            },
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [

              Container(
                width: 500,
                height: 100,
                decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(100)),
                    color: Colors.blue[700]),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 500,
                  height: 700,
                  decoration: BoxDecoration(color: Colors.blue[700]),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    width: 500,
                    height: 700,
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

  final _controller = PageController();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          child: Container(
            child: Column(
              children: [
                SizedBox(height: 30,),
                Text(
                  "“Memory is the treasury and guardian of all things.”",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10),
                Container(
                  height: 200,
                  width: 500,
                  child: PageView(
                    controller: _controller,
                    children: [
                     Expanded(child:  ImageCard("assets/images/1.jpg"),),
                     Expanded(child:  ImageCard("assets/images/2.jpg"),),
                     Expanded(child:  ImageCard("assets/images/3.jpg"),),
                     Expanded(child:  ImageCard("assets/images/4.jpg"),),
                     Expanded(child:  ImageCard("assets/images/5.jpg"),),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 5,
                  effect: ExpandingDotsEffect(),
                ),
                SizedBox(height: 40),
                Row(
                  children: [
                    ImageButtonCourseDetails(),
                    ImageButtonAttendence(),
                    ImageButtonLeave(),
                  ],
                ),
                SizedBox(height: 40),
                Row(
                  children: [
                    ImageButtonHomeNotes(),
                    ImageButtonHomeAdd(),
                    ImageButtonHomePerfomance(),
                  ],
                ),
              ],

            ),
          )
      ),
    );
  }


}

class ImageCard extends StatefulWidget {
  String  imagelink1 = "";
   ImageCard(String imagelink){
     imagelink1  = imagelink;
   }

  @override
  State<StatefulWidget> createState() {
    return ImageCardState(imagelink1);
  }
}

class ImageCardState extends State<ImageCard> {
  String image = "";
  ImageCardState(String imagelink){
    image = imagelink;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        width: 500,
        height: 200,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover),
        ),

         // child: Image.asset(image,height: 220,),

        ),

    );
  }
}
class ImageButtonCourseDetails extends StatefulWidget{


  @override
  State<StatefulWidget> createState() {
    return ImageButtonCourseDetailsState();
  }


}
class ImageButtonCourseDetailsState extends State<ImageButtonCourseDetails>{

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
          child: InkWell(
            onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context)=> Coursedetail()));
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(
                    child: Image.asset("assets/images/ava.png"),
                    radius: 55,
                  ),
                ),
                Text(
                  "Course Details",
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 17),
                )
              ],
            ),
          ),
        )
    );
  }


}
class ImageButtonAttendence extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ImageButtonAttendenceState();
  }
}
class ImageButtonAttendenceState extends State<ImageButtonAttendence>{
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
          child: InkWell(
            onTap: () {
             Navigator.push(context, MaterialPageRoute(builder: (context)=>atten()));
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(
                    backgroundColor: Colors.pink,
                    child: Image.asset("assets/images/att.png"),
                    radius: 55,
                  ),
                ),
                Text(
                  "Attendence",
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 17),
                )
              ],
            ),
          ),
        )
    );
  }

}
class ImageButtonLeave extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ImageButtonLeaveState();
  }
}
class ImageButtonLeaveState extends State<ImageButtonLeave>{
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
          child: InkWell(
            onTap: () {},
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(
                    child: Image.asset("assets/images/leave.png"),
                    radius: 55,
                  ),
                ),
                Text(
                  "Leave Application",
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 17),
                )
              ],
            ),
          ),
        )
    );
  }

}
class ImageButtonHomeNotes extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ImageButtonHomeNotesState();
  }
}
class ImageButtonHomeNotesState extends State<ImageButtonHomeNotes>{
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
          child: InkWell(
            onTap: () {
            //  Navigator.push(context, MaterialPageRoute(builder: (context)=>AddNotes()));
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(

                    child: Image.asset("assets/images/notes.png"),
                    radius: 55,
                  ),
                ),
                Text(
                  "Note's",
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 17),
                )
              ],
            ),
          ),
        )
    );
  }
}
class ImageButtonHomeAdd extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ImageButtonHomeAddState();
  }
}
class ImageButtonHomeAddState extends State<ImageButtonHomeAdd>{
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
          child: InkWell(
            onTap: () {
             // Navigator.push(context, MaterialPageRoute(builder: (context)=>AddCourse()));
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(

                    child: Image.asset("assets/images/question.png"),
                    radius: 55,
                  ),
                ),
                Text(
                  "Question Paper",
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 17),
                )
              ],
            ),
          ),
        )
    );
  }
}
class ImageButtonHomePerfomance extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ImageButtonHomePerformanceState();
  }
}
class ImageButtonHomePerformanceState extends State<ImageButtonHomePerfomance>{
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
          child: InkWell(
            onTap: () {},
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(

                    child: Image.asset("assets/images/report.png"),
                    radius: 55,
                  ),
                ),
                Text(
                  "Student Report",
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 17),
                )
              ],
            ),
          ),
        )
    );
  }
}
class ImageButtonAddsubject extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ImageButtonAddsubjectstate();
  }
}
class ImageButtonAddsubjectstate extends State<ImageButtonAddsubject>{
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
          child: InkWell(
            onTap: () {
            //  Navigator.push(context, MaterialPageRoute(builder: (context)=> Addsubject()));
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(

                    child: Image.asset("assets/images/addsub.png"),
                    radius: 55,
                  ),
                ),
                Text(
                  "Add Subject",
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 17),
                )
              ],
            ),
          ),
        )
    );
  }
}
class Categories extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return CategoriesState();
  }
}
class CategoriesState extends State<Categories>{
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10,),
              Row(

                children: [
                  ImageButtonAddsubject(),
                  ImageButtonResult(),
                  ImageButtonHomePerfomance(),
                ],
              )

            ],
          ),
        )

    );
  }
}
class ImageButtonResult extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ImageButtonResultstate();
  }
}
class ImageButtonResultstate extends State<ImageButtonResult>{
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
          child: InkWell(
            onTap: () {
            //  Navigator.push(context, MaterialPageRoute(builder: (context)=> Addsubject()));
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(

                    child: Image.asset("assets/images/result.png"),
                    radius: 55,
                  ),
                ),
                Text(
                  "Result Upload",
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 17),
                )
              ],
            ),
          ),
        )
    );
  }
}
