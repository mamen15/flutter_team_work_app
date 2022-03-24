import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/services/cloud/cloud_storage_contsants.dart';
import 'package:flutter/cupertino.dart';

@immutable
class CloudWorkboard {
  final String documentId;
  final String ownerUserId;
  final String text;

  const CloudWorkboard({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });

  CloudWorkboard.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[workboardTextFieldName] as String;
}

@immutable
class CloudToDoList {
  final String toDoListId;
  final String workboardId;
  final String todolistText;

  const CloudToDoList({
    required this.workboardId,
    required this.toDoListId,
    required this.todolistText,
  });

  CloudToDoList.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : toDoListId = snapshot.id,
        workboardId = snapshot.data()[workboardIdFieldName],
        todolistText = snapshot.data()[todolistTextFieldName] as String;
}