import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/crud/workboard_service.dart';
import 'package:flutter_application_2/utilities/dialogs/delete_dialog.dart';

typedef DeleteWorkboardCallBack = void Function(DatabaseWorkBoard workBoard);

class WorkboardsListView extends StatelessWidget {
  final List<DatabaseWorkBoard> workboards;
  final DeleteWorkboardCallBack onDeleteWorkboard;
  const WorkboardsListView({
    Key? key,
    required this.workboards,
    required this.onDeleteWorkboard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: workboards.length,
        itemBuilder: (BuildContext context, int index) {
          final workboard = workboards[index];
          return Dismissible(
            key: Key(workboard.text),
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.all(5),
              key: Key(workboards.toString()),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                title: Text(workboards.toString()),
                trailing: IconButton(
                  onPressed: () async {
                    final shouldDelete = await showDeleteDialog(context);
                    if (shouldDelete) {
                      onDeleteWorkboard(workboard);
                    }
                  },
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                ),
              ),
            ),
          );
        });
  }
}
