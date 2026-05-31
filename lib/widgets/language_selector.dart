import 'package:flutter/material.dart';

import '../services/locale_service.dart';
import '../l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.localeService,
  });

  final LocaleService localeService;

  /// Always shown in each language's native script — never translated.
  static const _nativeLabels = <String, String>{
    'en': 'English',
    'hi': 'हिन्दी',
    'te': 'తెలుగు',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = localeService.locale?.languageCode ?? 'en';

    return PopupMenuButton<String>(
      tooltip: l10n.languageLabel,
      icon: const Icon(Icons.translate_rounded, size: 22),
      onSelected: (code) => localeService.setLocale(Locale(code)),
      itemBuilder: (context) => [
        _item(_nativeLabels['en']!, 'en', current),
        _item(_nativeLabels['hi']!, 'hi', current),
        _item(_nativeLabels['te']!, 'te', current),
      ],
    );
  }

  PopupMenuItem<String> _item(String label, String code, String current) {
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        children: [
          if (code == current)
            const Icon(Icons.check_rounded, size: 18)
          else
            const SizedBox(width: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
