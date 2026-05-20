import 'dart:async';

import 'package:chat_app/core/constants/string.dart';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Perform check after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // User is not logged in, transition after a short delay for splash logo visibility
        _timer = Timer(const Duration(milliseconds: 800), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, wrapper);
          }
        });
      } else {
        // User is logged in, start pre-loading user profile in parallel
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        Future.wait([
          userProvider.loadUser(user.uid),
          Future.delayed(const Duration(milliseconds: 800)), // minimum delay for logo render
        ]).timeout(const Duration(seconds: 4)).then((_) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, wrapper);
          }
        }).catchError((_) {
          // Fallback if network fails
          if (mounted) {
            Navigator.pushReplacementNamed(context, wrapper);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    logo,
                    height: 140.r,
                    width: 140.r,
                    fit: BoxFit.contain,
                  ),
                  20.verticalSpace,
                  Text(
                    'yCHAT',
                    style: h.copyWith(
                      color: primary,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 40.h),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
