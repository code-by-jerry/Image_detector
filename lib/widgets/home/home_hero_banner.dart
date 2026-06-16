import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full-width hero banners with natural image height (auto) and auto-slide.
class HomeHeroBanner extends StatefulWidget {
  const HomeHeroBanner({super.key});

  static const bannerAssets = [
    'assets/branding/banner/banner (1).png',
    'assets/branding/banner/banner (2).png',
    'assets/branding/banner/banner (3).png',
  ];

  @override
  State<HomeHeroBanner> createState() => _HomeHeroBannerState();
}

class _HomeHeroBannerState extends State<HomeHeroBanner> {
  static const _slideInterval = Duration(seconds: 4);
  static const _slideDuration = Duration(milliseconds: 600);

  late final PageController _controller;
  Timer? _autoTimer;
  double? _slideHeight;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _autoTimer = Timer.periodic(_slideInterval, (_) => _advance());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_slideHeight == null) {
      _resolveSlideHeight();
    }
  }

  Future<void> _resolveSlideHeight() async {
    final ratio = await _assetAspectRatio(HomeHeroBanner.bannerAssets.first);
    if (!mounted) return;
    final width = MediaQuery.sizeOf(context).width;
    setState(() => _slideHeight = width / ratio);
  }

  Future<double> _assetAspectRatio(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;
    return image.width / image.height;
  }

  void _advance() {
    if (!_controller.hasClients) return;
    final count = HomeHeroBanner.bannerAssets.length;
    if (count < 2) return;
    final current = _controller.page?.round() ?? _controller.initialPage;
    final next = (current + 1) % count;
    _controller.animateToPage(
      next,
      duration: _slideDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = _slideHeight ?? width * 0.56;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: width,
        height: height,
        child: PageView.builder(
          controller: _controller,
          itemCount: HomeHeroBanner.bannerAssets.length,
          itemBuilder: (context, index) {
            return Image.asset(
              HomeHeroBanner.bannerAssets[index],
              width: width,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) => Container(
                width: width,
                height: height,
                color: const Color(0xFFFAF8F2),
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            );
          },
        ),
      ),
    );
  }
}
