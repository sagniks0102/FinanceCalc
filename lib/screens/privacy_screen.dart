import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

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
        title: Text('Privacy Policy',
            style: TextStyle(color: context.text, fontSize: 20,
                fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _header(context, 'Finance Calculator — Privacy Policy'),
          _updated(context, 'Last updated: June 28, 2026'),
          const SizedBox(height: 20),
          _section(context, '1. Information We Collect', [
            'All financial calculations are performed entirely on your device.',
            'No personal information (name, email, phone) is collected by us.',
            'No account creation is required to use this app.',
          ]),
          _section(context, '2. Local Storage', [
            'Your settings preferences (theme, number format, language) are stored locally on your device using SharedPreferences.',
            'Premium purchase status is stored locally for offline access.',
            'You can clear locally stored data by clearing the app data from your device settings.',
          ]),
          _section(context, '3. Third-Party Services', [
            'This app integrates the following third-party services that may collect data as described in their respective privacy policies:',
            '• Google AdMob — serves advertisements and may collect device identifiers, IP address, and ad interaction data. See: https://policies.google.com/privacy',
            '• Firebase Analytics — collects anonymized usage data such as screen views, session duration, and device information. See: https://firebase.google.com/support/privacy',
            '• Firebase Crashlytics — collects crash logs, stack traces, and device information to help us fix bugs. See: https://firebase.google.com/support/privacy',
            '• Firebase Remote Config — fetches configuration values from our servers. No personal data is transmitted.',
            '• Google Play Billing — processes in-app purchases through Google Play. Purchase data is handled by Google. See: https://policies.google.com/privacy',
          ]),
          _section(context, '4. Advertising', [
            'This app displays ads served by Google AdMob.',
            'AdMob may use device advertising identifiers to serve personalized or non-personalized ads based on your preferences.',
            'You can opt out of personalized ads through your device\'s ad settings.',
            'Premium users who purchase "Remove All Ads" will not see any advertisements.',
          ]),
          _section(context, '5. Permissions', [
            'INTERNET — Required for loading advertisements, crash reporting, and in-app purchases.',
            'ACCESS_NETWORK_STATE — Used to check network connectivity before making network requests.',
            'No access to camera, microphone, contacts, location, or storage is required.',
          ]),
          _section(context, '6. Children\'s Privacy', [
            'This app is suitable for all ages.',
            'We do not knowingly collect any personal information from children under 13.',
            'Ads served to children comply with Google\'s policies for child-directed content.',
          ]),
          _section(context, '7. Data Retention & Deletion', [
            'We do not store any user data on our servers.',
            'Third-party services (Google) may retain data according to their own retention policies.',
            'You can reset all locally stored data by clearing the app\'s data or uninstalling the app.',
          ]),
          _section(context, '8. Changes to This Policy', [
            'We may update our Privacy Policy from time to time.',
            'Changes will be reflected by updating the "Last updated" date above.',
            'Continued use of the app after changes constitutes acceptance of the updated policy.',
          ]),
          _section(context, '9. Contact Us', [
            'If you have questions about this Privacy Policy, please contact us.',
            'Email: appnexivo@gmail.com',
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, String text) => Text(text,
      style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700, color: context.text));

  Widget _updated(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(text,
            style: TextStyle(fontSize: 12, color: context.textSub)),
      );

  Widget _section(
          BuildContext context, String title, List<String> points) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6366F1))),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: points
                  .map((p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!p.startsWith('•')) const Text('• ',
                                  style: TextStyle(
                                      color: Color(0xFF6366F1),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              Expanded(
                                  child: Text(p.startsWith('• ') ? p.substring(2) : p,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: context.textSub,
                                          height: 1.5))),
                            ]),
                      ))
                  .toList(),
            ),
          ),
        ],
      );
}
