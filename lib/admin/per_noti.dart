import 'package:flutter/material.dart';

class PermissionDeniedPage extends StatefulWidget {
  @override
  State<PermissionDeniedPage> createState() => _PermissionDeniedPageState();
}

class _PermissionDeniedPageState extends State<PermissionDeniedPage> {
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Scaffold(
            body: Center(
              child: AlertDialog(
                title: Text("Notice"),
                content: Text("You do not have the permision to open the function "),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OK"),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: Text("Web Interface")),
            body: Center(child: Text("Web interface design will be added here later.")),
          );
        }
      },
    );
  }
}

