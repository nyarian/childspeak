import "package:flutter/material.dart";

void main() => runApp(const ChildSpeak());

class ChildSpeak extends StatelessWidget {
  const ChildSpeak({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: "Flutter Demo",
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const Text("ChildSpeak"),
      );
}
