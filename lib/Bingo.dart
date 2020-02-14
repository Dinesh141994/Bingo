import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_bingo/CustomProgressDialog.dart';
import 'package:path/path.dart';
import 'Box.dart';
import 'Utils.dart';
import 'package:screenshot/screenshot.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_advanced_networkimage/zoomable.dart';
import 'package:shimmer/shimmer.dart';

class Bingo extends StatefulWidget {
  @override
  _BingoState createState() => _BingoState();
}

class _BingoState extends State<Bingo> {

 final String number="number";
 final String username="username";
  Random random = new Random();
  List<int> list=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25];
  Set<int> selectedNumbersList=Set();
  Set<int> set=Set();
  StreamSubscription<DocumentSnapshot> subscription;
  bool _isBingo=false;
  String currentUserName="";
  String winner="";
 ScreenshotController screenshotController = ScreenshotController();
 File imageFile;
 bool isResultView=false;
 String imageUrl="";
 CustomProgressDialog customProgressDialog=CustomProgressDialog();
 void _add(int number,String username) {
    final DocumentReference documentReference =
    Firestore.instance.document("MyBingo/bingo");
    documentReference.setData({
      this.number:number,
      this.username:username
    }).whenComplete(() {
      print("Document Added");
    }).catchError((e) => print(e));
  }

  Future<void> uploadPic(BuildContext context)async{
   customProgressDialog.showProgressDialog(context);
   String fileName=basename(imageFile.path);
   StorageReference reference=FirebaseStorage.instance.ref().child(fileName);
   StorageUploadTask storageUploadTask=await reference.putFile(imageFile);
   StorageTaskSnapshot taskSnapshot=await storageUploadTask.onComplete;
   setState(() {
     customProgressDialog.dismiss(context);
     print(">>>>><<<<<<<<<<>>>>>>>>>>>>>>>><<<<<<<<<<>>>>>>>>>>   ${taskSnapshot}");
   });
  }


  addItemsInSet(int length){
    int randomValue=random.nextInt(length);
    set.add(list[randomValue]);
    list.removeAt(randomValue);
    if(list.length!=0)
    {
      addItemsInSet(list.length);
    }
  }

  deleteImageFromFirestore()async
  {
    String fileName=basename(imageFile.path);
    StorageReference reference=FirebaseStorage.instance.ref().child(fileName);
     await reference.delete();

    setState(() {
    });
  }
 void _delete() {
   final DocumentReference documentReference =
   Firestore.instance.document("MyBingo/bingo");
   final DocumentReference deleteWinnerDocument =
   Firestore.instance.document("MyBingo/isBingoDone");
   documentReference.delete().whenComplete(() {
    deleteWinnerDocument.delete().whenComplete(() {
      print("Success");
      setState(() {

        _isBingo=false;
        currentUserName="";
        selectedNumbersList.clear();
        set.clear();
        list=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25];
        addItemsInSet(list.length);
        isResultView=false;
        Future.delayed(Duration(minutes: 2),(){
          deleteImageFromFirestore();
        });
      });
    }).catchError((err){print(err);});

   }).catchError((e) => print(e));
 }
  getData(){
    final DocumentReference documentReference =
    Firestore.instance.document("MyBingo/bingo");
    documentReference.snapshots().listen((datasnapshot) {
      if (datasnapshot.exists) {
        setState(() {
          Map map=datasnapshot.data;
          selectedNumbersList.add(map['number']);
          currentUserName=map['username'];
        });
      }else{
        setState(() {
          selectedNumbersList.clear();
        });
      }
    });
  }

  getFirestoreImage()async
  {
    customProgressDialog.showProgressDialog(this.context);

   // String fileName=basename(imageFile.path);
    StorageReference reference=FirebaseStorage.instance.ref().child(imageUrl);
    String url=await reference.getDownloadURL();
    setState(() {
      imageUrl=url;
      isResultView=true;
      customProgressDialog.dismiss(this.context);
      print(">>>>><<<<<<<<<<>>>>>>>>>>>>>>>><<<<<<<<<<>>>>>>>>>>   ${url}");
    });
  }

  takeScreenshot(String username)
  {
    imageFile = null;
    screenshotController.capture().then((File image) {
      setState(() {
        imageFile = image;
        submitBingo(username);
        uploadPic(this.context);
      });
    }).catchError((onError){print(onError);});

  }

  getBingoStatus()
  {
      final DocumentReference documentReference =
      Firestore.instance.document("MyBingo/isBingoDone");
      documentReference.snapshots().listen((datasnapshot) {
        if (datasnapshot.exists) {
          setState(() {
            Map map=datasnapshot.data;
            winner=map['username'];
            imageUrl=map['imageUrl'];
            _isBingo=true;
          });
        }
      });

  }

 void submitBingo(String username) {
   String fileName=basename(imageFile.path);
   final DocumentReference documentReference =
   Firestore.instance.document("MyBingo/isBingoDone");
   documentReference.setData({
     this.username:username,
     "imageUrl":fileName
   }).whenComplete(() {
     print("Document Added");
   }).catchError((e) => print(e));
 }

  @override
  void initState() {
    addItemsInSet(list.length);
  getData();
    getBingoStatus();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription.cancel();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bingo"),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
         // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Positioned(
        /*      height: MediaQuery.of(context).size.height/13,
              width: MediaQuery.of(context).size.width,
       */       top: 50,
              right: 10,
              left: 10,
            //  bottom: 0.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      width:  MediaQuery.of(context).size.width/3,
                      height: MediaQuery.of(context).size.height/13,
                      decoration: BoxDecoration(color: Colors.blue,borderRadius: BorderRadius.circular(30.0)),
                      child: Center(child: Text("My Bingo",style: TextStyle(color: Colors.white,fontSize: 16),)),
                    ),
                    onTap: (){
                      //myBingoDone(Utils.username);
                      takeScreenshot(Utils.username);
                    },
                  ),    GestureDetector(
                    child: Container(
                      width:  MediaQuery.of(context).size.width/3,
                      height: MediaQuery.of(context).size.height/13,

                      decoration: BoxDecoration(color: Colors.blue,borderRadius: BorderRadius.circular(30.0)),
                      child: Center(child: Text("Restart Game",style: TextStyle(color: Colors.white,fontSize: 16),)),
                    ),
                    onTap: (){
                      _delete();
                    },
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Screenshot(
                controller: screenshotController,
                child: Container(
                    height: MediaQuery.of(context).size.height/1.6,
                    margin: EdgeInsets.only(left: 10,right: 10,bottom: 20),
                    child:  GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5), itemBuilder: (context,index){
                      return Box(set.elementAt(index),selectedNumbersList,selectedNumberCallback: (b){

                        print(">>>>>>>>><<<<<<<<<<<<<<////////////////    $b");
                        print(">>>>>>>>><<<<<<<<<<<<<<////////////////    ${this.currentUserName}");

                        if(Utils.username != this.currentUserName ) {
                          _add(b, Utils.username??"");
                          selectedNumbersList.add(b);
                        }else{
                          Utils.showToast("it's not your turn baby");
                        }
                      },);
                    },itemCount: 25,)
                ),
              ),
            ),
           _isBingo?
           Container(
               height: MediaQuery.of(context).size.height,
               width: MediaQuery.of(context).size.width,
               color: Colors.red.withOpacity(0.7),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.center,
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: <Widget>[
                   isResultView?
               Container(
               height: MediaQuery.of(context).size.height/2,
               width: MediaQuery.of(context).size.width/1.2,
                 margin: EdgeInsets.only(top: 10.0),
                 child: TransitionToImage(
                   image: AdvancedNetworkImage(
                       imageUrl, timeoutDuration: Duration(minutes: 2)),fit: BoxFit.fill,
                   loadingWidget: CircularProgressIndicator(),
                   placeholder: Container(

                     decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/error_placeholder.jpg"),fit: BoxFit.fill)),
                   ),
                   duration: Duration(milliseconds: 300),
                 ),
               )
              /*     Container(
                     height: MediaQuery.of(context).size.height/2,
                     width: MediaQuery.of(context).size.width/1.2,
                   //  color: Colors.blue,
                     margin: EdgeInsets.only(top: 10.0),
                     decoration: BoxDecoration(image: DecorationImage(image: AdvancedNetworkImage(imageUrl),fit: BoxFit.fill)),

                   )*/:Container(),
                   Text("${winner}'s bingo done",style: TextStyle(fontSize: 30,color: Colors.white),),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: <Widget>[
                       GestureDetector(
                         child: Container(
                           width:  MediaQuery.of(context).size.width/3,
                           height: MediaQuery.of(context).size.height/13,
                            margin: EdgeInsets.only(top: 15),
                           decoration: BoxDecoration(color: Colors.blue,borderRadius: BorderRadius.circular(30.0)),
                           child: Center(child: Text("Restart Game",style: TextStyle(color: Colors.white,fontSize: 16),)),
                         ),
                         onTap: (){
                                  _delete();
                         },
                       ),
                       GestureDetector(
                         child: Container(
                           width:  MediaQuery.of(context).size.width/3,
                           height: MediaQuery.of(context).size.height/13,
                           margin: EdgeInsets.only(top: 15),
                           decoration: BoxDecoration(color: Colors.blue,borderRadius: BorderRadius.circular(30.0)),
                           child: Center(child: Text("View Result",style: TextStyle(color: Colors.white,fontSize: 16),)),
                         ),
                         onTap: (){
                           getBingoStatus();
                           getFirestoreImage();
                         },
                       ),
                     ],
                   )
                 ],
               )):Container(),

          ],
        ),
      ),
    );
  }
}
