import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          child: Column(
            children: [
              Image.asset(
                'assets/branding/logo/logo-3-display.png',
                width: double.infinity,
                height: 96,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.appTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.aboutTagline,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentGold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 32),
              _AboutTile(
                icon: Icons.visibility_outlined,
                title: l10n.aboutWhatWeDo,
                body: l10n.aboutWhatWeDoBody,
              ),
              const SizedBox(height: 12),
              _AboutTile(
                icon: Icons.pets_outlined,
                title: l10n.aboutBuiltFor,
                body: l10n.aboutBuiltForBody,
              ),
              const SizedBox(height: 12),
              _AboutTile(
                icon: Icons.info_outline,
                title: l10n.aboutVersion,
                body: '1.0.0',
              ),
              const SizedBox(height: 32),
              Text(
                l10n.aboutCopyright(DateTime.now().year),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
