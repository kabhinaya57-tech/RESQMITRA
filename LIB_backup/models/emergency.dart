class Emergency {
  final String sosId;
  final String userId;
  final String emergencyType;
  final String description;
  final double? latitude;
  final double? longitude;
  final String urgency;
  final String status;
  final DateTime createdAt;

  const Emergency({
    required this.sosId,
    required this.userId,
    required this.emergencyType,
    required this.description,
    required this.urgency,
    required this.status,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() => {
    'sosId': sosId,
    'userId': userId,
    'emergencyType': emergencyType,
    'description': description,
    'latitude': latitude,
    'longitude': longitude,
    'urgency': urgency,
    'status': status,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': createdAt.toUtc().toIso8601String(),
  };
}
