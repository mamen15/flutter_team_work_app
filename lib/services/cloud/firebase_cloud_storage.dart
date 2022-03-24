import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/services/cloud/cloud_storage_contsants.dart';
import 'package:flutter_application_2/services/cloud/cloud_storage_exeptions.dart';
import 'package:flutter_application_2/services/cloud/cloud_app.dart';

class FirebaseCloudStorage {
  final workboards = FirebaseFirestore.instance.collection('workboards');
  final todolists = FirebaseFirestore.instance.collection('to do list');

  Future<void> deleteToDoList({
    required String toDoListId,
  }) async {
    try {
      await workboards.doc(toDoListId).delete();
    } catch (e) {
      throw CouldNotDeleteWorkBoardException();
    }
  }

  Future<void> deleteWorkboard({
    required String documentId,
  }) async {
    try {
      await workboards.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteWorkBoardException();
    }
  }

  Future<void> updateToDoList({
    required String toDoListId,
    required String todolistText,
  }) async {
    try {
      await workboards
          .doc(toDoListId)
          .update({todolistTextFieldName: todolistText});
    } catch (e) {
      throw CouldNotUpdateWorkBoardException();
    }
  }

  Future<void> updateWorkboard({
    required String documentId,
    required String text,
  }) async {
    try {
      await workboards.doc(documentId).update({workboardTextFieldName: text});
    } catch (e) {
      throw CouldNotUpdateWorkBoardException();
    }
  }

  Stream<Iterable<CloudToDoList>> allToDoLists({required String workboardId}) =>
      todolists.snapshots().map((event) => event.docs
          .map((doc) => CloudToDoList.fromSnapshot(doc))
          .where((workboard) => workboard.workboardId == workboardId));

  Stream<Iterable<CloudWorkboard>> allWorkboards(
          {required String ownerUserId}) =>
      workboards.snapshots().map((event) => event.docs
          .map((doc) => CloudWorkboard.fromSnapshot(doc))
          .where((workboard) => workboard.ownerUserId == ownerUserId));

  Future<Iterable<CloudWorkboard>> getToDoLists(
      {required String workboardId}) async {
    try {
      return await todolists
          .where(workboardId, isEqualTo: workboardId)
          .get()
          .then(
            (value) => value.docs.map(
              (doc) => CloudWorkboard.fromSnapshot(doc),
            ),
          );
    } catch (e) {
      throw CouldNotGetAllWorkBoardException();
    }
  }

  Future<Iterable<CloudWorkboard>> getWorkboards(
      {required String ownerUserId}) async {
    try {
      return await workboards
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get()
          .then(
            (value) => value.docs.map(
              (doc) => CloudWorkboard.fromSnapshot(doc),
            ),
          );
    } catch (e) {
      throw CouldNotGetAllWorkBoardException();
    }
  }

  Future<CloudToDoList> createNewToDoList(
      {required String workboardId}) async {
    final document = await workboards.add({
      workboardIdFieldName: workboardId,
      todolistTextFieldName: '',
    });
    final fetchedtodolist = await document.get();
    return CloudToDoList(
      toDoListId: fetchedtodolist.id,
      workboardId: workboardId,
      todolistText: '',
    );
  }

  Future<CloudWorkboard> createNewWorkboard(
      {required String ownerUserId}) async {
    final document = await workboards.add({
      ownerUserIdFieldName: ownerUserId,
      workboardTextFieldName: '',
    });
    final fetchedWorkboard = await document.get();
    return CloudWorkboard(
      documentId: fetchedWorkboard.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

// this below is a singleton initializer
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
