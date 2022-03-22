import 'package:flutter/material.dart';
import 'package:flutter_application_2/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Log out',
    content: 'Are you sure you want to Log out?', 
    optionsBuilder:() =>{
      'Cancel' : false,
      'Log Out' :true,
    },
  ).then((value) => value ?? false);
}