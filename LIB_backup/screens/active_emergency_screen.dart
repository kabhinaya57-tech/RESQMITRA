import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/app_config.dart';

class ActiveEmergencyScreen extends StatelessWidget {
  final String emergencyId;
  final String category;
  const ActiveEmergencyScreen({super.key, required this.emergencyId, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency status')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF078B43), size: 64),
          const SizedBox(height: 12),
          const Text('SOS record created', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Color(0xFF102A56))),
          const SizedBox(height: 8),
          Text('Emergency: $category', textAlign: TextAlign.center),
          SelectableText('Emergency ID: $emergencyId', textAlign: TextAlign.center),
          const SizedBox(height: 20),
          if (AppConfig.firebaseReady)
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('emergencies').doc(emergencyId).snapshots(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data();
                final status = data?['status']?.toString() ?? 'Loading status…';
                return Card(color: Colors.white, child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    const Text('Backend status', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(status, style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    const Text('Responder alert delivery is not yet implemented. A created record does not mean a responder has accepted the request.',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.red)),
                  ]),
                ));
              },
            ),
          const Spacer(),
          const Text('If you are in immediate danger or need urgent medical/fire/police assistance, contact official local emergency services directly.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
          const SizedBox(height: 14),
          FilledButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            child: const Text('Return to Home')),
        ]),
      ),
    );
  }
}
