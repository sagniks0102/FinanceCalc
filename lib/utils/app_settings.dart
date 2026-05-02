import 'package:flutter/material.dart';

/// Global app settings — use AppSettings.instance to access anywhere.
class AppSettings {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  // Theme
  final themeMode = ValueNotifier<ThemeMode>(ThemeMode.dark);

  // Language
  final language = ValueNotifier<String>('English');

  static const Map<String, Locale> localeMap = {
    'English'  : Locale('en', 'US'),
    'Hindi'    : Locale('hi', 'IN'),
    'Gujarati' : Locale('gu', 'IN'),
    'Marathi'  : Locale('mr', 'IN'),
    'Tamil'    : Locale('ta', 'IN'),
    'Telugu'   : Locale('te', 'IN'),
  };

  Locale get currentLocale => localeMap[language.value] ?? const Locale('en', 'US');

  // Number format: 'indian' | 'international'
  final numberFormat = ValueNotifier<String>('indian');

  // Decimal places
  final decimalPlaces = ValueNotifier<int>(2);

  // History of recent calculations
  final history = ValueNotifier<List<HistoryEntry>>([]);

  void addHistory(HistoryEntry entry) {
    final list = List<HistoryEntry>.from(history.value);
    list.insert(0, entry);
    if (list.length > 50) list.removeLast(); // keep max 50
    history.value = list;
  }

  void clearHistory() {
    history.value = [];
  }

  // Combine listeners so screens can rebuild on language, number format, or decimal changes
  Listenable get updateListener => Listenable.merge([language, numberFormat, decimalPlaces]);

  // Private helper to add commas based on Indian vs International format
  String _addCommas(String whole) {
    final buf = StringBuffer();
    int c = 0;
    if (numberFormat.value == 'indian') {
      for (int i = whole.length - 1; i >= 0; i--) {
        if (c == 3 || (c > 3 && (c - 3) % 2 == 0)) buf.write(',');
        buf.write(whole[i]);
        c++;
      }
    } else {
      for (int i = whole.length - 1; i >= 0; i--) {
        if (c > 0 && c % 3 == 0) buf.write(',');
        buf.write(whole[i]);
        c++;
      }
    }
    return buf.toString().split('').reversed.join();
  }

  /// 1.5L / 2.5Cr with Rupee symbol (ignores decimal setting for brevity)
  String formatShort(double v) {
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(2)} Cr';
    if (v >= 100000)   return '₹${(v / 100000).toStringAsFixed(2)} L';
    if (v >= 1000)     return '₹${(v / 1000).toStringAsFixed(1)} K';
    return '₹${v.toStringAsFixed(0)}';
  }

  /// 1.5L / 2.5Cr without Rupee symbol
  String formatShortWord(double v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(2)}Cr';
    if (v >= 100000)   return '${(v / 100000).toStringAsFixed(2)}L';
    if (v >= 1000)     return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  /// Full number without Rupee symbol, respecting decimal places
  String formatNumber(double v, {bool noDecimals = false}) {
    final dp = noDecimals ? 0 : decimalPlaces.value;
    final s = v.toStringAsFixed(dp);
    final parts = s.split('.');
    final whole = _addCommas(parts[0]);
    final dec = parts.length > 1 && dp > 0 ? '.${parts[1]}' : '';
    return '$whole$dec';
  }

  /// Format a rupee value respecting current settings
  String formatRupee(double v, {bool noDecimals = false}) {
    return '₹ ${formatNumber(v, noDecimals: noDecimals)}';
  }
}

class HistoryEntry {
  final String calculator;
  final String result;
  final String detail;
  final DateTime time;
  const HistoryEntry({
    required this.calculator,
    required this.result,
    required this.detail,
    required this.time,
  });
}
