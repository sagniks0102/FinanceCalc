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
          child: Icon(Icons.arrow_back, color: context.text),
        ),
        title: Text('Privacy Policy',
            style: TextStyle(color: context.text, fontSize: 20,
                fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _header(context, 'Financial Calculator Suite — Privacy Policy'),
          _updated(context, 'Last updated: May 1, 2026'),
          const SizedBox(height: 20),
          _section(context, '1. Information We Collect', [
            'This app does NOT collect any personal information.',
            'All calculations are performed entirely on your device.',
            'No data is transmitted to any server.',
            'No account creation is required.',
          ]),
          _section(context, '2. Local Storage', [
            'Calculation history is stored locally on your device only.',
            'Settings preferences are stored locally on your device.',
            'You can clear all stored data from Settings → Clear History.',
          ]),
          _section(context, '3. Third-Party Services', [
            'This app does not integrate any analytics, advertising, or tracking SDKs.',
            'No third-party SDKs have access to your data.',
          ]),
          _section(context, '4. Permissions', [
            'This app does not request any special device permissions.',
            'No access to camera, microphone, contacts, or location is required.',
          ]),
          _section(context, '5. Children\'s Privacy', [
            'This app is suitable for all ages.',
            'We do not knowingly collect any information from children under 13.',
          ]),
          _section(context, '6. Changes to This Policy', [
            'We may update our Privacy Policy from time to time.',
            'Changes will be reflected by updating the "Last updated" date.',
            'Continued use of the app after changes constitutes acceptance.',
          ]),
          _section(context, '7. Contact Us', [
            'If you have questions about this Privacy Policy, please contact us.',
            'Email: support@fincalc.app',
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
                              const Text('• ',
                                  style: TextStyle(
                                      color: Color(0xFF6366F1),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              Expanded(
                                  child: Text(p,
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
