import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/services/cloud/cloud_note.dart';
import 'package:notes_app/services/cloud/cloud_storage_constants.dart';
import 'package:notes_app/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  Future<CloudNote> createNewNote({required String userId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: userId,
      titleFieldName: '',
      textFieldName: '',
    });

    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      userId: userId,
      title: '',
      text: '',
    );
  }

  Future<Iterable<CloudNote>> getNotes({required String userId}) async {
    try {
      return await notes
          .where(ownerUserIdFieldName, isEqualTo: userId)
          .get()
          .then(
            (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)),
          );
    } catch (e) {
      throw CouldNotGetAllNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String userId}) =>
      notes.snapshots().map(
            (event) => event.docs
                .map((doc) => CloudNote.fromSnapshot(doc))
                .where((note) => note.userId == userId),
          );

  Future<void> updateNote({
    required String documentId,
    required String title,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({
        titleFieldName: title,
        textFieldName: text,
      });
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }
}
