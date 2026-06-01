import 'package:flutter/material.dart';

/// Full-viewport launch splash — [light-logo] on #414A1E (no rounded clip).
class BrandedLaunchSplash extends StatelessWidget {
  const BrandedLaunchSplash({super.key});

  static const background = Color(0xFF414A1E);
  static const logoAsset = 'assets/branding/splash/light-logo.png';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: background,
      body: SizedBox.expand(
        child: Image(
          image: AssetImage(logoAsset),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
