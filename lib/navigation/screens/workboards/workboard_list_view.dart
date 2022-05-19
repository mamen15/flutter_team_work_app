import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/cloud/cloud_app.dart';
import 'package:flutter_application_2/utilities/dialogs/delete_dialog.dart';

typedef WorkboardCallBack = void Function(CloudWorkboard workBoard);

class WorkboardsListView extends StatelessWidget {
  final Iterable<CloudWorkboard> workboards;
  final WorkboardCallBack onDeleteWorkboard;
  final WorkboardCallBack onUpdate;
  const WorkboardsListView({
    Key? key,
    required this.workboards,
    required this.onDeleteWorkboard,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: workboards.length,
      itemBuilder: (BuildContext context, int index) {
        final workboard = workboards.elementAt(index);
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            onTap: () {
              /* to the to do list view */

            },
            title: Text(
              workboard.text,
            ),
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        onUpdate(workboard);
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                    onPressed: () async {
                      final shouldDelete = await showDeleteDialog(context);
                      if (shouldDelete) {
                        onDeleteWorkboard(workboard);
                      }
                    },
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
