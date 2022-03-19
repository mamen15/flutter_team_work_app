
import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/auth/auth_service.dart';

import '../constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: const Text('Email verification')),
      body: Center(
        child: Column(
              children: [
                const Text("We've sent you an email verification. Please open it to verify your account."),
                const Text("if you haven't received an email verification yet, please press the button below"),
                TextButton(
                  onPressed: () async {
                     AuthService.firebase().currentUser;
                    },
                  child: const Text('Send email verification'), 
                ),
                TextButton(onPressed: () async {
                  await AuthService.firebase().logOut();
                  Navigator.of(context)
                  .pushNamedAndRemoveUntil(
                    RegisterRoute, 
                    (route) => false);
                }, 
                child: const Text('Go back!'))
              ],
            ),
      ),
    );
  }
}