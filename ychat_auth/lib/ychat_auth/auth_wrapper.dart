import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/y_user_profile.dart';
import 'providers/y_user_provider.dart';
import 'screens/auth_error_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/ychat_auth_theme.dart';

class YChatAuthWrapper extends StatefulWidget {
   const YChatAuthWrapper({super.key, required this.homeBuilder});

   final Widget Function(BuildContext context, YUserProfile profile) homeBuilder;

   @override
   State<YChatAuthWrapper> createState() => _YChatAuthWrapperState();
}

class _YChatAuthWrapperState extends State<YChatAuthWrapper> {
   bool started = false;

   @override
   void didChangeDependencies() {
     super.didChangeDependencies();
     if (started) return;
     started = true;
     WidgetsBinding.instance.addPostFrameCallback((_) {
       if (!mounted) return;
       context.read<YUserProvider>().start();
     });
   }

   @override
   Widget build(BuildContext context) {
     final provider = context.watch<YUserProvider>();

     Widget screen;
     switch (provider.state) {
       case AuthGateState.booting:
         screen = const SplashScreen();
         break;
       case AuthGateState.unauthenticated:
         screen = const LoginScreen();
         break;
       case AuthGateState.emailNotVerified:
         screen = const EmailVerificationScreen();
         break;
       case AuthGateState.authenticated:
         final profile = provider.profile;
         if (profile == null) {
           return Theme(
             data: yChatLightTheme(),
             child: const SplashScreen(message: 'Loading profile...'),
           );
         }
         return widget.homeBuilder(context, profile);
       case AuthGateState.error:
         screen = AuthErrorScreen(message: provider.errorMessage ?? 'Unable to start authentication.');
         break;
     }

     return Theme(
       data: yChatLightTheme(),
       child: screen,
     );
   }
}

