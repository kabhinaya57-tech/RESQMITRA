import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/incident.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  Database? _db;
  final _uuid = const Uuid();

  Future<Database> get database async {
    if (_db != null) return _db!;
    final base = await getDatabasesPath();
    _db = await openDatabase(p.join(base, 'pratham_raksha.db'), version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE incidents(
          id TEXT PRIMARY KEY, category TEXT NOT NULL, emergencyType TEXT NOT NULL,
          description TEXT NOT NULL, contactName TEXT NOT NULL, contactPhone TEXT NOT NULL,
          latitude REAL, longitude REAL, status TEXT NOT NULL, priority TEXT NOT NULL,
          createdAt TEXT NOT NULL, userEmail TEXT NOT NULL)''');
        await db.execute('''CREATE TABLE users(
          email TEXT PRIMARY KEY, name TEXT NOT NULL, passwordHash TEXT NOT NULL, createdAt TEXT NOT NULL)''');
        await db.execute('''CREATE TABLE responders(
          id TEXT PRIMARY KEY, name TEXT NOT NULL, role TEXT NOT NULL, phone TEXT NOT NULL, available INTEGER NOT NULL)''');
        await db.insert('responders', {'id':'R-101','name':'Emergency Medical Services','role':'Ambulance / Medical','phone':'112','available':1});
        await db.insert('responders', {'id':'R-102','name':'Police Emergency','role':'Police / Safety','phone':'112','available':1});
        await db.insert('responders', {'id':'R-103','name':'Women Helpline','role':'Women safety support','phone':'181','available':1});
      });
    return _db!;
  }

  String _hash(String value) => sha256.convert(utf8.encode(value)).toString();

  Future<String?> register({required String name, required String email, required String password}) async {
    final db = await database;
    final normalized = email.trim().toLowerCase();
    if (name.trim().isEmpty || !normalized.contains('@') || password.length < 8) {
      return 'Enter a name, valid email, and password of at least 8 characters.';
    }
    final existing = await db.query('users', where: 'email = ?', whereArgs: [normalized]);
    if (existing.isNotEmpty) return 'An account with this email already exists.';
    await db.insert('users', {'email': normalized, 'name': name.trim(), 'passwordHash': _hash(password), 'createdAt': DateTime.now().toIso8601String()});
    return null;
  }

  Future<Map<String, Object?>?> login(String email, String password) async {
    final db = await database;
    final rows = await db.query('users', where: 'email = ? AND passwordHash = ?', whereArgs: [email.trim().toLowerCase(), _hash(password)]);
    return rows.isEmpty ? null : rows.first;
  }

  Future<String> createIncident({required String category, required String emergencyType,
    required String description, required String contactName, required String contactPhone,
    double? latitude, double? longitude, required String userEmail}) async {
    final db = await database;
    final id = 'PR-${DateTime.now().year}-${_uuid.v4().substring(0, 8).toUpperCase()}';
    await db.insert('incidents', Incident(id: id, category: category, emergencyType: emergencyType,
      description: description, contactName: contactName, contactPhone: contactPhone,
      latitude: latitude, longitude: longitude, status: 'Created', priority: 'High',
      createdAt: DateTime.now().toIso8601String(), userEmail: userEmail).toMap());
    return id;
  }

  Future<List<Incident>> incidents({String? email}) async {
    final db = await database;
    final rows = await db.query('incidents', where: email == null || email.isEmpty ? null : 'userEmail = ?',
      whereArgs: email == null || email.isEmpty ? null : [email], orderBy: 'createdAt DESC');
    return rows.map(Incident.fromMap).toList();
  }

  Future<Incident?> incidentById(String id) async {
    final db = await database;
    final rows = await db.query('incidents', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Incident.fromMap(rows.first);
  }

  Future<void> updateStatus(String id, String status) async {
    final db = await database;
    await db.update('incidents', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> responders() async => (await database).query('responders', orderBy: 'name');

  Future<String> exportJson() async {
    final db = await database;
    final incidentRows = await db.query('incidents', orderBy: 'createdAt DESC');
    final responderRows = await db.query('responders');
    // Password hashes are intentionally excluded from exports.
    final userRows = await db.query('users', columns: ['email', 'name', 'createdAt']);
    return const JsonEncoder.withIndent('  ').convert({'schemaVersion': 1, 'exportedAt': DateTime.now().toIso8601String(),
      'incidents': incidentRows, 'responders': responderRows, 'users': userRows});
  }

  Future<int> importIncidentsJson(String jsonText) async {
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map || decoded['incidents'] is! List) throw const FormatException('JSON must contain an incidents array.');
    final db = await database;
    int count = 0;
    for (final item in decoded['incidents'] as List) {
      if (item is! Map) continue;
      final map = Map<String, Object?>.from(item);
      final id = map['id'];
      if (id is! String || id.isEmpty) continue;
      final exists = await db.query('incidents', columns: ['id'], where: 'id = ?', whereArgs: [id]);
      if (exists.isNotEmpty) continue;
      final required = ['category','emergencyType','description','contactName','contactPhone','status','priority','createdAt','userEmail'];
      if (required.any((key) => map[key] == null)) continue;
      await db.insert('incidents', map, conflictAlgorithm: ConflictAlgorithm.ignore);
      count++;
    }
    return count;
  }
}
