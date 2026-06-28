import 'package:flutter/material.dart';
import '../theme.dart';

/// Simple in-app reader for the Privacy Policy / Terms.
class LegalScreen extends StatelessWidget {
  final String title;
  final String body;
  const LegalScreen({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(body,
              style: const TextStyle(height: 1.55, color: ink, fontSize: 14)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// NOTE: These are plain-language templates to get you launch-ready. Have a
// lawyer review and adapt them (and fill in the bracketed details) before
// publishing to the stores.

const String kPrivacyPolicy = '''
Sankofa Twi — Privacy Policy
Last updated: 28 June 2026

Sankofa Twi ("we", "us") helps you learn the Akan/Twi language. This policy
explains what we collect and how we use it.

1. Information we collect
• Account details you provide: email address, display name, and optionally your
  date of birth and gender.
• Learning data: lesson scores, XP, streaks, daily activity, wisdom keys, pedis,
  and premium status.
• Approximate location: derived from your IP address only to show prices in your
  local currency. We do not store your IP.
• Content you submit: text you enter into the AI Translate tool.

2. How we use it
• To run and personalise the app (progress, leaderboards, streaks).
• To process subscriptions and in-app purchases.
• To translate text and generate Twi audio you request.

3. Third parties we share with
• Google Firebase (authentication, database) — stores your account and progress.
• GhanaNLP / Khaya (translation & text-to-speech) — receives text you choose to
  translate.
• ipapi.co — used to estimate your local currency from your IP.
• The Apple App Store / Google Play — process payments and subscriptions.
We do not sell your personal data.

4. Your choices and rights
You can edit your profile, and you can request deletion of your account and data
by contacting us at sankofa@aparato.ai. Depending on your region you may have rights
to access, correct, or delete your data, and to object to processing.

5. Children
Sankofa Twi is not directed to children under 13 (or the minimum age in your
country). We do not knowingly collect their data.

6. Security & retention
We use industry-standard providers and keep your data only as long as your
account is active or as required by law.

7. Changes
We may update this policy and will note the new date above.

8. Contact
Questions? Email sankofa@aparato.ai.
''';

const String kTermsAndConditions = '''
Sankofa Twi — Terms & Conditions
Last updated: 28 June 2026

By using Sankofa Twi you agree to these terms.

1. Your account
You are responsible for your account and for keeping your login secure. Provide
accurate information when you sign up.

2. Acceptable use
Use the app for personal, lawful learning. Don't misuse, copy, resell, reverse-
engineer, or disrupt the service or its content.

3. Subscriptions, free trial & billing
• Premium is offered as a monthly or annual subscription with a 7-day free trial.
• Prices are shown in your region's currency; you are charged in your app-store
  currency. Subscriptions renew automatically until cancelled.
• Cancel anytime in your Apple App Store or Google Play account settings. Your
  access continues until the end of the paid period. Trials cancelled before they
  end are not charged.
• Refunds are handled by the relevant app store under their policies.

4. Virtual items ("pedis"), keys & cosmetics
In-app currency and items have no real-world monetary value, are non-transferable
and non-refundable, and may change or expire. They are a licence to use within the
app, not property.

5. Content
Lesson content is provided for educational purposes and may be updated. Akan/Twi
language drafts are reviewed for accuracy over time; report errors to sankofa@aparato.ai.

6. Disclaimers & liability
The app is provided "as is". To the maximum extent permitted by law, we are not
liable for indirect or incidental damages arising from your use of the app.

7. Termination
We may suspend or end access for breach of these terms. You may stop using the app
at any time.

8. Changes & governing law
We may update these terms and will note the new date above. These terms are
governed by the laws of Spain.

9. Contact
Email sankofa@aparato.ai.
''';
