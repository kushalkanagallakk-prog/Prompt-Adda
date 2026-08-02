import 'package:flutter/material.dart';

Future<void> showPremiumPromptDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: Colors.amber),
            SizedBox(width: 10),
            Expanded(child: Text('Premium Prompt')),
          ],
        ),
        content: const Text(
          'This prompt is available only for Premium users.\n\n'
          'Upgrade to unlock exclusive prompts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Maybe Later'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Google Play Billing later
            },
            icon: const Icon(Icons.workspace_premium_rounded),
            label: const Text('Upgrade'),
          ),
        ],
      );
    },
  );
}
