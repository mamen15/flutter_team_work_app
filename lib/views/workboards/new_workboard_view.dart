import 'package:flutter/material.dart';

class newWorkBoardView extends StatefulWidget {
  const newWorkBoardView({Key? key}) : super(key: key);

  @override
  State<newWorkBoardView> createState() => _newWorkBoardViewState();
}

class _newWorkBoardViewState extends State<newWorkBoardView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: ,
      //   )
      body: const Text('Write your new note here...'),
    );
  }
}
