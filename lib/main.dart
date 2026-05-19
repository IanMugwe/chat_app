import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/core/utils/route_utils.dart';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/providers/ui_theme_provider.dart';

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
      builder: (context, child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => UserProvider(DatabaseService())),
          ChangeNotifierProvider(create: (context) => UiThemeProvider()),
        ],
        child: Consumer<UiThemeProvider>(
          builder: (context, uiTheme, child) {
            final active = uiTheme.activePreset;
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primaryColor: active.primaryAccent,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: active.primaryAccent,
                  primary: active.primaryAccent,
                  secondary: active.primaryAccent,
                  brightness: active.isDark ? Brightness.dark : Brightness.light,
                  surface: active.isDark ? const Color(0xFF121212) : Colors.white,
                ),
                appBarTheme: AppBarTheme(
                  backgroundColor: active.isDark ? const Color(0xFF121212) : Colors.white,
                  foregroundColor: active.primaryAccent,
                  elevation: 0,
                  centerTitle: true,
                  iconTheme: IconThemeData(color: active.primaryAccent),
                ),
                scaffoldBackgroundColor: active.isDark ? const Color(0xFF121212) : Colors.white,
                useMaterial3: true,
              ),
              onGenerateRoute: RouteUtils.onGenerateRoute,
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}