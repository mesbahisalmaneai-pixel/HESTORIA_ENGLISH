import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'progress_model.dart';

/// Stores each user's progress at Firestore: users/{uid}.progress
/// Firestore's built-in offline cache queues writes and uploads them
/// automatically when the connection returns.
class CloudSync {
  Future<String?> _uid() async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser ?? (await auth.signInAnonymously()).user;
      return user?.uid;
    } catch (_) {
      return null;
    }
  }

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid);

  Future<UserProgress?> fetch() async {
    final uid = await _uid();
    if (uid == null) return null;
    try {
      final snap = await _doc(uid).get();
      final data = snap.data()?['progress'];
      if (data is Map) {
        return UserProgress.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (_) {}
    return null;
  }

  Future<void> push(UserProgress p) async {
    final uid = await _uid();
    if (uid == null) return;
    try {
      await _doc(uid).set({
        'progress': p.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}
