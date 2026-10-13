class Incident {
  final String id;
  final String category;
  final String emergencyType;
  final String description;
  final String contactName;
  final String contactPhone;
  final double? latitude;
  final double? longitude;
  final String status;
  final String priority;
  final String createdAt;
  final String userEmail;

  const Incident({required this.id, required this.category, required this.emergencyType,
    required this.description, required this.contactName, required this.contactPhone,
    this.latitude, this.longitude, required this.status, required this.priority,
    required this.createdAt, required this.userEmail});

  Map<String, Object?> toMap() => {
    'id': id, 'category': category, 'emergencyType': emergencyType,
    'description': description, 'contactName': contactName, 'contactPhone': contactPhone,
    'latitude': latitude, 'longitude': longitude, 'status': status,
    'priority': priority, 'createdAt': createdAt, 'userEmail': userEmail,
  };

  factory Incident.fromMap(Map<String, Object?> map) => Incident(
    id: map['id'] as String, category: map['category'] as String,
    emergencyType: map['emergencyType'] as String,
    description: (map['description'] ?? '') as String,
    contactName: (map['contactName'] ?? '') as String,
    contactPhone: (map['contactPhone'] ?? '') as String,
    latitude: map['latitude'] == null ? null : (map['latitude'] as num).toDouble(),
    longitude: map['longitude'] == null ? null : (map['longitude'] as num).toDouble(),
    status: map['status'] as String, priority: map['priority'] as String,
    createdAt: map['createdAt'] as String, userEmail: (map['userEmail'] ?? '') as String,
  );
}
