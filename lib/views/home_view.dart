import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/auth/auth_service.dart';
import 'dart:developer' as devtools show log;

import '../enums/menu_action.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _NotesViewState();
}

class _NotesViewState extends State<HomeView> {
  List workboards = [];
  String input = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title: const Text("Main UI"),
//        actions: [
      body: Column(
        children: [
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
          Expanded(
            child: ListView.builder(
                itemCount: workboards.length,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    key: Key(workboards[index]),
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.all(5),
                      key: Key(workboards[index]),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        title: Text(workboards[index]),
                        trailing: IconButton(
                          onPressed: () {
                            setState(() {
                              workboards.removeAt(index);
                            });
                          },
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text("Add a Workboard"),
                content: Container(
                  width: double.infinity,
                  height: 100,
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (String value) {
                          input = value;
                        },
                        decoration: const InputDecoration(
                            hintText: "Enter your workboard's name"),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              workboards.add(input);
                              Navigator.of(context).pop();
                            });
                          },
                          child: const Text('Add your Workboard Daddy <3')),
                    ],
                  ),
                ),
              );
            },
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to Log out?'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Log out')),
        ],
      );
    },
  ).then((value) => value ?? false);
}
