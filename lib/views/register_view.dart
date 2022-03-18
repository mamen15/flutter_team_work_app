import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as devtools show log;

import 'package:flutter_application_2/constants/routes.dart';
import 'package:flutter_application_2/utilities/show_error_dialog.dart';


class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),),
      body:  Column(
                children: [
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        hintText: 'Enter your Email here'),
                  ),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        hintText: 'Enter your password here'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;
                      try {
                         await FirebaseAuth.instance
                         .createUserWithEmailAndPassword(
                                email: email, 
                                password: password);
                        final user =  FirebaseAuth.instance.currentUser;
                        await user?.sendEmailVerification();        
                        Navigator.of(context).pushNamed(VerifyEmailRoute);
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          showErrorDialog(context,'password is weak');
                        } else if (e.code == "email-already-in-use") {
                          showErrorDialog(context,
                              'The email address is already in use by another account.');
                        } else if (e.code == "invalid-email") {
                          showErrorDialog(context,'Invalid Email');
                          
                        } else {
                      await showErrorDialog(
                      context,
                      'Error : ${e.code}');
                      }
                     }  catch (e){                      
                          await showErrorDialog(
                          context,
                          e.toString(),
                          );
                        } 
                    },
                    child: const Text('Register'),
                  ),
                  TextButton(
                    onPressed: () {
                     Navigator.of(context).pushNamedAndRemoveUntil(
                     LoginRoute,
                     (route) => false,
                     );
           
                    } ,
                    child: const Text('Login if u already have an account'))
                ],
              )
  );
   } 
}   