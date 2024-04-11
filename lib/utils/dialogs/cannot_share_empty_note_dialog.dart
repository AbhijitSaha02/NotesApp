import 'package:flutter/material.dart';
import 'package:notes_app/utils/generics/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: 'Sharing',
      content: 'Cannot share an empty note!',
      optionsBuilder: () => {
            'OK': null,
          });
}
