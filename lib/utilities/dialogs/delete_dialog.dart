import 'package:flutter/material.dart';
import 'package:flutter_application_2/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to Delete this item?', 
    optionsBuilder:() =>{
      'Cancel' : false,
      'Log Out' : true,
    },
  ).then((value) => value ?? false);
}