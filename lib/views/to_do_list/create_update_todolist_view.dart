import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/auth/auth_service.dart';
import 'package:flutter_application_2/services/cloud/cloud_storage_contsants.dart';
import 'package:flutter_application_2/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_application_2/utilities/dialogs/generics/get_arguments.dart';
import 'package:flutter_application_2/services/cloud/cloud_app.dart';

class createOrUpdateToDoListView extends StatefulWidget {
  const createOrUpdateToDoListView({Key? key}) : super(key: key);

  @override
  State<createOrUpdateToDoListView> createState() =>
      _createOrUpdateToDoListView();
}

class _createOrUpdateToDoListView extends State<createOrUpdateToDoListView> {
  CloudToDoList? _todolist;
  late final FirebaseCloudStorage _toDoListService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _toDoListService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final todolist = _todolist;
    if (todolist == null) {
      return;
    }
    final todolistText = _textController.text;
    await _toDoListService.updateToDoList(
      toDoListId: todolist.toDoListId,
      todolistText: todolistText,
    );
  }

  void _setupTextControllerListener() async {
    _textController.removeListener(_textControllerListener);
    _textController.addListener((_textControllerListener));
  }

  // Future<CloudToDoList> createOrGetExistingtodolist(
  //     BuildContext context) async {
  //   final widgettodolist = context.getArgument<CloudToDoList>();
  //   if (widgettodolist != null) {
  //     _todolist = widgettodolist;
  //     _textController.text = widgettodolist.todolistText;
  //     return widgettodolist;
  //   }
  //   final existingtodolist = _todolist;
  //   if (existingtodolist != null) {
  //     return existingtodolist;
  //   }
  //   final currentUser = AuthService.firebase().currentUser!;
  //   final userId = currentUser.id;
  //   final newtodolist =
  //       await _todolistsService.createNewtodolist(ownerUserId: userId);
  //   _woarkboard = newtodolist;
  //   return newtodolist;
  // }

  // void _deletetodolistIfTextIsEmpty() {
  //   final todolist = _woarkboard;
  //   if (_textController.text.isEmpty && todolist != null) {
  //     _todolistsService.deletetodolist(documentId: todolist.documentId);
  //   }
  // }

  void _savetodolistIfTextIsNotEmpty() {
    final todolist = _woarkboard;
    final text = _textController.text;
    if (todolist != null && _textController.text.isNotEmpty) {
      _todolistsService.updatetodolist(
        documentId: todolist.documentId,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deletetodolistIfTextIsEmpty();
    _savetodolistIfTextIsNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Center(child: Text("Add a todolist")),
      content: SizedBox(
        width: double.infinity,
        height: 100,
        child: FutureBuilder(
          future: createOrGetExistingtodolist(context),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                _setupTextControllerListener();
                return Column(
                  children: [
                    TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(5),
                          hintText: "Enter your todolist's name"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Add your todolist Daddy <3'),
                    ),
                  ],
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
