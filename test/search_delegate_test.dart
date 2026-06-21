import 'package:flutter_test/flutter_test.dart';
import 'package:emi_calculator/widgets/calculator_search_delegate.dart';
import 'package:emi_calculator/utils/app_translations.dart';

void main() {
  test('Search delegate matches abbreviations and full names', () {
    // Instantiate the search delegate.
    // Note: since we pass a dummy callback for onNavigate, it's fine.
    final delegate = CalculatorSearchDelegate(onNavigate: (_, {showAd = true}) {});

    // Helper to run matching logic on delegate's calculators list
    List<Map<String, dynamic>> search(String query) {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return delegate.calculators;

      return delegate.calculators.where((c) {
        final name = (c['name'] as String).toLowerCase();
        final trName = (c['name'] as String).tr.toLowerCase();

        // Check main name and translated name
        if (name.contains(q) || trName.contains(q)) return true;

        // Check keywords/aliases
        final keywords = c['keywords'] as List<String>?;
        if (keywords != null) {
          for (final keyword in keywords) {
            final kwLower = keyword.toLowerCase();
            if (kwLower.contains(q) || q.contains(kwLower)) {
              return true;
            }
          }
        }
        return false;
      }).toList();
    }

    // 1. Search for SIP
    final sipResults = search('sip');
    expect(sipResults.any((c) => c['name'] == 'SIP Calculator'), isTrue);

    // 2. Search for Systematic investment plan
    final fullSipResults = search('Systematic investment plan');
    expect(fullSipResults.any((c) => c['name'] == 'SIP Calculator'), isTrue);

    // 3. Search for FD
    final fdResults = search('fd');
    expect(fdResults.any((c) => c['name'] == 'FD Calculator'), isTrue);

    // 4. Search for Fixed Deposit
    final fullFdResults = search('Fixed Deposit');
    expect(fullFdResults.any((c) => c['name'] == 'FD Calculator'), isTrue);

    // 5. Search for PPF
    final ppfResults = search('ppf');
    expect(ppfResults.any((c) => c['name'] == 'PPF Calculator'), isTrue);

    // 6. Search for Public Provident Fund
    final fullPpfResults = search('Public Provident Fund');
    expect(fullPpfResults.any((c) => c['name'] == 'PPF Calculator'), isTrue);
  });
}
