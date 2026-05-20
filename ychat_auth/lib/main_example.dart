import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ychat_auth/ychat_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => YUserProvider(),
      child: const YChatApp(),
    ),
  );
}

class YChatApp extends StatelessWidget {
  const YChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'yCHAT',
      debugShowCheckedModeBanner: false,
      theme: yChatDarkTheme(),
      home: YChatAuthWrapper(
        homeBuilder: (_, profile) => BottomNavigationScreen(profileName: profile.name),
      ),
    );
  }
}

// Replace this placeholder with your existing BottomNavigationScreen.
class BottomNavigationScreen extends StatelessWidget {
  const BottomNavigationScreen({super.key, required this.profileName});
  final String profileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Welcome $profileName')));
  }
}
