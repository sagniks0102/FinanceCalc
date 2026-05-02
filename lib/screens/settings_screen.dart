import 'package:flutter/material.dart';
import '../utils/app_settings.dart';
import '../utils/app_translations.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = AppSettings.instance;


  // ── Helpers ────────────────────────────────────────────────────────
  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 6),
    child: Text(label.tr,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: context.textSub, letterSpacing: 1.0)),
  );

  Widget _tile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) =>
      Column(children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(title.tr,
                  style: TextStyle(fontSize: 14, color: context.text))),
              Text(value,
                  style: TextStyle(fontSize: 13, color: context.textSub)),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: context.textSub),
            ]),
          ),
        ),
        Divider(height: 1, color: context.border,
            indent: 64, endIndent: 16),
      ]);

  Widget _actionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) =>
      Column(children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title.tr,
                      style: TextStyle(fontSize: 14, color: context.text)),
                  if (subtitle != null)
                    Text(subtitle.tr,
                        style: TextStyle(fontSize: 11, color: context.textSub)),
                ],
              )),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: context.textSub),
            ]),
          ),
        ),
        Divider(height: 1, color: context.border,
            indent: 64, endIndent: 16),
      ]);

  // ── Pickers ────────────────────────────────────────────────────────
  void _showPicker<T>(
      String title, List<T> options, T current,
      String Function(T) label, ValueChanged<T> onSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40, height: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: context.textSub,
              borderRadius: BorderRadius.circular(2)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Text(title.tr,
              style: TextStyle(color: context.text, fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ),
        ...options.map((opt) => InkWell(
          onTap: () { onSelected(opt); Navigator.pop(context); },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(children: [
              Expanded(child: Text(label(opt),
                  style: TextStyle(
                      color: opt == current
                          ? const Color(0xFF3B82F6)
                          : context.textSub,
                      fontSize: 14))),
              if (opt == current)
                const Icon(Icons.check, size: 18, color: Color(0xFF3B82F6)),
            ]),
          ),
        )),
        const SizedBox(height: 24),
      ]),
    );
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear History'.tr,
            style: TextStyle(color: context.text, fontSize: 16)),
        content: Text(
            'All calculation history will be permanently deleted.'.tr,
            style: TextStyle(color: context.textSub, fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(color: context.textSub))),
          TextButton(
              onPressed: () {
                _settings.clearHistory();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('✓ History cleared'),
                  backgroundColor: context.card,
                ));
              },
              child: const Text('Clear',
                  style: TextStyle(color: Color(0xFFEF4444)))),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode m) {
    switch (m) {
      case ThemeMode.system: return 'System Default';
      case ThemeMode.light:  return 'Light';
      case ThemeMode.dark:   return 'Dark';
    }
  }

  String _fmtLabel(String f) =>
      f == 'indian' ? '12,34,567.89' : '1,234,567.89';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.text.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: context.text, size: 20),
          ),
        ),
        title: Text('Settings'.tr,
            style: TextStyle(color: context.text, fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: _settings.language,
        builder: (_, lang, __) => ValueListenableBuilder<ThemeMode>(
          valueListenable: _settings.themeMode,
          builder: (_, theme, __) => ValueListenableBuilder<String>(
            valueListenable: _settings.numberFormat,
            builder: (_, fmt, __) => ValueListenableBuilder<int>(
              valueListenable: _settings.decimalPlaces,
              builder: (_, dp, __) => ListView(children: [
                _sectionLabel('GENERAL'),
                _tile(
                  icon: Icons.language_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: 'Language',
                  value: lang,
                  onTap: () => _showPicker<String>(
                    'Select Language',
                    ['English', 'Hindi'],
                    lang,
                    (s) => s,
                    (v) {
                      _settings.language.value = v;
                      _snack('🌐 Language set to $v — system locale applied');
                    },
                  ),
                ),
              // Language note
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(children: [
                  Icon(Icons.info_outline, size: 13, color: context.textSub),
                  const SizedBox(width: 6),
                  Expanded(child: Text(
                    'Basic translations applied. System components update immediately.'.tr,
                    style: TextStyle(fontSize: 10, color: context.textSub, height: 1.4),
                  )),
                ]),
              ),
              _tile(
                icon: Icons.tag_rounded,
                iconColor: const Color(0xFF3B82F6),
                title: 'Number Format',
                value: _fmtLabel(fmt),
                onTap: () => _showPicker<String>(
                  'Number Format',
                  ['indian', 'international'],
                  fmt,
                  _fmtLabel,
                  (v) {
                    _settings.numberFormat.value = v;
                    _snack('Number format updated');
                  },
                ),
              ),
              _tile(
                icon: Icons.pin_rounded,
                iconColor: const Color(0xFF3B82F6),
                title: 'Decimal Places',
                value: '$dp',
                onTap: () => _showPicker<int>(
                  'Decimal Places',
                  [0, 1, 2, 3],
                  dp,
                  (i) => i.toString(),
                  (v) {
                    _settings.decimalPlaces.value = v;
                    _snack('Decimal places updated');
                  },
                ),
              ),
              _tile(
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFF8B5CF6),
                title: 'Appearance',
                value: _themeLabel(theme),
                onTap: () => _showPicker<ThemeMode>(
                  'Appearance',
                  [ThemeMode.system, ThemeMode.light, ThemeMode.dark],
                  theme,
                  _themeLabel,
                  (v) {
                    _settings.themeMode.value = v;
                    _snack('Theme changed to ${_themeLabel(v)}');
                  },
                ),
              ),
              // _actionTile(
              //   icon: Icons.history_rounded,
              //   iconColor: const Color(0xFFEF4444),
              //   title: 'Clear History',
              //   subtitle: 'Delete all saved calculations',
              //   onTap: _clearHistory,
              // ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: context.card,
      duration: const Duration(seconds: 2),
    ));
  }
}
