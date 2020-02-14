import 'package:flutter/material.dart';

import 'Bingo.dart';
import 'Utils.dart';


class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  TextEditingController textEditingController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 60,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.0),border: Border.all(color: Colors.blue)),
              child: TextField(
                decoration: InputDecoration(hintText: "Enter your name",border: InputBorder.none,prefix: Padding(padding: EdgeInsets.all(10.0),)),controller: textEditingController,
              ),
            ),
            RaisedButton(child: Text("Submit"),onPressed: (){
              if(textEditingController.text=="")
                Utils.showToast("Please enter your name");
              else {
                Utils.username=textEditingController.text;
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Bingo()));
              }
            },)
          ],
        ),
      ),
    );
  }
}
