import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;
  final String abbreviation;
  final Color badgeColor;

  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.abbreviation,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: context.text,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    abbreviation,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              // Coming Soon badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [badgeColor, badgeColor.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Description
              Text(
                'This calculator is under development.\nIt will be available in a future update.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.textSub,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              // Icon
              Icon(
                Icons.construction_rounded,
                size: 48,
                color: context.textSub.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
