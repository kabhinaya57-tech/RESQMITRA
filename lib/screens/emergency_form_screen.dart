import 'package:flutter/material.dart';
import '../services/app_config.dart';
import '../services/emergency_service.dart';
import '../services/location_service.dart';
import 'active_emergency_screen.dart';

class EmergencyFormScreen extends StatefulWidget {
  final String category;
  const EmergencyFormScreen({super.key, required this.category});
  @override
  State<EmergencyFormScreen> createState() => _EmergencyFormScreenState();
}

class _EmergencyFormScreenState extends State<EmergencyFormScreen> {
  final description = TextEditingController();
  final manualLocation = TextEditingController();
  String urgency = 'HIGH';
  String bloodGroup = 'O+';
  static const bloodGroups = <String>['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  double? lat;
  double? lon;
  bool locating = false;
  bool submitting = false;
  String? locationNote;

  @override
  void dispose() { description.dispose(); manualLocation.dispose(); super.dispose(); }

  Future<void> getLocation() async {
    setState(() { locating = true; locationNote = null; });
    try {
      final p = await LocationService().getCurrentPosition();
      setState(() { lat = p.latitude; lon = p.longitude; locationNote = 'Current GPS location captured.'; });
    } catch (e) {
      setState(() => locationNote = e.toString().replaceFirst('Exception: ', ''));
    } finally { if (mounted) setState(() => locating = false); }
  }

  Future<void> send() async {
    if (description.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Briefly describe the emergency.')));
      return;
    }
    if (!AppConfig.firebaseReady) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('SOS NOT SENT: backend is not configured. Contact local emergency services directly if urgent.'),
        duration: Duration(seconds: 6),
      ));
      return;
    }
    setState(() => submitting = true);
    try {
      final needsBlood = widget.category == 'General SOS' || widget.category == 'Blood Needed';
      final details = <String>[
        description.text.trim(),
        if (needsBlood) 'Blood group needed: $bloodGroup',
        if (manualLocation.text.trim().isNotEmpty) 'Manual location: ${manualLocation.text.trim()}',
      ].join('\n');
      final id = await EmergencyService().createEmergency(
        category: widget.category,
        description: details,
        urgency: urgency,
        latitude: lat, longitude: lon,
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => ActiveEmergencyScreen(emergencyId: id, category: widget.category),
      ));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('SOS not confirmed: $e'),
        duration: const Duration(seconds: 7),
      ));
    } finally { if (mounted) setState(() => submitting = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Emergency details')),
    body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFE8F6FF), Colors.white])),
      child: ListView(padding: const EdgeInsets.all(18), children: [
        Text(widget.category, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF102A56))),
        const SizedBox(height: 14),
        TextField(controller: description, maxLines: 4, decoration: const InputDecoration(
          labelText: 'Describe what happened', hintText: 'What help is needed?')),
        if (widget.category == 'General SOS' || widget.category == 'Blood Needed') ...[
          const SizedBox(height: 16),
          const Text('Blood group needed', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: bloodGroup,
            decoration: const InputDecoration(labelText: 'Select blood group'),
            items: bloodGroups.map((group) => DropdownMenuItem<String>(
              value: group, child: Text(group),
            )).toList(),
            onChanged: (value) => setState(() => bloodGroup = value ?? 'O+'),
          ),
        ],
        const SizedBox(height: 16),
        const Text('Urgency', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: urgency,
          items: const [
            DropdownMenuItem(value: 'CRITICAL', child: Text('Critical')),
            DropdownMenuItem(value: 'HIGH', child: Text('High')),
            DropdownMenuItem(value: 'NORMAL', child: Text('Normal')),
          ],
          onChanged: (v) => setState(() => urgency = v ?? 'HIGH'),
          decoration: const InputDecoration(),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: locating ? null : getLocation,
          icon: locating ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location),
          label: const Text('Use current GPS location'),
        ),
        if (locationNote != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(locationNote!)),
        if (lat != null && lon != null) Text('GPS: ${lat!.toStringAsFixed(5)}, ${lon!.toStringAsFixed(5)}'),
        const SizedBox(height: 12),
        TextField(controller: manualLocation, maxLines: 2, decoration: const InputDecoration(
          labelText: 'Manual location (optional)', hintText: 'Address, landmark, village, or nearby place')),
        const SizedBox(height: 18),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16)),
          onPressed: submitting ? null : send,
          icon: submitting ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.sos),
          label: Text(submitting ? 'Submitting…' : 'Confirm and Send SOS'),
        ),
        const SizedBox(height: 12),
        const Text('Do not rely on this app for life-critical communication until the backend, alert delivery, responder verification, and security rules have been tested.',
          style: TextStyle(color: Colors.red, fontSize: 12)),
      ]),
    ),
  );
}
