import 'package:flutter/material.dart';
import 'login.dart';

void main() => runApp(Splash());

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Get Started",
      home: GetStarted(),
    );
  }
}
class GetStarted extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          width: 500,
          height: 550,
          decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius:
                  BorderRadius.only(bottomRight: Radius.circular(140))),
          child: Container(
              child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 70, top: 170),
                child: Image.asset('assets/images/books.png',width: 600,height: 300,),
              )
            ],
          )),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.blue[700],
            width: 550,
            height: 350,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 550,
            height: 350,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(140))),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    "Learning is Everything",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40,vertical: 10),
                  child: Text(
                    "Learning with  Pleasure with  Dear programer, Wherever you are",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,

                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 50),
                Material(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));
                    },
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20,horizontal: 120),
                        child:  Text("Get Started" , style: TextStyle(
                            color: Colors.white,fontWeight: FontWeight.w700,fontSize: 22
                        ),),

                      )
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    ));
  }
}
