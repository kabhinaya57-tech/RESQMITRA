import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/incident.dart';
import 'services/app_database.dart';

const navy = Color(0xFF063768);
const blue = Color(0xFF1475D1);
const pink = Color(0xFFE91E63);

void main() => runApp(const PrathamRakshaApp());

class PrathamRakshaApp extends StatelessWidget {
  const PrathamRakshaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'PRATHAM-RAKSHA', debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: navy), scaffoldBackgroundColor: const Color(0xFFF5F7FB), useMaterial3: true,
      appBarTheme: const AppBarTheme(backgroundColor: navy, foregroundColor: Colors.white, centerTitle: false),
      inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white)),
    home: const MainShell(),
  );
}

class MainShell extends StatefulWidget { const MainShell({super.key}); @override State<MainShell> createState() => _MainShellState(); }
class _MainShellState extends State<MainShell> {
  int tab = 0;
  String userName = 'Guest User';
  String userEmail = '';
  String? trackingId;
  bool get signedIn => userEmail.isNotEmpty;
  void go(int index) => setState(() => tab = index);
  void setUser(Map<String, Object?> user) { setState(() { userName = user['name'] as String; userEmail = user['email'] as String; tab = 0; }); }
  void openSos(String type) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SosScreen(category: type, email: userEmail, onCreated: (id) {
      setState(() => trackingId = id);
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingScreen(id: id)));
    })));
  }
  @override Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(userName: userName, signedIn: signedIn, onSos: openSos,
        onLogin: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AuthScreen(onSuccess: setUser))),
        onIncidents: () => setState(() => tab = 1),
        onTrack: (id) => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingScreen(id: id)))),
      IncidentsScreen(email: userEmail, onTrack: (id) => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingScreen(id: id)))),
      const RespondersScreen(),
      const MapScreen(),
      ProfileScreen(name: userName, email: userEmail, onLogin: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AuthScreen(onSuccess: setUser))), onLogout: () => setState(() { userName = 'Guest User'; userEmail = ''; tab = 0; })),
    ];
    return Scaffold(body: SafeArea(child: IndexedStack(index: tab, children: pages)), bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: go, destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Incidents'),
      NavigationDestination(icon: Icon(Icons.health_and_safety_outlined), selectedIcon: Icon(Icons.health_and_safety), label: 'Responders'),
      NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
      NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
    ]));
  }
}

class HomeScreen extends StatelessWidget {
  final String userName; final bool signedIn; final void Function(String) onSos; final VoidCallback onLogin; final VoidCallback onIncidents; final void Function(String) onTrack;
  const HomeScreen({super.key, required this.userName, required this.signedIn, required this.onSos, required this.onLogin, required this.onIncidents, required this.onTrack});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(22)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('PRATHAM-RAKSHA', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: .5)),
      const SizedBox(height: 8), Text('Protect every life. ${signedIn ? 'Welcome, $userName.' : 'Your local emergency companion.'}', style: const TextStyle(color: Colors.white70, fontSize: 15)),
      const SizedBox(height: 18), const Row(children: [Icon(Icons.shield_outlined, color: Colors.white), SizedBox(width: 8), Expanded(child: Text('Safety • Support • Community', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)))])
    ])),
    const SizedBox(height: 20), const Text('NEED HELP NOW?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: navy)),
    const SizedBox(height: 10), Row(children: [Expanded(child: _SosCard(title: 'GENERAL SOS', subtitle: 'Accident, medical or other emergency', color: blue, icon: Icons.sos, onTap: () => onSos('General'))), const SizedBox(width: 12), Expanded(child: _SosCard(title: 'WOMEN SOS', subtitle: 'Women safety and urgent support', color: pink, icon: Icons.shield, onTap: () => onSos('Women')))]),
    const SizedBox(height: 20), Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Important emergency contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 5), const Text('India emergency response number: 112'), const SizedBox(height: 10), FilledButton.icon(onPressed: () => _call('112'), icon: const Icon(Icons.call), label: const Text('Call 112'))]))),
    const SizedBox(height: 18), const Text('QUICK ACCESS', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: navy)), const SizedBox(height: 8),
    _QuickTile(icon: Icons.assignment, title: 'My incidents', subtitle: 'Review and track locally saved reports', onTap: onIncidents),
    _QuickTile(icon: Icons.location_on, title: 'Share / view location', subtitle: 'Open map and current GPS location', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()))),
    const SizedBox(height: 12), if (!signedIn) OutlinedButton.icon(onPressed: onLogin, icon: const Icon(Icons.login), label: const Text('Sign in or create account')),
    const SizedBox(height: 12), const Text('Prototype notice: reports are stored on this device. SOS submission does not automatically alert police, ambulance services, or a staffed response centre.', style: TextStyle(color: Colors.black54, fontSize: 12)),
  ]);
}

class _SosCard extends StatelessWidget { final String title, subtitle; final Color color; final IconData icon; final VoidCallback onTap; const _SosCard({required this.title, required this.subtitle, required this.color, required this.icon, required this.onTap});
  @override Widget build(BuildContext context) => Material(color: color, borderRadius: BorderRadius.circular(18), child: InkWell(borderRadius: BorderRadius.circular(18), onTap: onTap, child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: Colors.white, size: 34), const SizedBox(height: 12), Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)), const SizedBox(height: 7), Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.35)), const SizedBox(height: 8), const Align(alignment: Alignment.centerRight, child: Icon(Icons.arrow_forward, color: Colors.white))])))); }
class _QuickTile extends StatelessWidget { final IconData icon; final String title, subtitle; final VoidCallback onTap; const _QuickTile({required this.icon, required this.title, required this.subtitle, required this.onTap}); @override Widget build(BuildContext context) => Card(child: ListTile(leading: Icon(icon, color: blue), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right), onTap: onTap)); }

class SosScreen extends StatefulWidget { final String category, email; final ValueChanged<String> onCreated; const SosScreen({super.key, required this.category, required this.email, required this.onCreated}); @override State<SosScreen> createState() => _SosScreenState(); }
class _SosScreenState extends State<SosScreen> {
  final form = GlobalKey<FormState>(); final description = TextEditingController(); final name = TextEditingController(); final phone = TextEditingController();
  String type = 'Medical emergency'; String priority = 'High'; Position? position; bool locating = false; bool submitting = false;
  final types = const ['Medical emergency','Accident / injury','Police / safety','Fire','Women safety','Other'];
  Future<void> getLocation() async { setState(() => locating = true); try { var enabled = await Geolocator.isLocationServiceEnabled(); if (!enabled) throw Exception('Turn on device location and try again.'); var permission = await Geolocator.checkPermission(); if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission(); if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) throw Exception('Location permission was not granted. You can still submit without GPS.'); position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15))); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location captured for this report.'))); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')))); } finally { if (mounted) setState(() => locating = false); } }
  Future<void> submit() async { if (!form.currentState!.validate()) return; setState(() => submitting = true); try { final id = await AppDatabase.instance.createIncident(category: widget.category, emergencyType: type, description: description.text.trim(), contactName: name.text.trim(), contactPhone: phone.text.trim(), latitude: position?.latitude, longitude: position?.longitude, userEmail: widget.email); if (mounted) widget.onCreated(id); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save report: $e'))); } finally { if (mounted) setState(() => submitting = false); } }
  @override void dispose() { description.dispose(); name.dispose(); phone.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('${widget.category.toUpperCase()} SOS')), body: Form(key: form, child: ListView(padding: const EdgeInsets.all(18), children: [Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: widget.category == 'Women' ? pink.withOpacity(.1) : blue.withOpacity(.1), borderRadius: BorderRadius.circular(16)), child: Text(widget.category == 'Women' ? 'Women safety emergency report' : 'General emergency report', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: navy))), const SizedBox(height: 16), DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'Emergency type'), items: types.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => type = v ?? type)), const SizedBox(height: 12), TextFormField(controller: description, decoration: const InputDecoration(labelText: 'What happened?', hintText: 'Describe the emergency'), maxLines: 3, validator: (v) => (v == null || v.trim().isEmpty) ? 'Please describe the emergency.' : null), const SizedBox(height: 12), TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Contact name (optional)')), const SizedBox(height: 12), TextFormField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Contact phone (optional)')), const SizedBox(height: 14), OutlinedButton.icon(onPressed: locating ? null : getLocation, icon: locating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location), label: Text(position == null ? 'Capture current GPS location (optional)' : 'Location captured: ${position!.latitude.toStringAsFixed(5)}, ${position!.longitude.toStringAsFixed(5)}')), if (position == null) const Padding(padding: EdgeInsets.only(top: 6), child: Text('You can submit without location. No location is invented if GPS is unavailable.', style: TextStyle(fontSize: 12, color: Colors.black54))), const SizedBox(height: 20), FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: widget.category == 'Women' ? pink : blue, padding: const EdgeInsets.all(16)), onPressed: submitting ? null : submit, icon: const Icon(Icons.save), label: Text(submitting ? 'Saving report…' : 'SAVE SOS REPORT')), const SizedBox(height: 12), const Text('This prototype saves the report locally on this device. It does not dispatch emergency services or send a remote alert.', style: TextStyle(fontSize: 12, color: Colors.redAccent)),])));
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
                        backgroundColor: incident.category == 'Women' ? pink : blue,
                        child: Icon(
                          incident.category == 'Women' ? Icons.shield : Icons.sos,
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
class _TrackingScreenState extends State<TrackingScreen> { late Future<Incident?> future; @override void initState() { super.initState(); future = AppDatabase.instance.incidentById(widget.id); } @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Incident tracking')), body: FutureBuilder<Incident?>(future: future, builder: (context, snap) { if (widget.id.isEmpty) return const Center(child: Text('Open the Incidents tab to select a saved report.')); if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator()); final i = snap.data; if (i == null) return const Center(child: Text('Incident not found on this device.')); return ListView(padding: const EdgeInsets.all(18), children: [Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.track_changes, size: 40, color: blue), const SizedBox(height: 12), const Text('REFERENCE NUMBER', style: TextStyle(color: Colors.black54)), SelectableText(i.id, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: navy)), const Divider(height: 28), _DetailLine('Category', i.category), _DetailLine('Type', i.emergencyType), _DetailLine('Status', i.status), _DetailLine('Priority', i.priority), _DetailLine('Description', i.description), _DetailLine('Created', DateTime.tryParse(i.createdAt)?.toLocal().toString().split('.').first ?? i.createdAt), _DetailLine('Contact', i.contactName.isEmpty ? 'Not provided' : i.contactName), if (i.latitude != null && i.longitude != null) _DetailLine('GPS', '${i.latitude}, ${i.longitude}'), if (i.latitude != null && i.longitude != null) FilledButton.icon(onPressed: () => _openMap(i.latitude!, i.longitude!), icon: const Icon(Icons.map), label: const Text('Open location in Google Maps')), const SizedBox(height: 12), const Text('Status is stored locally in this prototype. It does not indicate that a responder has received or acknowledged the alert.', style: TextStyle(color: Colors.redAccent, fontSize: 12))])))]); })) ; }
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
class _AuthScreenState extends State<AuthScreen> { bool registering = false, busy = false; final name = TextEditingController(); final email = TextEditingController(); final password = TextEditingController(); Future<void> submit() async { setState(() => busy = true); try { if (registering) { final error = await AppDatabase.instance.register(name: name.text, email: email.text, password: password.text); if (error != null) throw Exception(error); } final user = await AppDatabase.instance.login(email.text, password.text); if (user == null) throw Exception('Login failed. Check your email and password.'); if (mounted) { Navigator.pop(context); widget.onSuccess(user); } } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')))); } finally { if (mounted) setState(() => busy = false); } } @override void dispose() { name.dispose(); email.dispose(); password.dispose(); super.dispose(); } @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(registering ? 'Create account' : 'Sign in')), body: ListView(padding: const EdgeInsets.all(20), children: [const Icon(Icons.shield_moon, size: 64, color: navy), const SizedBox(height: 12), Text(registering ? 'Create a local prototype account' : 'Welcome back', textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navy)), const SizedBox(height: 20), if (registering) ...[TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name')), const SizedBox(height: 12)], TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')), const SizedBox(height: 12), TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password (minimum 8 characters)')), const SizedBox(height: 18), FilledButton(onPressed: busy ? null : submit, child: Text(busy ? 'Please wait…' : registering ? 'Register' : 'Login')), TextButton(onPressed: () => setState(() => registering = !registering), child: Text(registering ? 'Already registered? Sign in' : 'New user? Create an account')), const Text('Prototype authentication is stored locally on this device. Use a secure backend such as Firebase Authentication before public deployment.', style: TextStyle(fontSize: 12, color: Colors.redAccent))])); }

class ProfileScreen extends StatelessWidget { final String name, email; final VoidCallback onLogin, onLogout; const ProfileScreen({super.key, required this.name, required this.email, required this.onLogin, required this.onLogout}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Profile & data')), body: ListView(padding: const EdgeInsets.all(18), children: [CircleAvatar(radius: 38, backgroundColor: navy, child: Text(name.isEmpty ? 'G' : name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 28))), const SizedBox(height: 12), Text(name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), Text(email.isEmpty ? 'Not signed in' : email, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)), const SizedBox(height: 20), if (email.isEmpty) FilledButton.icon(onPressed: onLogin, icon: const Icon(Icons.login), label: const Text('Sign in / Register')) else OutlinedButton.icon(onPressed: onLogout, icon: const Icon(Icons.logout), label: const Text('Sign out')), const SizedBox(height: 12), Card(child: ListTile(leading: const Icon(Icons.data_object, color: blue), title: const Text('Export database as JSON'), subtitle: const Text('View a JSON backup of incidents and non-secret records'), onTap: () async { final data = await AppDatabase.instance.exportJson(); if (context.mounted) showDialog(context: context, builder: (_) => AlertDialog(title: const Text('JSON backup'), content: SizedBox(width: 500, child: SingleChildScrollView(child: SelectableText(data))), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))])); })), Card(child: ListTile(leading: const Icon(Icons.upload_file, color: blue), title: const Text('Import incidents from JSON'), subtitle: const Text('Paste a previously exported JSON object'), onTap: () async { final controller = TextEditingController(); final accepted = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Import JSON'), content: TextField(controller: controller, maxLines: 8, decoration: const InputDecoration(hintText: 'Paste JSON here')), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Import'))])); if (accepted == true) { try { final count = await AppDatabase.instance.importIncidentsJson(controller.text); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imported $count incident(s).'))); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid JSON: $e'))); } } controller.dispose(); })), const SizedBox(height: 14), const Text('Local database: SQLite on this device. JSON export is a backup format, not a cloud sync service. Do not share exports containing personal or location data publicly.', style: TextStyle(fontSize: 12, color: Colors.black54))])); }

Future<void> _call(String phone) async { final uri = Uri(scheme: 'tel', path: phone); if (!await launchUrl(uri)) throw Exception('Could not open phone dialler.'); }
Future<void> _openMap(double lat, double lng) async { final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'); if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) throw Exception('Could not open Google Maps.'); }
