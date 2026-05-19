import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/core/utils/route_utils.dart';
import 'package:chat_app/core/constants/colors.dart';

import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:chat_app/ui/screens/splash/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) => ChangeNotifierProvider(
        create: (context) => UserProvider(DatabaseService()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: primary,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primary,
              primary: primary,
              secondary: primary,
              surface: Colors.white,
              onPrimary: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: primary,
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(color: primary),
            ),
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
          ),
          onGenerateRoute: RouteUtils.onGenerateRoute,
          home: SplashScreen(),
        ),
      ),
    );
  }
}