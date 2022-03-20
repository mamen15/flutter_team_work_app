import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/auth/auth_service.dart';
import 'package:flutter_application_2/views/login_view.dart';
import 'package:flutter_application_2/views/register_view.dart';
import 'package:flutter_application_2/views/verify_email_view.dart';
import 'package:flutter_application_2/views/workboards/new_workboard_view.dart';
import 'constants/routes.dart';
import 'views/workboards/workboard_view.dart';

void main() {
  
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const Loginview(),
        registerRoute :(context) => const RegisterView(),
        myHomeRoute :(context) => const HomeView(),
        verifyEmailRoute :(context) => const VerifyEmailView(),
        newWorkBoardRoute :(context) => const newWorkBoardView(),
      },
    ),
  );
}


class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
           switch (snapshot.connectionState) {
            case ConnectionState.done:
            final user = AuthService.firebase().currentUser ;
               if (user != null) {
                 if (user.isEmailVerified) {
                   return const HomeView();
                   //return const Text('email is verified');
                 }
                 else{
                   return const VerifyEmailView();
                 }
               } else {
                 return const Loginview();
               }
              default:
              return const Scaffold( 
                body: Center(
                  child : CircularProgressIndicator(),
                ) 
              );
          }
        },
      );
  }
}




