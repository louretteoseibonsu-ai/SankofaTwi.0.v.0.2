import 'dart:convert';
import 'package:http/http.dart' as http;

/// Localises the *displayed* price from the user's IP region. The actual
/// charge is always handled (and localised) by the App Store / Play Store —
/// this is an estimate so the paywall feels native. EUR is the base.
class CurrencyService {
  CurrencyService._();
  static final CurrencyService instance = CurrencyService._();

  // [rate from 1 EUR, symbol]. Rates are approximate and for display only.
  static const Map<String, (double, String)> _rates = {
    'EUR': (1.0, '€'),
    'USD': (1.08, '\$'),
    'GBP': (0.85, '£'),
    'GHS': (16.5, '₵'),
    'NGN': (1750.0, '₦'),
    'ZAR': (20.0, 'R'),
    'KES': (140.0, 'KSh '),
    'CAD': (1.47, 'C\$'),
    'AUD': (1.65, 'A\$'),
    'INR': (90.0, '₹'),
    'JPY': (170.0, '¥'),
    'CNY': (7.8, '¥'),
    'BRL': (5.9, 'R\$'),
    'CHF': (0.95, 'CHF '),
    'SEK': (11.4, 'kr '),
    'AED': (3.97, 'AED '),
    'XOF': (655.0, 'CFA '),
  };

  String code = 'EUR';
  String symbol = '€';
  double rate = 1.0;
  bool _loaded = false;

  bool get isEuro => code == 'EUR';

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      final res = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final m = jsonDecode(res.body) as Map<String, dynamic>;
        final c = (m['currency'] as String?)?.toUpperCase();
        final r = _rates[c];
        if (c != null && r != null) {
          code = c;
          rate = r.$1;
          symbol = r.$2;
        }
      }
    } catch (_) {
      // keep EUR on any failure
    }
    _loaded = true;
  }

  /// Formats a EUR amount in the user's local currency.
  String format(double eur) {
    final v = eur * rate;
    final twoDp = code == 'EUR' || code == 'USD' || code == 'GBP' ||
        code == 'CHF' || code == 'CAD' || code == 'AUD';
    final s = twoDp ? v.toStringAsFixed(2) : v.round().toString();
    return '$symbol$s';
  }
}
