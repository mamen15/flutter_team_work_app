import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/constants/routes.dart';
import 'package:flutter_application_2/services/auth/auth_service.dart';
import 'package:flutter_application_2/services/cloud/cloud_app.dart';
import 'package:flutter_application_2/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_application_2/utilities/dialogs/logout_dialog.dart';
import 'package:flutter_application_2/views/workboards/workboard_list_view.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:developer' as devtools show log;
import '../../enums/menu_action.dart';
import 'package:flutter_application_2/views/workboards/create_update_workboard_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _WorkBoardViewState();
}

class _WorkBoardViewState extends State<HomeView> {
  // get current user by email "userEmail"
  late final FirebaseCloudStorage _workboardsService;
  String get userId => AuthService.firebase().currentUser!.id;
  String username = "";

  @override
  void initState() {
    _workboardsService = FirebaseCloudStorage();
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
  // @override
  // void dispose() {
  //   _workboardsService.close();
  //   super.dispose();
  // }
int page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title: const Text("Main UI"),
//        actions: [
      body: Column(
        children: [
          Flexible(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 0,
                    left: 50,
                    right: 240,
                    top: 50,
                  ),
                  child: Text('hey $username'),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    top: 53,
                  ),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF801E48),
                    child: PopupMenuButton<MenuAction>(
                      onSelected: (value) async {
                        switch (value) {
                          case MenuAction.logout:
                            final shouldLogout =
                                await showLogOutDialog(context);
                            devtools.log(shouldLogout.toString());
                            if (shouldLogout) {
                              await AuthService.firebase().logOut();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login/',
                                (_) => false,
                              );
                            }
                        }
                      },
                      itemBuilder: (context) => <PopupMenuEntry<MenuAction>>[
                        const PopupMenuItem<MenuAction>(
                          value: MenuAction.logout,
                          child: Text('Log out'),
                        ),
                      ],
                      color: Colors.white,
                      offset: const Offset(0, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    radius: 25,
                  ),
                ),
              ],
            ),
          ),
          // logout menu

          StreamBuilder(
              stream: _workboardsService.allWorkboards(ownerUserId: userId),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    if (snapshot.hasData) {
                      final allWorkboards =
                          snapshot.data as Iterable<CloudWorkboard>;
                      return Expanded(
                        child: WorkboardsListView(
                            onUpdate: (workBoard) {
                              Navigator.of(context).pushNamed(
                                createOrUpdateWorkBoardRoute,
                                arguments: workBoard,
                              );
                            },
                            workboards: allWorkboards,
                            onDeleteWorkboard: (workboard) async {
                              await _workboardsService.deleteWorkboard(
                                documentId: workboard.documentId,
                              );
                            }),
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }

                  default:
                    return const CircularProgressIndicator();
                }
              })
        ],
      ),

      //Floating button
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: const IconThemeData(size: 22),
        backgroundColor: const Color(0xFF801E48),
        visible: true,
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
              child: const Icon(Icons.add),
              backgroundColor: const Color(0xFF801E48),
              onTap: () async {
                final result = await showDialog(
                  context: context,
                  builder: (_) => const createOrUpdateWorkBoardView(),
                );
                return result;
              },
              label: 'Add a workboard',
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 16.0),
              labelBackgroundColor: const Color(0xFF801E48)),
          // FAB 1
          SpeedDialChild(
              child: const Icon(Icons.share),
              backgroundColor: const Color(0xFF801E48),
              onTap: () {
                /* do anything */
              },
              label: 'share your workboards',
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 16.0),
              labelBackgroundColor: const Color(0xFF801E48)),
          // FAB 2
        ],
      ),
      
    );
  }
}
