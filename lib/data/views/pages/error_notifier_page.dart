import 'package:flutter/material.dart';
import 'package:senior/data/core/repository/exceptions_network.dart';

class ErrorListener extends StatefulWidget {
  @override
  _ErrorListenerState createState() => _ErrorListenerState();
}

class _ErrorListenerState extends State<ErrorListener> {
  @override
  void initState() {
    super.initState();
    ErrorNotifier.errorMessage.addListener(() {
      if (ErrorNotifier.errorMessage.value != null) {
        showSnackBar(ErrorNotifier.errorMessage.value!);
        ErrorNotifier.errorMessage.value = null;
      }
    });
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
