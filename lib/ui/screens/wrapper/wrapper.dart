import 'dart:developer';

import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/ui/screens/auth/login/login_screen.dart';
import 'package:chat_app/ui/screens/bottom_navigation/bottom_navigation_screen.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    log("Wrapper Screen");
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primary),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Something went wrong!")),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          log("User logged out");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<UserProvider>(context, listen: false).clearUser();
          });
          return const LoginScreen();
        } else {
          log("User logged in, awaiting details...");
          return Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              if (userProvider.user == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  userProvider.loadUser(user.uid);
                });
                return const Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                    ),
                  ),
                );
              }
              return const BottomNavigationScreen();
            },
          );
        }
      },
    );
  }
}
