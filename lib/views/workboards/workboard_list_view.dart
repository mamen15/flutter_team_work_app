import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/crud/workboard_service.dart';
import 'package:flutter_application_2/utilities/dialogs/delete_dialog.dart';

typedef WorkboardCallBack = void Function(DatabaseWorkBoard workBoard);

class WorkboardsListView extends StatelessWidget {
  final List<DatabaseWorkBoard> workboards;
  final WorkboardCallBack onDeleteWorkboard;
  final WorkboardCallBack onTap;
  const WorkboardsListView({
    Key? key,
    required this.workboards,
    required this.onDeleteWorkboard,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: workboards.length,
      itemBuilder: (BuildContext context, int index) {
        final workboard = workboards[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            onTap: () {
              onTap(workboard);
            },
            title: Text(
              workboard.text,
            ),
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
        );
      },
    );
  }
}
