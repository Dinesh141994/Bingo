import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';


class Utils{
  static String username;
  static void showToast(String msg)
{
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
  );
}
}