import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String id;
  final String? name;
  final String email;
  final bool isEmailVerified;
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.isEmailVerified,
  });
  factory AuthUser.fromFirebase(User user) => AuthUser(
        id: user.uid,
        isEmailVerified: user.emailVerified,
        email: user.email!,
        name: user.displayName,
      );
}
