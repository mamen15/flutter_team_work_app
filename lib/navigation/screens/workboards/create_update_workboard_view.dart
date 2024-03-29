import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/auth/auth_service.dart';
import 'package:flutter_application_2/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_application_2/utilities/dialogs/generics/get_arguments.dart';
import 'package:flutter_application_2/services/cloud/cloud_storage_exeptions.dart';
import 'package:flutter_application_2/services/cloud/cloud_app.dart';

class createOrUpdateWorkBoardView extends StatefulWidget {
  const createOrUpdateWorkBoardView({Key? key}) : super(key: key);

  @override
  State<createOrUpdateWorkBoardView> createState() =>
      _createOrUpdateWorkBoardViewState();
}

class _createOrUpdateWorkBoardViewState
    extends State<createOrUpdateWorkBoardView> {
  CloudWorkboard? _woarkboard;
  late final FirebaseCloudStorage _workboardsService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _workboardsService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final workboard = _woarkboard;
    if (workboard == null) {
      return;
    }
    final text = _textController.text;
    await _workboardsService.updateWorkboard(
      documentId: workboard.documentId,
      text: text,
    );
  }

  void _setupTextControllerListener() async {
    _textController.removeListener(_textControllerListener);
    _textController.addListener((_textControllerListener));
  }

  Future<CloudWorkboard> createOrGetExistingWorkboard(
      BuildContext context) async {
    final widgetWorkboard = context.getArgument<CloudWorkboard>();
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
    final userId = currentUser.id;
    final newWorkboard =
        await _workboardsService.createNewWorkboard(ownerUserId: userId);
    _woarkboard = newWorkboard;
    return newWorkboard;
  }

  void _deleteWorkboardIfTextIsEmpty() {
    final workboard = _woarkboard;
    if (_textController.text.isEmpty && workboard != null) {
      _workboardsService.deleteWorkboard(documentId: workboard.documentId);
    }
  }

  void _saveWorkboardIfTextIsNotEmpty() {
    final workboard = _woarkboard;
    final text = _textController.text;
    if (workboard != null && _textController.text.isNotEmpty) {
      _workboardsService.updateWorkboard(
        documentId: workboard.documentId,
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
