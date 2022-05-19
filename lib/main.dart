import 'package:flutter/material.dart';
import 'package:flutter_application_2/navigation/screens/workboards/create_update_workboard_view.dart';
import 'package:flutter_application_2/navigation/screens/workboards/workboard_view.dart';
import 'package:flutter_application_2/services/auth/auth_service.dart';
import 'package:flutter_application_2/views/login_view.dart';
import 'package:flutter_application_2/views/register_view.dart';
import 'package:flutter_application_2/views/screen_layout.dart';
import 'package:flutter_application_2/views/verify_email_view.dart';
import 'constants/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF801E48),
          secondary: const Color(0xFF801E48),
        ),
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const Loginview(),
        registerRoute: (context) => const RegisterView(),
        myHomeRoute: (context) => const HomeView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUpdateWorkBoardRoute: (context) =>
            const createOrUpdateWorkBoardView(),
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
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const MobileScreenLayout();
                //return const Text('email is verified');
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const Loginview();
            }
          default:
            return const Scaffold(
                body: Center(
              child: CircularProgressIndicator(),
            ));
        }
      },
    );
  }
}
