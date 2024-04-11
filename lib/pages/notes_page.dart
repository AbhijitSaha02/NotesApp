import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;

import 'package:notes_app/enums/menu_action.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/pages/notes_list_view.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/services/auth/bloc/auth_bloc.dart';
import 'package:notes_app/services/auth/bloc/auth_event.dart';
import 'package:notes_app/services/cloud/cloud_note.dart';
import 'package:notes_app/services/cloud/firebase_cloud_storage.dart';
import 'package:notes_app/utils/dialogs/logout_dialog.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  PopupMenuItem _buildPopupMenuItem(
      String title, IconData iconData, MenuAction value) {
    return PopupMenuItem(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            iconData,
            color: Colors.black,
          ),
          Text(title),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('MyNotes'),
          centerTitle: true,
          actions: [
            PopupMenuButton(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.signout:
                    devtools.log('signout');
                    final shouldLogOut = await showLogOutDialog(context);
                    if (shouldLogOut) {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    }
                    break;
                  case MenuAction.profile:
                    break;
                }
              },
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
              ),
              itemBuilder: (BuildContext context) => [
                _buildPopupMenuItem(
                    'Sign Out', Icons.exit_to_app_rounded, MenuAction.signout),
                _buildPopupMenuItem('Profile', Icons.account_circle_rounded,
                    MenuAction.profile),
              ],
            )
          ],
        ),
        body: StreamBuilder(
          stream: _notesService.allNotes(userId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(
                          documentId: note.documentId);
                    },
                  );
                } else {
                  return const Center(
                      child: Text(
                    'Notes is Empty. \nAdd a note.',
                    textAlign: TextAlign.center,
                  ));
                }
              default:
                return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(56)),
          ),
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xfffbb448), Color(0xffe46b10)]),
            ),
            child: const Icon(
              Icons.add,
              size: 30,
              color: Colors.white,
            ),
          ),
          onPressed: () async {
            Navigator.pushNamed(context, createUpdateNotePageRoute);
            devtools.log("Pressed floating button");
          },
        ));
  }
}
