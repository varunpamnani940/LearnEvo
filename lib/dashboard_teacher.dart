import 'package:dreamclass/AddCourse.dart';
import 'package:dreamclass/DeviceManager.dart';
import 'package:dreamclass/EditStudent.dart';
import 'package:dreamclass/addnotes.dart';
import 'package:dreamclass/addstudent.dart';
import 'package:dreamclass/addsubject.dart';
import 'package:dreamclass/profile.dart';
import 'package:dreamclass/removestudent.dart';
import 'package:dreamclass/transfer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'Availablestudent.dart';
import 'att.dart';
import 'fees.dart';
import 'inquiry.dart';
import 'main.dart';

class TeacherDashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TeacherDashboardState();
  }
}
class TeacherDashboardState extends State<TeacherDashboard> {
  int _current_Index = 0;
  List<Widget> bottomNavigationBarItems = [
    Home(),
    Fees(),
    Categories(),
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "TeacherDashboard",
      home: Scaffold(
        drawer: Drawer(
          backgroundColor: Colors.blue[700],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const EndDrawerButton(

              ),
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
                   Navigator.push(context,MaterialPageRoute(builder: (context)=> profile())); // Close the drawer
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
              Icons.logout_outlined,
              color: Colors.white,
            ),
            title: const Text("Logout",
                style: TextStyle(color: Colors.white)),
            onTap: ()  async {
            final  SharedPreferences Logut =  await SharedPreferences.getInstance();
            Logut.remove("teacher");
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
                width: MediaQuery.sizeOf(context).width,
                height:  MediaQuery.sizeOf(context).height*0.2,
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(100)),
                    color: Colors.blue[700]),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height*0.75,
                  decoration: BoxDecoration(color: Colors.blue[700]),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    width:  MediaQuery.sizeOf(context).width,
                    height:  MediaQuery.sizeOf(context).height*0.75,
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
  final _controller = PageController();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          child: Container(
            child: Column(
              children: [
                SizedBox(height: 25,),
                Text(
                  "“Memory is the treasury and guardian of all things.”",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                // SizedBox(height: MediaQuery.sizeOf(context).height*0.01),
                Container(
                  height: MediaQuery.sizeOf(context).height*0.2,
                  width: MediaQuery.sizeOf(context).width,
                  child: PageView(
                    controller: _controller,
                    children: [
                      Expanded(child:  ImageCard("assets/images/4.jpg"),),
                      Expanded(child:  ImageCard("assets/images/2.jpg"),),
                      Expanded(child:  ImageCard("assets/images/3.jpg"),),
                      Expanded(child:  ImageCard("assets/images/4.jpg"),),
                      Expanded(child:  ImageCard("assets/images/5.jpg"),),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height*0.02),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 5,
                  // effect: ExpandingDotsEffect(),
                ),
                 SizedBox(height:  MediaQuery.sizeOf(context).height*0.04),
                Container(
                  // width: MediaQuery.sizeOf(context).width*0.001,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ImageButtonHomeInquiry(),
                      ImageButtonHomeAddUser(),
                      ImageButtonHomeDelete(),
                    ],
                  ),
                ),
                SizedBox(height:  MediaQuery.sizeOf(context).height*0.04),
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
        width: MediaQuery.sizeOf(context).width*0.5,
        height:  MediaQuery.sizeOf(context).height*0.2,

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
class ImageButtonHomeInquiry extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ImageButtonHomeInquiryState();
  }
}
class ImageButtonHomeInquiryState extends State<ImageButtonHomeInquiry>{
  @override
  Widget build(BuildContext context) {
    return Container(

        child: Material(
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> Inquiry()));
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(
                    child: Image.asset("assets/images/inquiry.png"),
                    radius: MediaQuery.sizeOf(context).width*0.12,
                  ),
                ),
                Text(
                  "Inquiry",
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
class ImageButtonHomeAddUser extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ImageButtonHomeAddUserState();
  }
}
class ImageButtonHomeAddUserState extends State<ImageButtonHomeAddUser>{
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
          child: InkWell(
            onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddStudent()));
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(
                    backgroundColor: Colors.pink,
                    child: Image.asset("assets/images/adduser.png"),
                    radius: MediaQuery.sizeOf(context).width*0.12,
                  ),
                ),
                Text(
                  "Add Student",
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
class ImageButtonHomeDelete extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ImageButtonHomeDeleteState();
  }
}
class ImageButtonHomeDeleteState extends State<ImageButtonHomeDelete>{
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext)=>Removestudent()));
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(

                    child: Image.asset("assets/images/delete2.png"),
                    radius: MediaQuery.sizeOf(context).width*0.12,
                  ),
                ),
                Text(
                  "Remove Student",
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=>AddNotes()));
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(

                    child: Image.asset("assets/images/notes.png"),
                    radius: MediaQuery.sizeOf(context).width*0.14,
                  ),
                ),
                Text(
                  "Note's Upload",
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
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddCourse()));
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(

                    child: Image.asset("assets/images/add.png"),
                    radius: MediaQuery.sizeOf(context).width*0.14,
                  ),
                ),
                Text(
                  "Add Course",
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
                    radius: MediaQuery.sizeOf(context).width*0.14,
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=> Addsubject()));
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(

                    child: Image.asset("assets/images/addsub.png"),
                    radius: MediaQuery.sizeOf(context).width*0.11,
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
              ImageButtonAttendence(),
            ],
          ),
           Row(
             children: [
               ImageButtonstudent(),
               ImageButtondevice(),
               ImageButtontransfer(),
             ],
           ),
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=> Addsubject()));
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
class ImageButtonAttendence extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ImageButtonAttendencestate();
  }
}
class ImageButtonAttendencestate extends State<ImageButtonAttendence>{
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> att()));
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(

                    child: Image.asset("assets/images/att.png"),
                    radius: 55,
                  ),
                ),
                Text(
                  " Att  Upload",
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
class ImageButtonstudent extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ImageButtonstudentstate();
  }
}
class ImageButtonstudentstate extends State<ImageButtonstudent>{
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
          child: InkWell(
            onTap: () {

              Navigator.push(context, MaterialPageRoute(builder: (context)=> Availablestudent()));
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(

                    child: Image.asset("assets/images/student1.png"),
                    radius: 55,
                  ),
                ),
                Text(
                  "Available Student",
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                )
              ],
            ),
          ),
        )
    );
  }
}
class ImageButtondevice extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ImageButtondevicestate();
  }
}
class ImageButtondevicestate extends State<ImageButtondevice>{
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
          child: InkWell(
            onTap: () {

              Navigator.push(context, MaterialPageRoute(builder: (context)=> DeviceManager()));
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(

                    child: Image.asset("assets/images/device1.png"),
                    radius: 55,
                  ),
                ),
                Text(
                  "Device Manager",
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
class ImageButtontransfer extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ImageButtontransferstate();
  }
}
class ImageButtontransferstate extends State<ImageButtontransfer>{
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
          child: InkWell(
            onTap: () {

              Navigator.push(context, MaterialPageRoute(builder: (context)=> Transfer()));
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(

                    child: Icon(Icons.transform,size: 70,),
                    radius: 55,
                  ),
                ),
                Text(
                  "Trasnfer",
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