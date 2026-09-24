import 'firestore_models.dart';

class AdminEmergencyModel {
  final String emergencyId;
  final String rideId;
  final String userId;
  final String captainId;
  final double latitude;
  final double longitude;
  final EmergencyStatus status;
  final String triggeredBy;
  final String userName;
  final String userPhone;
  final String captainName;
  final String captainPhone;
  final String vehicleNumber;
  final String vehicleType;
  final String pickup;
  final String destination;
  final String? adminNotes;
  final String? resolutionSummary;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  const AdminEmergencyModel({
    required this.emergencyId,
    required this.rideId,
    required this.userId,
    required this.captainId,
    required this.latitude,
    required this.longitude,
    this.status = EmergencyStatus.active,
    required this.triggeredBy,
    this.userName = 'User',
    this.userPhone = '',
    this.captainName = 'Captain',
    this.captainPhone = '',
    this.vehicleNumber = '',
    this.vehicleType = 'Bike',
    this.pickup = 'Current Location',
    this.destination = 'Destination',
    this.adminNotes,
    this.resolutionSummary,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  bool get isActive => status == EmergencyStatus.active;
  bool get isAcknowledged => status == EmergencyStatus.acknowledged;
  bool get isResolved => status == EmergencyStatus.resolved;
  bool get isClosed => status == EmergencyStatus.closed;

  String get statusLabel {
    switch (status) {
      case EmergencyStatus.active:
        return 'ACTIVE';
      case EmergencyStatus.acknowledged:
        return 'ACKNOWLEDGED';
      case EmergencyStatus.resolved:
        return 'RESOLVED';
      case EmergencyStatus.closed:
        return 'CLOSED';
    }
  }

  factory AdminEmergencyModel.fromFirestore(FirestoreEmergencyIncidentModel m) {
    return AdminEmergencyModel(
      emergencyId: m.emergencyId,
      rideId: m.rideId,
      userId: m.userId,
      captainId: m.captainId,
      latitude: m.latitude,
      longitude: m.longitude,
      status: m.status,
      triggeredBy: m.triggeredBy,
      userName: m.userName ?? 'User',
      userPhone: m.userPhone ?? '',
      captainName: m.captainName ?? 'Captain',
      captainPhone: m.captainPhone ?? '',
      vehicleNumber: m.vehicleNumber ?? '',
      vehicleType: m.vehicleType ?? 'Bike',
      pickup: m.pickup ?? 'Pickup Point',
      destination: m.destination ?? 'Destination',
      adminNotes: m.adminNotes,
      resolutionSummary: m.resolutionSummary,
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
      resolvedAt: m.resolvedAt,
    );
  }

  factory AdminEmergencyModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return AdminEmergencyModel.fromFirestore(
      FirestoreEmergencyIncidentModel.fromMap(map, id: id),
    );
  }

  Map<String, dynamic> toMap() => {
    'emergencyId': emergencyId,
    'rideId': rideId,
    'userId': userId,
    'captainId': captainId,
    'latitude': latitude,
    'longitude': longitude,
    'status': status.firestoreValue,
    'triggeredBy': triggeredBy,
    'userName': userName,
    'userPhone': userPhone,
    'captainName': captainName,
    'captainPhone': captainPhone,
    'vehicleNumber': vehicleNumber,
    'vehicleType': vehicleType,
    'pickup': pickup,
    'destination': destination,
    if (adminNotes != null) 'adminNotes': adminNotes,
    if (resolutionSummary != null) 'resolutionSummary': resolutionSummary,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (resolvedAt != null) 'resolvedAt': resolvedAt!.toIso8601String(),
  };

  AdminEmergencyModel copyWith({
    String? emergencyId,
    String? rideId,
    String? userId,
    String? captainId,
    double? latitude,
    double? longitude,
    EmergencyStatus? status,
    String? triggeredBy,
    String? userName,
    String? userPhone,
    String? captainName,
    String? captainPhone,
    String? vehicleNumber,
    String? vehicleType,
    String? pickup,
    String? destination,
    String? adminNotes,
    String? resolutionSummary,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  }) {
    return AdminEmergencyModel(
      emergencyId: emergencyId ?? this.emergencyId,
      rideId: rideId ?? this.rideId,
      userId: userId ?? this.userId,
      captainId: captainId ?? this.captainId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      triggeredBy: triggeredBy ?? this.triggeredBy,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      captainName: captainName ?? this.captainName,
      captainPhone: captainPhone ?? this.captainPhone,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      adminNotes: adminNotes ?? this.adminNotes,
      resolutionSummary: resolutionSummary ?? this.resolutionSummary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}