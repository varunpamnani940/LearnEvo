import 'package:dreamclass/AddCourse.dart';
import 'package:dreamclass/addstudent.dart';
import 'package:dreamclass/addsubject.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
    Icon(Icons.account_circle_rounded),
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
                  // Navigator.push(context,MaterialPageRoute(builder: (context)=> profile())); // Close the drawer
                  // Navigate to a screen related to Option 1 if needed
                },
              ),
              ListTile(
                leading: Icon(Icons.upload, color: Colors.white),
                title: const Text('Attendence Upload',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Navigate to a screen related to Option 2 if needed
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
              )
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
                    child: Column(
                      children: [
                        SizedBox(height: 25),
                        Container(
                          child: bottomNavigationBarItems[_current_Index],
                        )
                      ],
                    )),
              ),
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
                      ImageCard(),
                      ImageCard(),
                      ImageCard(),
                      ImageCard(),
                      ImageCard(),
                      ImageCard(),
                      ImageCard(),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 7,
                  effect: ExpandingDotsEffect(),
                ),
                SizedBox(height: 40),
                Row(
                  children: [
                    ImageButtonHomeInquiry(),
                    ImageButtonHomeAddUser(),
                    ImageButtonHomeDelete(),
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
  @override
  State<StatefulWidget> createState() {
    return ImageCardState();
  }
}

class ImageCardState extends State<ImageCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        width: 500,
        height: 200,
        decoration: BoxDecoration(
            color: Colors.blue[300], borderRadius: BorderRadius.circular(20)),
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
            onTap: () {},
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(
                    child: Image.asset("assets/images/inquiry.png"),
                    radius: 55,
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
                    radius: 55,
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
            onTap: () {},
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(

                    child: Image.asset("assets/images/delete2.png"),
                    radius: 55,
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
            onTap: () {},
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
                    radius: 55,
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=> Addsubject()));
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
              ImageButtonHomePerfomance(),
              ImageButtonHomePerfomance(),
            ],
          )

         ],
       ),
     )

   );
  }

}
