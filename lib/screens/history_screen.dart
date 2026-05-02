import 'package:flutter/material.dart';
import '../utils/app_settings.dart';
import '../utils/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
        title: Text('History',
            style: TextStyle(color: context.text, fontSize: 18,
                fontWeight: FontWeight.w600)),
        actions: [
          ValueListenableBuilder<List<HistoryEntry>>(
            valueListenable: AppSettings.instance.history,
            builder: (_, entries, __) => entries.isEmpty
                ? const SizedBox()
                : TextButton(
                    onPressed: () => _confirmClear(context),
                    child: const Text('Clear all',
                        style: TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
                  ),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<HistoryEntry>>(
        valueListenable: AppSettings.instance.history,
        builder: (_, entries, __) {
          if (entries.isEmpty) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: context.card,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.history_rounded,
                      size: 36, color: context.textSub),
                ),
                const SizedBox(height: 16),
                Text('No history yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                        color: context.text)),
                const SizedBox(height: 8),
                Text('Your recent calculations will appear here',
                    style: TextStyle(fontSize: 13, color: context.textSub)),
              ],
            ));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final e = entries[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calculate_rounded,
                        size: 20, color: Color(0xFF6366F1)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.calculator,
                          style: TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w600, color: context.text)),
                      const SizedBox(height: 2),
                      Text(e.detail,
                          style: TextStyle(fontSize: 11, color: context.textSub)),
                    ],
                  )),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(e.result,
                        style: const TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w700, color: Color(0xFF22C55E))),
                    const SizedBox(height: 2),
                    Text(_timeAgo(e.time),
                        style: TextStyle(fontSize: 10, color: context.textSub)),
                  ]),
                ]),
              );
            },
          );
        },
      ),
    );
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear All History',
            style: TextStyle(color: context.text, fontSize: 16)),
        content: Text('This will remove all calculation history.',
            style: TextStyle(color: context.textSub, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: context.textSub))),
          TextButton(
              onPressed: () {
                AppSettings.instance.clearHistory();
                Navigator.pop(context);
              },
              child: const Text('Clear',
                  style: TextStyle(color: Color(0xFFEF4444)))),
        ],
      ),
    );
  }
}
