import 'package:flutter/material.dart';

import 'package:notes_app/utils/generics/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error has occured',
    content: text,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
