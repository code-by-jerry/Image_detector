import 'package:flutter/material.dart';

/// Launch splash — `spash-logo.png` centered, full width, height auto.
class BrandedLaunchSplash extends StatelessWidget {
  const BrandedLaunchSplash({super.key});

  static const background = Color(0xFFFAF8F2);
  static const logoAsset = 'assets/branding/splash/spash-logo.png';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: background,
      body: Center(
        child: _SplashLogo(),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Image.asset(
        BrandedLaunchSplash.logoAsset,
        width: width - 40,
        fit: BoxFit.fitWidth,
        alignment: Alignment.center,
      ),
    );
  }
}
