import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/auth/auth_service.dart';
import 'package:flutter_application_2/services/crud/workboard_service.dart';
import 'package:flutter_application_2/utilities/dialogs/logout_dialog.dart';
import 'package:flutter_application_2/views/workboards/workboard_list_view.dart';
import 'dart:developer' as devtools show log;
import '../../enums/menu_action.dart';
import 'package:flutter_application_2/views/workboards/new_workboard_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _WorkBoardViewState();
}

class _WorkBoardViewState extends State<HomeView> {
  late final TextEditingController _textController;
  // List workboards = [];
  // String input = '';

  // get current user by email "userEmail"
  late final WorkBoardService _workboardsService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _workboardsService = WorkBoardService();
    _workboardsService.open();
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
          Padding(
            padding: const EdgeInsets.only(
              bottom: 0,
              left: 350.0,
              right: 0,
              top: 70.0,
            ),
            child: CircleAvatar(
              child: PopupMenuButton<MenuAction>(
                onSelected: (value) async {
                  switch (value) {
                    case MenuAction.logout:
                      final shouldLogout = await showLogOutDialog(context);
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
                color: Colors.blueGrey.shade50,
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              radius: 25,
            ),
          ),

          FutureBuilder(
            future: _workboardsService.getOrCreateWorkBoard(email: userEmail),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return StreamBuilder(
                      stream: _workboardsService.allWorkBoards,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.active:
                            if (snapshot.hasData) {
                              final allWorkboards =
                                  snapshot.data as List<DatabaseWorkBoard>;
                              return Expanded(
                                child: WorkboardsListView(
                                    workboards: allWorkboards,
                                    onDeleteWorkboard: (workboard) async {
                                      await _workboardsService.deleteWorkBoard(
                                          id: workboard.id);
                                    }),
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }

                          default:
                            return const CircularProgressIndicator();
                        }
                      });
                default:
                  return const CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
      //Floating button
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (_) => const newWorkBoardView(),
          );
          return result;
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
