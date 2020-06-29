import 'package:flutter/material.dart';

class AddEntityPage extends StatefulWidget {
  static const String name = '/entity/add';

  static Widget builder(BuildContext context) => const AddEntityPage();

  const AddEntityPage({Key key}) : super(key: key);

  @override
  _AddEntityPageState createState() => _AddEntityPageState();
}

class _AddEntityPageState extends State<AddEntityPage> {
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Text('Add entity'),
        ),
      );
}
