import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/services/cloud/cloud_storage_contsants.dart';
import 'package:flutter_application_2/services/cloud/cloud_storage_exeptions.dart';
import 'package:flutter_application_2/services/cloud/cloud_workboard.dart';

class FirebaseCloudStorage {
  final workboards = FirebaseFirestore.instance.collection('workboards');
  
  Future<void> deleteWorkboard({
    required String documentId,
  }) async {
    try {
      await workboards.doc(documentId).delete() ;
    } catch (e) {
      throw CouldNotDeleteWorkBoardException();
    }
  }

  Future<void> updateWorkboard({
    required String documentId,
    required String text,
  }) async {
    try {
      await workboards.doc(documentId).update({workboardTextFieldName : text}) ;
    } catch (e) {
      throw CouldNotUpdateWorkBoardException();
    }
  }

  Stream<Iterable<CloudWorkboard>> allWorkboards(
          {required String ownerUserId}) =>
      workboards.snapshots().map((event) => event.docs
          .map((doc) => CloudWorkboard.fromSnapshot(doc))
          .where((workboard) => workboard.ownerUserId == ownerUserId));

  Future<Iterable<CloudWorkboard>> getWorkboards(
      {required String ownerUserId}) async {
    try {
      return await workboards
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get()
          .then((value) => value.docs.map((doc) {
                return CloudWorkboard(
                  documentId: doc.id,
                  ownerUserId: doc.data()[ownerUserIdFieldName],
                  text: doc.data()[workboardTextFieldName] as String,
                );
              }));
    } catch (e) {
      throw CouldNotGetAllWorkBoardException();
    }
  }

  void createNewWorkboard({required String ownerUserId}) async {
    await workboards.add({
      ownerUserIdFieldName: ownerUserId,
      workboardTextFieldName: '',
    });
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
