import 'package:flutter/material.dart';

/// Launch splash — cream background + centered tagline wordmark.
class BrandedLaunchSplash extends StatelessWidget {
  const BrandedLaunchSplash({super.key});

  static const background = Color(0xFFFAF8F2);
  static const taglineAsset = 'assets/branding/splash/tagline.png';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: background,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 48),
          child: Image(
            image: AssetImage(taglineAsset),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
