import 'package:flutter/material.dart';
import 'package:card_scanner/camera_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Card scanner demo'),
        ),
        body: Center(
          child: CameraView(),
        ),
      ),
    );
  }
}
