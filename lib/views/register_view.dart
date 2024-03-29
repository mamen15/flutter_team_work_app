import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import 'package:flutter_application_2/constants/routes.dart';
import 'package:flutter_application_2/services/auth/auth_exceptions.dart';
import 'package:flutter_application_2/services/auth/auth_service.dart';
import 'package:flutter_application_2/utilities/dialogs/error_dialog.dart';
import 'package:flutter_application_2/utilities/dialogs/generic_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _username;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _username = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _username,
            enableSuggestions: false,
            autocorrect: false,
            decoration:
                const InputDecoration(hintText: 'Enter your username here'),
          ),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            enableSuggestions: false,
            autocorrect: false,
            decoration:
                const InputDecoration(hintText: 'Enter your Email here'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration:
                const InputDecoration(hintText: 'Enter your password here'),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              final username = _username.text;
              try {
                await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                  username: username,
                );
                AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(verifyEmailRoute);
              } on WeakPasswordAuthException {
                showErrorDialog(
                  context,
                  'password is weak',
                );
              } on EmailAlreadyInUsedAuthException {
                showErrorDialog(
                  context,
                  'The email address is already in use by another account.',
                );
              } on InvalidEmailAuthException {
                showErrorDialog(
                  context,
                  'Invalid Email',
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  'Failed to Register',
                );
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text('Login if u already have an account'))
        ],
      ),
    );
  }
}
