import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_config.dart';
import '../models/emergency.dart';

class EmergencyService {
  Future<String> createEmergency({
    required String category,
    required String description,
    required String urgency,
    double? latitude,
    double? longitude,
  }) async {
    if (!AppConfig.firebaseReady) {
      throw Exception(
        'Emergency service is not connected. Configure Firebase before sending a real SOS. '
        'If this is a real emergency, contact local emergency services directly.',
      );
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Please sign in before sending an SOS.');
    }

    final ref = FirebaseFirestore.instance.collection('emergencies').doc();
    final now = DateTime.now().toUtc();
    final emergency = Emergency(
      sosId: ref.id,
      userId: user.uid,
      emergencyType: category,
      description: description.trim(),
      urgency: urgency,
      status: 'REQUESTED',
      createdAt: now,
      latitude: latitude,
      longitude: longitude,
    );

    // This confirms only that the record was written. Responder delivery
    // requires a trusted backend/Cloud Function and is not implemented here.
    await ref.set(emergency.toMap());
    return ref.id;
  }
}
