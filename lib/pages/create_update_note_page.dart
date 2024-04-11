import 'package:flutter/material.dart';

import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/utils/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:notes_app/utils/generics/get_arguments.dart';
import 'package:notes_app/utils/size_config.dart';
import 'package:notes_app/services/cloud/cloud_note.dart';
import 'package:notes_app/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNotePage extends StatefulWidget {
  const CreateUpdateNotePage({super.key});

  @override
  State<CreateUpdateNotePage> createState() => _NewNotePageState();
}

class _NewNotePageState extends State<CreateUpdateNotePage> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController titleController;
  late final TextEditingController bodyController;
  String appBarTitle = 'Add Note';

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    titleController = TextEditingController();
    bodyController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  Future<CloudNote> createOrGetNewExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      titleController.text = widgetNote.title;
      bodyController.text = widgetNote.text;
      appBarTitle = 'Edit  Note';
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(userId: userId);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (titleController.text.isEmpty &&
        bodyController.text.isEmpty &&
        note != null) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final title = titleController.text;
    final text = bodyController.text;
    if (note != null && title.isNotEmpty && text.isNotEmpty) {
      await _notesService.updateNote(
        documentId: note.documentId,
        title: title,
        text: text,
      );
    }
  }

  void _setupTextControllerListener() {
    titleController.removeListener(_textControllerListener);
    bodyController.removeListener(_textControllerListener);
    titleController.addListener(_textControllerListener);
    bodyController.addListener(_textControllerListener);
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }

    final title = titleController.text;
    final text = bodyController.text;
    await _notesService.updateNote(
      documentId: note.documentId,
      title: title,
      text: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () async {
              final title = titleController.text;
              final text = bodyController.text;
              if (_note == null || title.isEmpty || text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                Share.share('$title\n\n$text');
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetNewExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return SafeArea(
                child: Container(
                  height: SizeConfig.screenHeight,
                  padding: const EdgeInsets.all(
                    16.0,
                  ),
                  child: Column(children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextFormField(
                              maxLines: null,
                              autofocus: true,
                              controller: titleController,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration.collapsed(
                                hintText: "Title",
                              ),
                              style: const TextStyle(
                                fontSize: 26.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: bodyController,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration.collapsed(
                                hintText: "Type something...",
                              ),
                              style: const TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
