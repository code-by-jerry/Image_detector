import 'package:flutter/material.dart';

import '../services/locale_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.localeService,
    this.compact = false,
  });

  final LocaleService localeService;
  final bool compact;

  static const _nativeLabels = <String, String>{
    'en': 'English',
    'hi': 'हिन्दी',
    'te': 'తెలుగు',
  };

  static const _shortCodes = <String, String>{
    'en': 'EN',
    'hi': 'HI',
    'te': 'TE',
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localeService,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final current = localeService.locale.languageCode;

        return PopupMenuButton<String>(
          tooltip: l10n.languageLabel,
          offset: const Offset(0, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (code) => localeService.setLocale(Locale(code)),
          itemBuilder: (context) => [
            _item(_nativeLabels['en']!, 'en', current),
            _item(_nativeLabels['hi']!, 'hi', current),
            _item(_nativeLabels['te']!, 'te', current),
          ],
          child: compact ? _CompactToggle(code: current) : _IconToggle(),
        );
      },
    );
  }

  PopupMenuItem<String> _item(String label, String code, String current) {
    final selected = code == current;
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: selected
                ? const Icon(Icons.check_rounded, size: 18, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.translate_rounded, size: 22);
  }
}

class _CompactToggle extends StatelessWidget {
  const _CompactToggle({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final short = LanguageSelector._shortCodes[code] ?? code.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.language_rounded,
            size: 17,
            color: AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            short,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
