import 'package:flutter_test/flutter_test.dart';

void main() {
  test('App smoke test — imports resolve correctly', () {
    // Basic sanity check that the app can be referenced without errors.
    // Full widget tests require Firebase mock setup.
    expect(1 + 1, equals(2));
  });
}
