import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

/// One recognised object from an image.
class LensLabel {
  final String label;
  final double confidence; // 0..1
  LensLabel(this.label, this.confidence);
}

/// A saved entry in the user's visual dictionary.
class LensFind {
  final String id;
  final String english;
  final String twi;
  LensFind(this.id, this.english, this.twi);

  factory LensFind.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return LensFind(
      d.id,
      (m['english'] ?? '').toString(),
      (m['twi'] ?? '').toString(),
    );
  }
}

/// Sankofa Lens v0: on-device object recognition → Twi name (via the existing
/// Khaya backend) → spoken audio you can play out loud to a Twi speaker, plus a
/// personal visual dictionary of "finds".
class LensService {
  LensService._();
  static final LensService instance = LensService._();

  // Bundled on-device model. See kLensConfidenceThreshold for why this isn't
  // lower — the labeler's ~400-category vocabulary means low thresholds
  // surface wrong-but-confident-enough guesses rather than "I don't know".
  final ImageLabeler _labeler = ImageLabeler(
      options:
          ImageLabelerOptions(confidenceThreshold: kLensConfidenceThreshold));

  /// Recognises objects in [file], strongest first. Runs fully on-device.
  Future<List<LensLabel>> label(File file) async {
    final input = InputImage.fromFilePath(file.path);
    final results = await _labeler.processImage(input);
    final list = results
        .map((l) => LensLabel(l.label, l.confidence))
        .toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
    return list;
  }

  /// Translates an English word/phrase to Twi via the backend.
  Future<String> toTwi(String english) async {
    final res = await http.post(
      Uri.parse('$kBackendBaseUrl/api/translate'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'text': english, 'mode': 'en-to-twi'}),
    );
    if (res.statusCode != 200) throw Exception('translate ${res.statusCode}');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['translation'] ?? '').toString().trim();
  }

  /// Fetches Twi speech audio bytes for [twi] (play out loud to communicate).
  Future<Uint8List> tts(String twi) async {
    final res = await http.post(
      Uri.parse('$kBackendBaseUrl/api/tts'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'text': twi, 'lang': 'tw'}),
    );
    if (res.statusCode != 200) throw Exception('tts ${res.statusCode}');
    return res.bodyBytes;
  }

  /// Logs a user-typed correction when Lens returned nothing, or nothing
  /// right, for a photo. This is write-only from the client (see
  /// firestore.rules) and builds a review queue that maintainers can use to
  /// spot gaps in ML Kit's label set and grow a custom/curated vocabulary
  /// over time. Never throws into the caller — a failed log shouldn't block
  /// the user from getting their word.
  Future<void> submitCorrection({
    required String userLabel,
    required List<String> suggestedLabels,
  }) async {
    final label = userLabel.trim();
    if (label.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('lensCorrections').add({
        'userLabel': label,
        'suggestedLabels': suggestedLabels,
        'uid': FirebaseAuth.instance.currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Best-effort — swallow. Losing one correction shouldn't break the flow.
    }
  }

  CollectionReference<Map<String, dynamic>>? _finds() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('finds');
  }

  /// Live stream of the user's visual dictionary, newest first.
  Stream<List<LensFind>> finds() {
    final ref = _finds();
    if (ref == null) return const Stream.empty();
    return ref
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(LensFind.fromDoc).toList());
  }

  /// Saves a find. Each distinct object is stored once (keyed by its English
  /// name). Returns true if this was the user's FIRST time finding it.
  Future<bool> saveFind(String english, String twi) async {
    final ref = _finds();
    if (ref == null) return false;
    final id = english
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    if (id.isEmpty) return false;
    final doc = ref.doc(id);
    final snap = await doc.get();
    final isFirst = !snap.exists;
    await doc.set({
      'english': english,
      'twi': twi,
      if (isFirst) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return isFirst;
  }
}
