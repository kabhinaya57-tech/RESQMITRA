import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/incident.dart';
import 'services/app_database.dart';

const navy = Color(0xFF063768);
const blue = Color(0xFF1475D1);
const pink = Color(0xFFE91E63);
const saffron = Color(0xFFFFA900);
const green = Color(0xFF087A3D);

void main() => runApp(const PrathamRakshaApp());

class PrathamRakshaApp extends StatelessWidget {
  const PrathamRakshaApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'RESQ-MITRA', debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: navy), scaffoldBackgroundColor: const Color(0xFFF5F7FB), useMaterial3: true,
      appBarTheme: const AppBarTheme(backgroundColor: navy, foregroundColor: Colors.white, centerTitle: false),
      inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white)),
    home: const SplashScreen(),
  );
}

class SplashScreen extends StatefulWidget { const SplashScreen({super.key}); @override State<SplashScreen> createState() => _SplashScreenState(); }
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController ticker = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
  @override void initState() { super.initState(); Timer(const Duration(seconds: 3), _continue); }
  Future<void> _continue() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('signed_in_email');
    final name = prefs.getString('signed_in_name');
    final role = prefs.getString('user_role');
    if (!mounted) return;
    if (email != null && email.isNotEmpty) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => role == null ? RoleScreen(name: name ?? 'User', email: email) : MainShell(userName: name ?? 'User', userEmail: email, role: role)));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AuthScreen(onSuccess: (user) async {
        final p = await SharedPreferences.getInstance();
        await p.setString('signed_in_email', user['email'] as String);
        await p.setString('signed_in_name', user['name'] as String);
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RoleScreen(name: user['name'] as String, email: user['email'] as String)));
      })));
    }
  }
  @override void dispose() { ticker.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.white, body: SafeArea(child: Column(children: [
    const Spacer(), Padding(padding: const EdgeInsets.all(22), child: Image.asset('assets/pratham_raksha_logo.png', fit: BoxFit.contain)),
    const Spacer(), SizedBox(height: 28, child: ClipRect(child: AnimatedBuilder(animation: ticker, builder: (_, __) => Align(alignment: Alignment(-1 + 2*ticker.value, 0), child: const Text('HELP  |  PROTECT  |  SUPPORT  |  TOGETHER', maxLines: 1, style: TextStyle(color: navy, fontWeight: FontWeight.w900, letterSpacing: 1.3, fontSize: 15))))),
    const SizedBox(height: 20), const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 3, color: green)), const SizedBox(height: 28)
  ])));
}

class RoleScreen extends StatefulWidget { final String name, email; const RoleScreen({super.key, required this.name, required this.email}); @override State<RoleScreen> createState() => _RoleScreenState(); }
class _RoleScreenState extends State<RoleScreen> {
  String selected = 'HELP SEEKER';
  Future<void> start() async { final prefs = await SharedPreferences.getInstance(); await prefs.setString('user_role', selected); if (!mounted) return; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainShell(userName: widget.name, userEmail: widget.email, role: selected))); }
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const SizedBox(height: 24), const Icon(Icons.health_and_safety, size: 62, color: green), const SizedBox(height: 12), const Text('HOW WOULD YOU LIKE TO HELP?', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: navy)), const SizedBox(height: 8), Text('Welcome, ${widget.name}. Choose your role to continue.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)), const SizedBox(height: 28),
    _RoleCard(title: 'HELP SEEKER', subtitle: 'I need help or want to report an emergency', icon: Icons.sos, color: const Color(0xFFD92727), selected: selected == 'HELP SEEKER', onTap: () => setState(() => selected = 'HELP SEEKER')),
    const SizedBox(height: 16), _RoleCard(title: 'VOLUNTEER AS RESCUE RESPONDER', subtitle: 'I want to help and support others', icon: Icons.volunteer_activism, color: green, selected: selected == 'VOLUNTEER', onTap: () => setState(() => selected = 'VOLUNTEER')),
    const Spacer(), FilledButton(onPressed: start, style: FilledButton.styleFrom(backgroundColor: navy, padding: const EdgeInsets.symmetric(vertical: 17)), child: const Text('GET STARTED', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1))), const SizedBox(height: 14)
  ]))));
}
class _RoleCard extends StatelessWidget { final String title, subtitle; final IconData icon; final Color color; final bool selected; final VoidCallback onTap; const _RoleCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.selected, required this.onTap}); @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: selected ? color.withOpacity(.08) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: selected ? color : Colors.black12, width: selected ? 2 : 1)), child: Row(children: [CircleAvatar(radius: 28, backgroundColor: color, child: Icon(icon, color: Colors.white, size: 30)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 15)), const SizedBox(height: 6), Text(subtitle, style: const TextStyle(color: Colors.black54))])), Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: color)]))); }

class MainShell extends StatefulWidget { final String userName, userEmail, role; const MainShell({super.key, required this.userName, required this.userEmail, required this.role}); @override State<MainShell> createState() => _MainShellState(); }
class _MainShellState extends State<MainShell> {
  int tab = 0; String? trackingId;
  void openSos(String type) { Navigator.push(context, MaterialPageRoute(builder: (_) => SosScreen(category: type, email: widget.userEmail, onCreated: (id) { setState(() => trackingId = id); Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingScreen(id: id))); })); }
  @override Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(userName: widget.userName, role: widget.role, onSos: openSos, onHistory: () => setState(() => tab = 2)),
      const MapScreen(),
      IncidentsScreen(email: widget.userEmail, onTrack: (id) => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingScreen(id: id)))),
      const BadgesScreen(),
      ProfileScreen(name: widget.userName, email: widget.userEmail, onLogin: () {}, onLogout: () async { final p = await SharedPreferences.getInstance(); await p.remove('signed_in_email'); await p.remove('signed_in_name'); await p.remove('user_role'); if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SplashScreen()), (_) => false); }),
    ];
    return Scaffold(body: SafeArea(child: IndexedStack(index: tab, children: pages)), bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i), destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
      NavigationDestination(icon: Icon(Icons.history), selectedIcon: Icon(Icons.history), label: 'History'),
      NavigationDestination(icon: Icon(Icons.workspace_premium_outlined), selectedIcon: Icon(Icons.workspace_premium), label: 'Badges'),
      NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
    ]));
  }
}

class HomeScreen extends StatelessWidget {
  final String userName, role; final void Function(String) onSos; final VoidCallback onHistory;
  const HomeScreen({super.key, required this.userName, required this.role, required this.onSos, required this.onHistory});
  void showSosOptions(BuildContext context) { showModalBottomSheet(context: context, showDragHandle: true, backgroundColor: Colors.white, builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(18, 8, 18, 26), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('CHOOSE SOS TYPE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: navy)), const SizedBox(height: 16), _SosChoice(title: 'GENERAL SOS', subtitle: 'Medical, accident or other emergency', color: blue, icon: Icons.health_and_safety, onTap: () { Navigator.pop(ctx); onSos('General'); }), _SosChoice(title: 'WOMEN SOS', subtitle: 'Women safety and urgent support', color: pink, icon: Icons.shield, onTap: () { Navigator.pop(ctx); onSos('Women'); }), _SosChoice(title: 'CHILD SOS', subtitle: 'Urgent help involving a child', color: saffron, icon: Icons.child_care, onTap: () { Navigator.pop(ctx); onSos('Child'); })])))); }
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 14, 20, 20), child: ConstrainedBox(constraints: BoxConstraints(minHeight: constraints.maxHeight - 34), child: Column(children: [
    Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: green.withOpacity(.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.health_and_safety, color: green, size: 28)), const SizedBox(width: 10), const Expanded(child: Text('RESQ-MITRA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: navy, letterSpacing: .4))), const Icon(Icons.notifications_none, color: navy, size: 26)]),
    const SizedBox(height: 12), Align(alignment: Alignment.centerLeft, child: Text('Hello, $userName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), Align(alignment: Alignment.centerLeft, child: Text(role == 'VOLUNTEER' ? 'Thank you for being ready to help.' : 'You are not alone. Help is one tap away.', style: const TextStyle(color: Colors.black54))),
    const SizedBox(height: 26), const Text('IN AN EMERGENCY', style: TextStyle(color: Colors.black54, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)), const SizedBox(height: 20),
    _BlinkingSosButton(onTap: () => showSosOptions(context)), const SizedBox(height: 18), const Text('TAP SOS TO CHOOSE THE HELP YOU NEED', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, color: navy, letterSpacing: .6)),
    const SizedBox(height: 20), Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)), child: const Row(children: [Icon(Icons.call, color: green, size: 28), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('India emergency number', style: TextStyle(fontWeight: FontWeight.bold)), Text('112 · Call directly if you need immediate assistance', style: TextStyle(fontSize: 12, color: Colors.black54))]))])),
    const SizedBox(height: 14), SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: onHistory, icon: const Icon(Icons.history), label: const Text('View SOS history'))), const SizedBox(height: 8), const Text('Prototype notice: an in-app SOS report is saved locally and does not automatically dispatch emergency services.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.black54))
  ]))));
}

class _BlinkingSosButton extends StatefulWidget { final VoidCallback onTap; const _BlinkingSosButton({required this.onTap}); @override State<_BlinkingSosButton> createState() => _BlinkingSosButtonState(); }
class _BlinkingSosButtonState extends State<_BlinkingSosButton> with SingleTickerProviderStateMixin { late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 850), lowerBound: .93, upperBound: 1)..repeat(reverse: true); @override void dispose() { c.dispose(); super.dispose(); } @override Widget build(BuildContext context) => AnimatedBuilder(animation: c, builder: (_, child) => Transform.scale(scale: c.value, child: child), child: GestureDetector(onTap: widget.onTap, child: Container(width: 228, height: 228, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFD91F26), boxShadow: [BoxShadow(color: Colors.red.withOpacity(.28), blurRadius: 30, spreadRadius: 8)]), child: Container(margin: const EdgeInsets.all(9), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(.8), width: 2)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.sos, color: Colors.white, size: 62), Text('SOS', style: TextStyle(color: Colors.white, fontSize: 43, fontWeight: FontWeight.w900, letterSpacing: 2)), Text('TAP FOR HELP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 11))])))))); }
class _SosChoice extends StatelessWidget { final String title, subtitle; final Color color; final IconData icon; final VoidCallback onTap; const _SosChoice({required this.title, required this.subtitle, required this.color, required this.icon, required this.onTap}); @override Widget build(BuildContext context) => Card(color: color.withOpacity(.08), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7), leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)), title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900)), subtitle: Text(subtitle), trailing: Icon(Icons.arrow_forward_ios, color: color, size: 18), onTap: onTap)); }
class BadgesScreen extends StatelessWidget { const BadgesScreen({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Badges')), body: ListView(padding: const EdgeInsets.all(20), children: [const Icon(Icons.workspace_premium, size: 70, color: saffron), const SizedBox(height: 12), const Text('Your impact, recognised', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: navy)), const SizedBox(height: 8), const Text('Badges and achievements will appear here as the app gains activity.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)), const SizedBox(height: 24), const Card(child: ListTile(leading: Icon(Icons.favorite, color: pink, size: 32), title: Text('First step'), subtitle: Text('Create your account and join the RESQ-MITRA community'))), const Card(child: ListTile(leading: Icon(Icons.volunteer_activism, color: green, size: 32), title: Text('Community helper'), subtitle: Text('Volunteer achievements coming soon')))])); }

class SosScreen extends StatefulWidget { final String category, email; final ValueChanged<String> onCreated; const SosScreen({super.key, required this.category, required this.email, required this.onCreated}); @override State<SosScreen> createState() => _SosScreenState(); }
class _SosScreenState extends State<SosScreen> {
  final form = GlobalKey<FormState>(); final description = TextEditingController(); final name = TextEditingController(); final phone = TextEditingController();
  String type = 'Medical emergency'; String bloodGroup = 'A+'; String priority = 'High'; Position? position; bool locating = false; bool submitting = false;
  static const bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  List<String> get types => widget.category == 'Women'
    ? const ['Immediate danger','Harassment','Unsafe situation','Escort assistance','Medical emergency','Safe shelter','Others']
    : widget.category == 'Child'
      ? const ['Child in Immediate danger','Missing child','Medical emergency','Lost child','Child abuse or threat','Unsafe situation','Rescue assistance','Others']
      : const ['Medical emergency','Accident','Fire','Flood','Rescue','Evacuation','Missing person','Blood needed','Other'];
  Future<void> getLocation() async { setState(() => locating = true); try { var enabled = await Geolocator.isLocationServiceEnabled(); if (!enabled) throw Exception('Turn on device location and try again.'); var permission = await Geolocator.checkPermission(); if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission(); if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) throw Exception('Location permission was not granted. You can still submit without GPS.'); position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15))); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location captured for this report.'))); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')))); } finally { if (mounted) setState(() => locating = false); } }
  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    final details = SosDraft(
      category: widget.category,
      emergencyType: type,
      description: description.text.trim(),
      contactName: name.text.trim(),
      contactPhone: phone.text.trim(),
      latitude: position?.latitude,
      longitude: position?.longitude,
      email: widget.email,
      bloodGroup: type == 'Blood needed' ? bloodGroup : '',
    );
    final id = await Navigator.push<String>(context, MaterialPageRoute(
      builder: (_) => EmergencyConfirmationScreen(draft: details),
    ));
    if (id != null && mounted) widget.onCreated(id);
  }
  @override void dispose() { description.dispose(); name.dispose(); phone.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('${widget.category.toUpperCase()} SOS')), body: Form(key: form, child: ListView(padding: const EdgeInsets.all(18), children: [Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: widget.category == 'Women' ? pink.withOpacity(.1) : blue.withOpacity(.1), borderRadius: BorderRadius.circular(16)), child: Text(widget.category == 'Women' ? 'Women safety emergency report' : widget.category == 'Child' ? 'Child emergency report' : 'General emergency report', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: navy))), const SizedBox(height: 16), DropdownButtonFormField<String>(value: types.contains(type) ? type : types.first, decoration: const InputDecoration(labelText: 'Emergency type'), items: types.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => type = v ?? type)), if (widget.category == 'General' && type == 'Blood needed') ...[const SizedBox(height: 12), DropdownButtonFormField<String>(value: bloodGroup, decoration: const InputDecoration(labelText: 'Blood group needed'), items: bloodGroups.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => bloodGroup = v ?? bloodGroup)), const SizedBox(height: 6), const Text('Select the blood group required for the patient.', style: TextStyle(fontSize: 12, color: Colors.black54))], const SizedBox(height: 12), TextFormField(controller: description, decoration: const InputDecoration(labelText: 'What happened?', hintText: 'Describe the emergency'), maxLines: 3, validator: (v) => (v == null || v.trim().isEmpty) ? 'Please describe the emergency.' : null), const SizedBox(height: 12), TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Contact name (optional)')), const SizedBox(height: 12), TextFormField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Contact phone (optional)')), const SizedBox(height: 14), OutlinedButton.icon(onPressed: locating ? null : getLocation, icon: locating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location), label: Text(position == null ? 'Capture current GPS location (optional)' : 'Location captured: ${position!.latitude.toStringAsFixed(5)}, ${position!.longitude.toStringAsFixed(5)}')), if (position == null) const Padding(padding: EdgeInsets.only(top: 6), child: Text('You can submit without location. No location is invented if GPS is unavailable.', style: TextStyle(fontSize: 12, color: Colors.black54))), const SizedBox(height: 20), FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: widget.category == 'Women' ? pink : widget.category == 'Child' ? saffron : blue, padding: const EdgeInsets.all(16)), onPressed: submitting ? null : submit, icon: const Icon(Icons.save), label: Text(submitting ? 'Saving report…' : 'SAVE SOS REPORT')), const SizedBox(height: 12), const Text('This prototype saves the report locally on this device. It does not dispatch emergency services or send a remote alert.', style: TextStyle(fontSize: 12, color: Colors.redAccent)),])));
}


class SosDraft {
  final String category, emergencyType, description, contactName, contactPhone, email;
  final String bloodGroup;
  final double? latitude, longitude;
  const SosDraft({required this.category, required this.emergencyType, required this.description,
    required this.contactName, required this.contactPhone, required this.email, this.latitude, this.longitude, this.bloodGroup = ''});
}

class EmergencyConfirmationScreen extends StatefulWidget {
  final SosDraft draft;
  const EmergencyConfirmationScreen({super.key, required this.draft});
  @override State<EmergencyConfirmationScreen> createState() => _EmergencyConfirmationScreenState();
}

class _EmergencyConfirmationScreenState extends State<EmergencyConfirmationScreen> {
  bool doNotCall = false;
  bool sending = false;
  Future<void> sendSos() async {
    setState(() => sending = true);
    try {
      final d = widget.draft;
      final id = await AppDatabase.instance.createIncident(
        category: d.category, emergencyType: d.emergencyType, description: d.description,
        contactName: d.contactName, contactPhone: d.contactPhone,
        latitude: d.latitude, longitude: d.longitude, userEmail: d.email,
        doNotCall: doNotCall, bloodGroup: d.bloodGroup,
      );
      if (mounted) Navigator.pop(context, id);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save SOS: $e')));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override Widget build(BuildContext context) {
    final d = widget.draft;
    final accent = d.category == 'Women' ? pink : d.category == 'Child' ? saffron : blue;
    final location = d.latitude == null || d.longitude == null
      ? 'Not shared — GPS location was not captured'
      : '${d.latitude!.toStringAsFixed(5)}, ${d.longitude!.toStringAsFixed(5)}';
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Emergency')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Row(children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
          const Expanded(child: Text('Review your SOS before sending', style: TextStyle(fontWeight: FontWeight.w800, color: navy))),
          Icon(Icons.sync, color: accent),
        ]),
        Card(elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), child: Padding(
          padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(backgroundColor: accent, child: const Icon(Icons.health_and_safety, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${d.category.toUpperCase()} SOS', style: const TextStyle(fontWeight: FontWeight.w900, color: navy)),
                Text(d.emergencyType, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                if (d.bloodGroup.isNotEmpty) Text('Blood group needed: ${d.bloodGroup}', style: const TextStyle(fontSize: 13, color: Color(0xFFB71C1C), fontWeight: FontWeight.w800)),
              ])),
            ]),
            const Divider(height: 28),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
            const SizedBox(height: 5),
            Text(d.description),
            const Divider(height: 24),
            const Text('Location', style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
            const SizedBox(height: 5),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.location_on_outlined, size: 18, color: Colors.black54),
              const SizedBox(width: 6), Expanded(child: Text(location)),
            ]),
            const Divider(height: 24),
            const Text('Nearby Responders', style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
            const SizedBox(height: 5),
            const Text('Responder notifications require an active network dispatch service. This app currently saves SOS reports on this device only.', style: TextStyle(fontSize: 12, color: Colors.black54)),
            const Divider(height: 24),
            const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
            const SizedBox(height: 5),
            const Row(children: [Icon(Icons.info_outline, size: 18, color: green), SizedBox(width: 6), Expanded(child: Text('No calls will be initiated automatically by this prototype.', style: TextStyle(fontSize: 12)))]),
            const SizedBox(height: 14),
            Container(decoration: BoxDecoration(color: const Color(0xFFFFF5E5), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFD18A))), child: CheckboxListTile(
              value: doNotCall,
              onChanged: (v) => setState(() => doNotCall = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              title: const Text('DO NOT CALL', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: const Text('My situation is sensitive or critical. Do not place a phone call; record this preference with my SOS.', style: TextStyle(fontSize: 12)),
            )),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: sending ? null : () => Navigator.pop(context), child: const Text('CANCEL'))),
              const SizedBox(width: 10),
              Expanded(child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD92727), padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: sending ? null : sendSos,
                icon: sending ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.sos),
                label: Text(sending ? 'SENDING…' : 'SEND SOS'),
              )),
            ]),
          ]),
        )),
        const SizedBox(height: 12),
        const Text('Important: SEND SOS saves the report locally. It does not yet transmit an alert to nearby responders or emergency services. In a real emergency, contact local emergency services if it is safe to do so.', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
      ]),
    );
  }
}

class IncidentsScreen extends StatefulWidget { final String email; final ValueChanged<String> onTrack; const IncidentsScreen({super.key, required this.email, required this.onTrack}); @override State<IncidentsScreen> createState() => _IncidentsScreenState(); }
class _IncidentsScreenState extends State<IncidentsScreen> {
  Future<List<Incident>> load() => AppDatabase.instance.incidents(email: widget.email);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident dashboard'),
        actions: [
          IconButton(
            tooltip: 'Export JSON',
            icon: const Icon(Icons.data_object),
            onPressed: () async {
              final json = await AppDatabase.instance.exportJson();
              if (!context.mounted) return;
              await showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Database JSON export'),
                  content: SizedBox(
                    width: 500,
                    child: SingleChildScrollView(child: SelectableText(json)),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Incident>>(
        future: load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Could not load incidents: ${snapshot.error}'));
          }
          final items = snapshot.data ?? <Incident>[];
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No incidents saved yet. Submit an SOS report to see it here.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '${items.length} saved incident(s)',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                ...items.map(
                  (incident) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: incident.category == 'Women' ? pink : incident.category == 'Child' ? saffron : blue,
                        child: Icon(
                          incident.category == 'Women' ? Icons.shield : incident.category == 'Child' ? Icons.child_care : Icons.sos,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        '${incident.category} • ${incident.emergencyType}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${incident.id}\n${incident.status} • ${DateTime.tryParse(incident.createdAt)?.toLocal().toString().split('.').first ?? incident.createdAt}',
                        maxLines: 3,
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => widget.onTrack(incident.id),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TrackingScreen extends StatefulWidget { final String id; const TrackingScreen({super.key, required this.id}); @override State<TrackingScreen> createState() => _TrackingScreenState(); }
class _TrackingScreenState extends State<TrackingScreen> { late Future<Incident?> future; @override void initState() { super.initState(); future = AppDatabase.instance.incidentById(widget.id); } @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Incident tracking')), body: FutureBuilder<Incident?>(future: future, builder: (context, snap) { if (widget.id.isEmpty) return const Center(child: Text('Open the Incidents tab to select a saved report.')); if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator()); final i = snap.data; if (i == null) return const Center(child: Text('Incident not found on this device.')); return ListView(padding: const EdgeInsets.all(18), children: [Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.track_changes, size: 40, color: blue), const SizedBox(height: 12), const Text('REFERENCE NUMBER', style: TextStyle(color: Colors.black54)), SelectableText(i.id, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: navy)), const Divider(height: 28), _DetailLine('Category', i.category), _DetailLine('Type', i.emergencyType),
_DetailLine('Blood group needed', i.bloodGroup.isEmpty ? 'Not applicable' : i.bloodGroup), _DetailLine('Status', i.status), _DetailLine('Priority', i.priority), _DetailLine('Description', i.description), _DetailLine('Do not call', i.doNotCall ? 'Yes — no-call preference selected' : 'No'), _DetailLine('Created', DateTime.tryParse(i.createdAt)?.toLocal().toString().split('.').first ?? i.createdAt), _DetailLine('Contact', i.contactName.isEmpty ? 'Not provided' : i.contactName), if (i.latitude != null && i.longitude != null) _DetailLine('GPS', '${i.latitude}, ${i.longitude}'), if (i.latitude != null && i.longitude != null) FilledButton.icon(onPressed: () => _openMap(i.latitude!, i.longitude!), icon: const Icon(Icons.map), label: const Text('Open location in Google Maps')), const SizedBox(height: 12), const Text('Status is stored locally in this prototype. It does not indicate that a responder has received or acknowledged the alert.', style: TextStyle(color: Colors.redAccent, fontSize: 12))])))]); })) ; }
class _DetailLine extends StatelessWidget { final String label, value; const _DetailLine(this.label, this.value); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.black54))), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)))])); }

class RespondersScreen extends StatelessWidget {
  const RespondersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency contacts')),
      body: FutureBuilder<List<Map<String, Object?>>>(
        future: AppDatabase.instance.responders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Could not load contacts: ${snapshot.error}'));
          }
          final responders = snapshot.data ?? <Map<String, Object?>>[];
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'These are default emergency contact entries, not live verified responders. Call only if appropriate for your situation.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              ...responders.map(
                (responder) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.health_and_safety),
                    ),
                    title: Text(responder['name'] as String? ?? 'Contact'),
                    subtitle: Text(
                      '${responder['role'] ?? 'Contact'} • ${responder['available'] == 1 ? 'Listed as available' : 'Unavailable'}\n${responder['phone'] ?? ''}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.call, color: Colors.green),
                      onPressed: () => _call(responder['phone'] as String? ?? ''),
                    ),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('India emergency response'),
                  subtitle: const Text('112'),
                  trailing: FilledButton(
                    onPressed: () => _call('112'),
                    child: const Text('Call'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MapScreen extends StatefulWidget { const MapScreen({super.key}); @override State<MapScreen> createState() => _MapScreenState(); }
class _MapScreenState extends State<MapScreen> { Position? pos; bool loading = false; Future<void> locate() async { setState(() => loading = true); try { if (!await Geolocator.isLocationServiceEnabled()) throw Exception('Location service is turned off.'); var p = await Geolocator.checkPermission(); if (p == LocationPermission.denied) p = await Geolocator.requestPermission(); if (p == LocationPermission.denied || p == LocationPermission.deniedForever) throw Exception('Location permission denied.'); pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15))); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')))); } finally { if (mounted) setState(() => loading = false); } } @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Location & map')), body: ListView(padding: const EdgeInsets.all(18), children: [Container(height: 170, decoration: BoxDecoration(color: const Color(0xFFDCEAF8), borderRadius: BorderRadius.circular(18)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.map, size: 58, color: navy), SizedBox(height: 8), Text('Map opens through Google Maps', style: TextStyle(fontWeight: FontWeight.bold, color: navy)), Text('No map API key is required for this link-based view.', style: TextStyle(fontSize: 12))])), const SizedBox(height: 16), FilledButton.icon(onPressed: loading ? null : locate, icon: const Icon(Icons.my_location), label: Text(loading ? 'Getting location…' : 'Get current location')), if (pos != null) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Current coordinates', style: TextStyle(fontWeight: FontWeight.bold)), SelectableText('${pos!.latitude}, ${pos!.longitude}'), const SizedBox(height: 10), FilledButton.icon(onPressed: () => _openMap(pos!.latitude, pos!.longitude), icon: const Icon(Icons.open_in_new), label: const Text('Open in Google Maps'))]))), const SizedBox(height: 12), const Text('GPS requires device location to be enabled and permission to be granted. This page does not show live responder positions.', style: TextStyle(color: Colors.black54, fontSize: 12))])); }

class AuthScreen extends StatefulWidget { final ValueChanged<Map<String, Object?>> onSuccess; const AuthScreen({super.key, required this.onSuccess}); @override State<AuthScreen> createState() => _AuthScreenState(); }
class _AuthScreenState extends State<AuthScreen> { bool registering = false, busy = false; final name = TextEditingController(); final phone = TextEditingController(); final email = TextEditingController(); final password = TextEditingController(); Future<void> submit() async { setState(() => busy = true); try { if (registering) { final error = await AppDatabase.instance.register(name: name.text, phone: phone.text, email: email.text, password: password.text); if (error != null) throw Exception(error); } final user = await AppDatabase.instance.login(email.text, password.text); if (user == null) throw Exception('Login failed. Check your email and password.'); if (mounted) { Navigator.pop(context); widget.onSuccess(user); } } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')))); } finally { if (mounted) setState(() => busy = false); } } @override void dispose() { name.dispose(); phone.dispose(); email.dispose(); password.dispose(); super.dispose(); } @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(registering ? 'Create account' : 'Sign in')), body: ListView(padding: const EdgeInsets.all(20), children: [Image.asset('assets/pratham_raksha_logo.png', height: 130, fit: BoxFit.contain), const SizedBox(height: 12), Text(registering ? 'Create your RESQ-MITRA account' : 'Welcome back', textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navy)), const SizedBox(height: 20), if (registering) ...[TextField(controller: name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline))), const SizedBox(height: 12), TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number', prefixIcon: Icon(Icons.phone_outlined))), const SizedBox(height: 12)], TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))), const SizedBox(height: 12), TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password (minimum 8 characters)', prefixIcon: Icon(Icons.lock_outline))), const SizedBox(height: 18), FilledButton(onPressed: busy ? null : submit, style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)), child: Text(busy ? 'Please wait…' : registering ? 'CREATE ACCOUNT' : 'LOGIN')), TextButton(onPressed: () => setState(() => registering = !registering), child: Text(registering ? 'Already registered? Sign in' : 'New user? Create an account')), const Text('Prototype authentication is stored locally on this device. Use a secure backend such as Firebase Authentication before public deployment.', style: TextStyle(fontSize: 12, color: Colors.redAccent))])); }
class ProfileScreen extends StatelessWidget { final String name, email; final VoidCallback onLogin, onLogout; const ProfileScreen({super.key, required this.name, required this.email, required this.onLogin, required this.onLogout}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Profile & data')), body: ListView(padding: const EdgeInsets.all(18), children: [CircleAvatar(radius: 38, backgroundColor: navy, child: Text(name.isEmpty ? 'G' : name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 28))), const SizedBox(height: 12), Text(name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), Text(email.isEmpty ? 'Not signed in' : email, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)), const SizedBox(height: 20), if (email.isEmpty) FilledButton.icon(onPressed: onLogin, icon: const Icon(Icons.login), label: const Text('Sign in / Register')) else OutlinedButton.icon(onPressed: onLogout, icon: const Icon(Icons.logout), label: const Text('Sign out')), const SizedBox(height: 12), Card(child: ListTile(leading: const Icon(Icons.data_object, color: blue), title: const Text('Export database as JSON'), subtitle: const Text('View a JSON backup of incidents and non-secret records'), onTap: () async { final data = await AppDatabase.instance.exportJson(); if (context.mounted) showDialog(context: context, builder: (_) => AlertDialog(title: const Text('JSON backup'), content: SizedBox(width: 500, child: SingleChildScrollView(child: SelectableText(data))), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))])); })), Card(child: ListTile(leading: const Icon(Icons.upload_file, color: blue), title: const Text('Import incidents from JSON'), subtitle: const Text('Paste a previously exported JSON object'), onTap: () async { final controller = TextEditingController(); final accepted = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Import JSON'), content: TextField(controller: controller, maxLines: 8, decoration: const InputDecoration(hintText: 'Paste JSON here')), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Import'))])); if (accepted == true) { try { final count = await AppDatabase.instance.importIncidentsJson(controller.text); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imported $count incident(s).'))); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid JSON: $e'))); } } controller.dispose(); })), const SizedBox(height: 14), const Text('Local database: SQLite on this device. JSON export is a backup format, not a cloud sync service. Do not share exports containing personal or location data publicly.', style: TextStyle(fontSize: 12, color: Colors.black54))])); }

Future<void> _call(String phone) async { final uri = Uri(scheme: 'tel', path: phone); if (!await launchUrl(uri)) throw Exception('Could not open phone dialler.'); }
Future<void> _openMap(double lat, double lng) async { final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'); if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) throw Exception('Could not open Google Maps.'); }
