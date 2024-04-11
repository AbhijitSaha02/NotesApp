import 'dart:math';

import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/services/cloud/cloud_note.dart';

import 'package:notes_app/utils/dialogs/delete_dialog.dart';
import 'package:notes_app/utils/size_config.dart';

typedef DeleteCallBack = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final DeleteCallBack onDeleteNote;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
  });

  Widget _notesCard(
    BuildContext context,
    CloudNote note,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        _showNote(context, note);
      },
      child: Card(
        elevation: 10,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
              const SizedBox(height: 8),
              Text(
                note.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.left,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showNote(
    BuildContext context,
    CloudNote note,
  ) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                height: SizeConfig.screenHeight * 0.75,
                width: SizeConfig.screenWidth * 0.85,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(
                        5.0,
                        5.0,
                      ),
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ), //BoxShadow
                    BoxShadow(
                      color: Colors.white,
                      offset: Offset(0.0, 0.0),
                      blurRadius: 0.0,
                      spreadRadius: 0.0,
                    ), //BoxShadow
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          color: Colors.transparent,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        const Spacer(),
                        Container(
                          color: Colors.transparent,
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit_document,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.popAndPushNamed(
                                  context, createUpdateNotePageRoute,
                                  arguments: note);
                            },
                          ),
                        ),
                        Container(
                          color: Colors.transparent,
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete_rounded,
                              color: Colors.black,
                            ),
                            onPressed: () async {
                              final shouldDelete =
                                  await showDeleteDialog(context);
                              if (shouldDelete) {
                                onDeleteNote(note);
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.all(10),
                          color: Colors.white70,
                          child: Text(
                            note.title,
                            style: const TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            note.text,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.justify,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final lightColors = [
      Colors.amber.shade300,
      Colors.lightGreen.shade300,
      Colors.lightBlue.shade300,
      Colors.orange.shade300,
      Colors.pinkAccent.shade100,
      Colors.tealAccent.shade100,
      Colors.purpleAccent,
      Colors.greenAccent.shade400,
      Colors.cyanAccent,
    ];

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        return _notesCard(
          context,
          note,
          lightColors[random.nextInt(8)],
        );
      },
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
    );
  }
}
