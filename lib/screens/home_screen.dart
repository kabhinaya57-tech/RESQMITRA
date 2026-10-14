import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/app_config.dart';
import 'role_screen.dart';
import 'auth_screen.dart';
import 'emergency_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const categories = <(String, IconData, Color)>[
    ('General SOS', Icons.sos, Colors.red),
    ('Women SOS', Icons.shield_outlined, Color(0xFFB83280)),
    ('Children SOS', Icons.child_care, Color(0xFFFFC928)),
    ('Medical Emergency', Icons.medical_services_outlined, Color(0xFF168DDB)),
    ('Accident', Icons.car_crash_outlined, Colors.deepOrange),
    ('Fire', Icons.local_fire_department_outlined, Colors.redAccent),
    ('Rescue', Icons.health_and_safety_outlined, Color(0xFF078B43)),
    ('Evacuation', Icons.directions_run, Color(0xFF168DDB)),
    ('Missing Person', Icons.person_search, Color(0xFF102A56)),
    ('Blood Needed', Icons.bloodtype_outlined, Colors.red),
    ('Natural Calamities', Icons.flood_outlined, Color(0xFF168DDB)),
    ('Other', Icons.more_horiz, Colors.blueGrey),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Image.asset('assets/images/resq_mitra_logo.jpeg', height: 38, width: 38, fit: BoxFit.contain),
          const SizedBox(width: 8),
          const Text('ResQMitra', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Profile / Role',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoleScreen())),
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              if (AppConfig.firebaseReady) await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          colors: [Color(0xFFE8F6FF), Colors.white],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        )),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22),
                  boxShadow: const [BoxShadow(color: Color(0x16000000), blurRadius: 14, offset: Offset(0, 5))]),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Emergency assistance', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF102A56))),
                  SizedBox(height: 6),
                  Text('Request help or volunteer to support your community.'),
                  SizedBox(height: 10),
                  Text('BE FIRST TO RESPOND', style: TextStyle(color: Color(0xFF168DDB), fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                ]),
              ),
              const SizedBox(height: 18),
              const Text('Choose an emergency', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF102A56))),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 1.45, crossAxisSpacing: 12, mainAxisSpacing: 12,
                ),
                itemBuilder: (context, i) {
                  final item = categories[i];
                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => EmergencyFormScreen(category: item.$1),
                    )),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFD2DCE5))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(item.$2, size: 30, color: item.$3),
                        const SizedBox(height: 8),
                        Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF102A56))),
                      ]),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoleScreen())),
                icon: const Icon(Icons.volunteer_activism_outlined),
                label: const Text('Join as a responder'),
              ),
              const SizedBox(height: 8),
              const Text('Important: This app is not a replacement for official emergency services. If you are in immediate danger, call your local emergency number.',
                style: TextStyle(fontSize: 12, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}
