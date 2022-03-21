import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/auth/auth_service.dart';
import 'package:flutter_application_2/services/crud/workboard_service.dart';
import 'package:sqflite/sqflite.dart';

class newWorkBoardView extends StatefulWidget {
  const newWorkBoardView({Key? key}) : super(key: key);

  @override
  State<newWorkBoardView> createState() => _newWorkBoardViewState();
}

class _newWorkBoardViewState extends State<newWorkBoardView> {
  DatabaseWorkBoard? _woarkboard;
  late final WorkBoardService _workboardsService;
  late final TextEditingController _textController;

  Future<DatabaseWorkBoard> createNewWorkBoard() async {
    final existingWorkboard = _woarkboard;
    if (existingWorkboard != null) {
      return existingWorkboard;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _workboardsService.getUser(email: email);
    return _workboardsService.createWorkBoard(owner: owner);
  }

  void _deleteWorkboardIfTextIsEmpty() {
    final workboard = _woarkboard;
    if (_textController.text.isEmpty && workboard != null) {
      _workboardsService.deleteWorkBoard(id: workboard.id);
    }
  }

  void _saveWorkboardIfTextIsNotEmpty() {
    final workboard = _woarkboard;
    final text = _textController.text;
    if (_textController.text.isNotEmpty && workboard != null) {
      _workboardsService.updateWorkBoard(
        workboard: workboard,
        text: text,
      );
    }
  }

  @override
  void initState() {
    _workboardsService = WorkBoardService();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final workboard = _woarkboard;
    if (workboard == null) {
      return;
    }
    final text = _textController.text;
    await _workboardsService.updateWorkBoard(workboard: workboard, text: text);
  }

  void _setupTextControllerListener() async {
    _textController.removeListener(_textControllerListener);
    _textController.addListener((_textControllerListener));
  }

  @override
  void dispose() {
    _deleteWorkboardIfTextIsEmpty();
    _saveWorkboardIfTextIsNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Center(child: Text("Add a Workboard")),
      content: Container(
        width: double.infinity,
        height: 100,
        child: Column(
          children: [
            TextField(
              controller: _textController,
              keyboardType: TextInputType.multiline,
              maxLines: null,

              // onChanged: (String value) {
              //   input = value;
              // },
              
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(5),
                  hintText: "Enter your workboard's name"),
            ),
            ElevatedButton(
                onPressed: () {
                  // setState(() {
                  //   workboards.add(input);
                  //   Navigator.of(context).pop();
                  // });
                },
                child: const Text('Add your Workboard Daddy <3')),
          ],
        ),
      ),
    );
  }
}
