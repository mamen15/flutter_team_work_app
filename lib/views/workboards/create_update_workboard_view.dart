
import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/auth/auth_service.dart';
import 'package:flutter_application_2/services/crud/workboard_service.dart';
import 'package:flutter_application_2/utilities/dialogs/generics/get_arguments.dart';

class createOrUpdateWorkBoardView extends StatefulWidget {
  const createOrUpdateWorkBoardView({Key? key}) : super(key: key);

  @override
  State<createOrUpdateWorkBoardView> createState() =>
      _createOrUpdateWorkBoardViewState();
}

class _createOrUpdateWorkBoardViewState
    extends State<createOrUpdateWorkBoardView> {
  DatabaseWorkBoard? _woarkboard;
  late final WorkBoardService _workboardsService;
  late final TextEditingController _textController;

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
    await _workboardsService.updateWorkBoard(
      workboard: workboard,
      text: text,
    );
  }

  void _setupTextControllerListener() async {
    _textController.removeListener(_textControllerListener);
    _textController.addListener((_textControllerListener));
  }

  Future<DatabaseWorkBoard> createOrGetExistingWorkboard(
      BuildContext context) async {
    final widgetWorkboard = context.getArgument<DatabaseWorkBoard>();
    if (widgetWorkboard != null) {
      _woarkboard = widgetWorkboard;
      _textController.text = widgetWorkboard.text;
      return widgetWorkboard;
    }
    final existingWorkboard = _woarkboard;
    if (existingWorkboard != null) {
      return existingWorkboard;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _workboardsService.getUser(email: email);
    final newWorkboard = await _workboardsService.createWorkBoard(owner: owner);
    _woarkboard = newWorkboard;
    return newWorkboard;
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
    if (workboard != null && _textController.text.isNotEmpty ) {
      _workboardsService.updateWorkBoard(
        workboard: workboard,
        text: text,
      );
    }
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
      content: SizedBox(
        width: double.infinity,
        height: 100,
        child: FutureBuilder(
          future: createOrGetExistingWorkboard(context),
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
                          hintText: "Enter your workboard's name"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Add your Workboard Daddy <3'),
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
