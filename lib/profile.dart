import 'package:flutter/material.dart';
class profile extends StatefulWidget {
  @override
  State<profile> createState() => _profileState();
}
class _profileState extends State<profile> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Profile",
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: AppBar(
            title: Text(
              "Profile",
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
                  onTap: () {

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
                padding: EdgeInsets.all(50),
                child: Column(children: [
                  SizedBox(height: 10,),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                      icon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      icon: Icon(Icons.email_outlined),
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Branch',
                      icon: Icon(Icons.account_tree_outlined),
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      icon: Icon(Icons.phone_android_sharp),
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Role',
                      icon: Icon(Icons.perm_contact_cal_outlined),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Theme(data: ThemeData().copyWith(dividerColor: Colors.transparent),
                    child:
                    ExpansionTile(
                      trailing: Icon(Icons.man_2,color: Colors.transparent,),
                      title:Text('Update Password'),
                      leading:  Icon(Icons.password),
                      children: [
                        Column(
                          children: [
                            Padding(padding: EdgeInsets.all(0.01),
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Old Password',
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(0.01),
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'New Password',
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(0.01),
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Conform Password',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Material(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: (){

                      },
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 15,horizontal: 50),
                          child:  Text("Edit Profile" , style: TextStyle(
                              color: Colors.white,fontWeight: FontWeight.w500,fontSize: 18
                          ),),
                        ),
                      ),
                    ),
                  ),
                ],
                ),
              ),],
          ),
        ),
      ),
    );
  }
}