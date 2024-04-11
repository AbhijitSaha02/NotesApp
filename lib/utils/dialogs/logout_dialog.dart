import 'package:flutter/material.dart';

import 'package:notes_app/utils/generics/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Sign Out',
    content: 'Are you sure to sign out?',
    optionsBuilder: () => {
      'Cancel': false,
      'Sign Out': true,
    },
  ).then((value) => value ?? false);
}
