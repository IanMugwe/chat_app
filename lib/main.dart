import 'package:chat_app/core/utils/route_utils.dart';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/ui/screens/bottom_navigation/bottom_navigation_screen.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ychat_auth/ychat_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bootstrap Firebase & Firestore settings using ychat_auth bootstrap
  await FirebaseBootstrap.initialize(
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
          ChangeNotifierProvider(
            create: (context) => YUserProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => UserProvider(context.read<YUserProvider>()),
          ),
        ],
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
          home: YChatAuthWrapper(
            homeBuilder: (context, profile) => const BottomNavigationScreen(),
          ),
        ),
      ),
    );
  }
}