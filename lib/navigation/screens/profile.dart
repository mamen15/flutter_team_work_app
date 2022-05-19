import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/enums/menu_action.dart';
import 'package:flutter_application_2/services/auth/auth_service.dart';
import 'package:flutter_application_2/utilities/dialogs/logout_dialog.dart';
import 'dart:developer' as devtools show log;

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "";

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  void getUsername() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    setState(() {
      username = (snap.data() as Map<String, dynamic>)['username'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 40,
            left: 50,
            right: 50,
            top: 60,
          ),
          child: Text(
            username,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              // color: Colors.grey,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 0,
            left: 0,
            right: 0,
            top: 0,
          ),
          // child: CircleAvatar(
          //   backgroundColor: const Color(0xFF801E48),
          //   child: PopupMenuButton<MenuAction>(
          // onSelected: (value) async {
          //   switch (value) {
          // case MenuAction.logout:
          child: ElevatedButton(
            child: const Text('Log out'),
            onPressed: () async {
              final shouldLogout = await showLogOutDialog(context);
              devtools.log(shouldLogout.toString());
              if (shouldLogout) {
                await AuthService.firebase().logOut();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login/',
                  (_) => false,
                );
              }
            },
            //   itemBuilder: (context) => <PopupMenuEntry<MenuAction>>[
            //     const PopupMenuItem<MenuAction>(
            //       value: MenuAction.logout,
            //       child: Text('Log out'),
            //     ),
            //   ],
            //   color: Colors.white,
            //   offset: const Offset(0, 50),
            //   shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(16)),
            // ),
            // radius: 25,
          ),
        ),
      ],
    );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
