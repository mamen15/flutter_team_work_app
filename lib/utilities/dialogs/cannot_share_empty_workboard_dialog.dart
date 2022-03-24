import 'package:flutter/material.dart';
import 'package:flutter_application_2/utilities/dialogs/generic_dialog.dart';


Future<void> showCannotShareEmptyWorkboardDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Sharing',
    content: 'You cannot share an empty Workboard!',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}