import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/app_config.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});
  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  String? selected;
  bool busy = false;
  final roles = const [
    ('HELP_SEEKER', 'Help Seeker', 'Need assistance', Icons.shield_outlined, Color(0xFF168DDB)),
    ('RESCUER', 'Volunteer as Rescuer', 'Help others', Icons.volunteer_activism_outlined, Color(0xFF078B43)),
    ('BOTH', 'Help Seeker and Rescuer', 'Together, we save lives', Icons.groups_outlined, Color(0xFF009688)),
  ];

  Future<void> saveRole() async {
    if (selected == null) return;
    if (!AppConfig.firebaseReady || FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in and configure Firebase to save your role.')));
      return;
    }
    setState(() => busy = true);
    try {
      await FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({'role': selected, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Role could not be saved: $e')));
    } finally { if (mounted) setState(() => busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Join ResQMitra')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const Text('Choose how you want to use ResQMitra.', style: TextStyle(fontSize: 18, color: Color(0xFF102A56))),
      const SizedBox(height: 18),
      ...roles.map((r) => Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: selected == r.$1 ? r.$5 : const Color(0xFFD2DCE5), width: selected == r.$1 ? 2 : 1),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(14),
          leading: Icon(r.$4, color: r.$5, size: 34),
          title: Text(r.$2, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(r.$3),
          trailing: Radio<String>(value: r.$1, groupValue: selected, onChanged: (v) => setState(() => selected = v)),
          onTap: () => setState(() => selected = r.$1),
        ),
      )),
      const SizedBox(height: 18),
      FilledButton(
        onPressed: selected == null || busy ? null : saveRole,
        child: busy ? const CircularProgressIndicator() : const Text('Continue'),
      ),
      const SizedBox(height: 10),
      const Text('Responder access and emergency categories must be verified server-side. Selecting a role does not make a user a verified responder.',
        style: TextStyle(fontSize: 12)),
    ]),
  );
}
