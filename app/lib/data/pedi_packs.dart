/// A purchasable bundle of pedis (soft currency). Prices are in EUR and shown
/// localised via CurrencyService; the real charge happens in the app-store
/// currency once billing is live (kBillingEnabled).
///
/// Pricing model: ~€0.01 per pedi at the entry pack, with a growing bonus on
/// bigger packs (better value rewards commitment, standard for soft currency).
class PediPack {
  final int pedis;
  final double eur;
  final String? tag; // e.g. "Best value", "Popular"
  const PediPack(this.pedis, this.eur, {this.tag});

  /// Effective price per pedi, for a "bonus %" callout vs the base pack.
  double get perPedi => eur / pedis;
}

const List<PediPack> kPediPacks = [
  PediPack(100, 0.99),
  PediPack(550, 4.99, tag: 'Popular'), // ~10% more pedis per €
  PediPack(1200, 9.99, tag: 'Best value'), // ~20% more pedis per €
];

/// What pedis are good for — shown in the store so the value is concrete.
const List<String> kPediUses = [
  'Top up AI credits — translate, Lens scans & audio (10 for 20 pedis)',
  'Buy streak freezes (50 pedis each)',
  'Unlock avatars & cosmetics',
];
