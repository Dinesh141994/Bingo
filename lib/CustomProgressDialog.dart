import 'package:flutter/material.dart';

class CustomProgressDialog {
  BuildContext context;

  /// show Progress Dialog UI
  void showProgressDialog(BuildContext context) {
    this.context = context;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(
              child: SizedBox(
            child: new Theme(
                data:
                    Theme.of(context).copyWith(accentColor: Colors.blue),
                child: CircularProgressIndicator()),
            height: 50.0,
            width: 50.0,
          ));
        });
  }

  void dismiss(BuildContext context) {
    Navigator.pop(context);
  }
}
