import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/constants/routes.dart';
import 'package:flutter_application_2/enums/menu_action.dart';
import 'package:flutter_application_2/navigation/screens/workboards/create_update_workboard_view.dart';
import 'package:flutter_application_2/navigation/screens/workboards/workboard_list_view.dart';
import 'package:flutter_application_2/services/auth/auth_service.dart';
import 'package:flutter_application_2/services/cloud/cloud_app.dart';
import 'package:flutter_application_2/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_application_2/utilities/dialogs/logout_dialog.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:developer' as devtools show log;


class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _WorkBoardViewState();
}

class _WorkBoardViewState extends State<HomeView> {
  // get current user by email "userEmail"
  late final FirebaseCloudStorage _workboardsService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _workboardsService = FirebaseCloudStorage();
    super.initState();
  }
  // @override
  // void dispose() {
  //   _workboardsService.close();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title: const Text("Main UI"),
//        actions: [
      body: Column(
        children: [
          
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
