/// Backend base URL for translation + Twi audio.
///
/// IMPORTANT: set this to YOUR deployed Render URL (the one you open in a browser),
/// e.g. 'https://sankofa-twi.onrender.com'. The app calls <base>/api/translate and
/// <base>/api/tts so the Khaya/Gemini keys stay on the server, never in the app.
const String kBackendBaseUrl = 'https://sankofa-twi.onrender.com';

/// Master switch for motion / celebratory animations. Turn off to ship a
/// fully static build. Animations ALSO auto-disable when the OS "reduce
/// motion" accessibility setting is on (see widgets/animations.dart).
const bool kAnimationsEnabled = true;

/// Master switch for paid features (premium Ananse avatar, etc.).
/// Keep this FALSE until real billing is wired up (in_app_purchase + a
/// verified payment gateway). While false, the premium unlock is shown as
/// "coming soon" and never grants premium.
const bool kBillingEnabled = false;
