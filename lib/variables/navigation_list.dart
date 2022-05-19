import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/navigation/screens/chat.dart';
import 'package:flutter_application_2/navigation/screens/profile.dart';
import '../navigation/screens/workboards/workboard_view.dart';

List<Widget> homeScreenItems = [
  const HomeView(),
  const ChatScreen(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
