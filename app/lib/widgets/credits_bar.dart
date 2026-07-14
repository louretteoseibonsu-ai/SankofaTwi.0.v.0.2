import 'package:flutter/material.dart';
import '../services/credits_service.dart';
import '../theme.dart';

/// Compact monthly-credits indicator with a top-up shortcut. Shared by the
/// metered features (AI Translate, Sankofa Lens) so the UX stays consistent.
class CreditsBar extends StatelessWidget {
  final CreditStatus status;
  final String unit; // e.g. 'translate credits', 'Lens scans'
  final Future<void> Function() onBuy;
  const CreditsBar({
    super.key,
    required this.status,
    required this.unit,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final low = status.remaining <= 3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: low ? accentCoral : silverLight, width: low ? 1.4 : 1),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt, size: 18, color: low ? accentCoral : plantainGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${status.remaining} $unit left this month'
              '${status.extra > 0 ? ' (+${status.extra} bought)' : ''}',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 12.5, color: ink),
            ),
          ),
          TextButton(
            onPressed: () => onBuy(),
            child: const Text('Buy more'),
          ),
        ],
      ),
    );
  }
}
