import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String id;
  final String? username;
  final String email;
  final bool isEmailVerified;
  final List followers;
  final List following;
  const AuthUser({
    required this.username,
    required this.id,
    required this.email,
    required this.isEmailVerified,
    required this.followers,
    required this.following,
  });
  factory AuthUser.fromFirebase(User user) => AuthUser(
        id: user.uid,
        username: user.displayName,
        isEmailVerified: user.emailVerified,
        email: user.email!,
        followers: [],
        following: [],
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'uid': id,
        'email': email,
        'followers': followers,
        'following': following,
      };
}
