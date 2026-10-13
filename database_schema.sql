-- SQLite schema used by lib/services/app_database.dart
CREATE TABLE incidents (
  id TEXT PRIMARY KEY,
  category TEXT NOT NULL,
  emergencyType TEXT NOT NULL,
  description TEXT NOT NULL,
  contactName TEXT NOT NULL,
  contactPhone TEXT NOT NULL,
  latitude REAL,
  longitude REAL,
  status TEXT NOT NULL,
  priority TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  userEmail TEXT NOT NULL
);
CREATE TABLE users (
  email TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  passwordHash TEXT NOT NULL,
  createdAt TEXT NOT NULL
);
CREATE TABLE responders (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  role TEXT NOT NULL,
  phone TEXT NOT NULL,
  available INTEGER NOT NULL
);
