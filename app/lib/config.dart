/// Backend base URL for translation + Twi audio.
///
/// IMPORTANT: set this to YOUR deployed Render URL (the one you open in a browser),
/// e.g. 'https://sankofa-twi.onrender.com'. The app calls <base>/api/translate and
/// <base>/api/tts so the Khaya/Gemini keys stay on the server, never in the app.
const String kBackendBaseUrl = 'https://sankofa-twi.onrender.com';
