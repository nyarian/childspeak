import 'package:flutter/material.dart';

void main() => runApp(ChildSpeak());

class ChildSpeak extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Text('ChildSpeak'),
    );
  }
}
