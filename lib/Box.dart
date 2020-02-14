import 'package:flutter/material.dart';
import 'package:my_bingo/Callback.dart';
import 'Utils.dart';

class Box extends StatefulWidget {
  int value;
  SelectedNumber selectedNumberCallback;
  Set<int> list;
  Box(this.value,this.list,{this.selectedNumberCallback});

  @override
  _BoxState createState() => _BoxState();
}

class _BoxState extends State<Box> {

  selectedNumber(int number){
    widget.selectedNumberCallback(number);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black),
          color: widget.list.contains(widget.value)?Colors.red:Colors.white),
        child: Center(child: Text("${widget.value}"),),
      ),onTap: (){
        if(widget.list.contains(widget.value))
          {
            Utils.showToast("Number already selected");
          }else
            {
              selectedNumber(widget.value);
            }
    },
    );
  }
}
