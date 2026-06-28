import 'package:flutter/material.dart';
import '../data/adinkra_symbols.dart';
import '../theme.dart';
import '../widgets/adinkra_glyph.dart';
import '../widgets/floating_card.dart';

class SymbolsScreen extends StatelessWidget {
  const SymbolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            'Adinkra Symbols',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 26, color: ink),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Text(
            'Ancestral wisdom in visual form.',
            style: TextStyle(color: inkSoft, fontSize: 14.5),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: kAdinkraSymbols.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, i) {
              final s = kAdinkraSymbols[i];
              return FloatingCard(
                onTap: () => _showDetail(context, s),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: glyphTile,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: AdinkraGlyph(svg: s.svg, size: 48),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 17, color: ink),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.value,
                            style: const TextStyle(
                                color: plantainGreen, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.black26),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDetail(BuildContext context, AdinkraSymbol s) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: glyphTile,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: AdinkraGlyph(svg: s.svg, size: 88),
              ),
            ),
            const SizedBox(height: 16),
            Text(s.name,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: ink)),
            Text('"${s.literal}"',
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54)),
            const SizedBox(height: 8),
            Text(s.value,
                style: const TextStyle(color: plantainGreen, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(s.description, style: const TextStyle(height: 1.5, color: ink)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
