enum AdminRideStatus {
  requested,
  accepted,
  arrived,
  inProgress,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case AdminRideStatus.requested:
        return 'Requested';
      case AdminRideStatus.accepted:
        return 'Accepted';
      case AdminRideStatus.arrived:
        return 'Arrived';
      case AdminRideStatus.inProgress:
        return 'In Progress';
      case AdminRideStatus.completed:
        return 'Completed';
      case AdminRideStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class AdminRideModel {
  final String id;
  final String passengerName;
  final String passengerPhone;
  final String? captainName;
  final String? captainPhone;
  final String pickupAddress;
  final String destinationAddress;
  final double pickupLat;
  final double pickupLng;
  final double destLat;
  final double destLng;
  final double? captainLat;
  final double? captainLng;
  final String vehicleType;
  final double fare;
  final double distanceKm;
  final int durationMins;
  final AdminRideStatus status;
  final DateTime timestamp;
  final String? cancelledBy;
  final String? cancellationReason;
  final String? cancellationDescription;
  final double? cancellationFee;
  final double? refundAmount;
  final String? refundStatus;
  final String? refundId;
  final DateTime? refundedAt;
  final DateTime? cancelledAt;
  final String? paymentStatus;
  final String? paymentMethod;

  const AdminRideModel({
    required this.id,
    required this.passengerName,
    required this.passengerPhone,
    this.captainName,
    this.captainPhone,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.destLat,
    required this.destLng,
    this.captainLat,
    this.captainLng,
    required this.vehicleType,
    required this.fare,
    required this.distanceKm,
    required this.durationMins,
    required this.status,
    required this.timestamp,
    this.cancelledBy,
    this.cancellationReason,
    this.cancellationDescription,
    this.cancellationFee,
    this.refundAmount,
    this.refundStatus,
    this.refundId,
    this.refundedAt,
    this.cancelledAt,
    this.paymentStatus,
    this.paymentMethod,
  });

  bool get isCancelled => status == AdminRideStatus.cancelled;
  bool get isRefunded =>
      (refundStatus != null && refundStatus!.toUpperCase() == 'COMPLETED') ||
      (refundAmount != null && refundAmount! > 0);
  bool get isCancelledByUser =>
      isCancelled &&
      (cancelledBy?.toLowerCase() == 'user' ||
          cancelledBy?.toLowerCase() == 'passenger');
  bool get isCancelledByCaptain =>
      isCancelled && cancelledBy?.toLowerCase() == 'captain';

  AdminRideModel copyWith({
    String? id,
    String? passengerName,
    String? passengerPhone,
    String? captainName,
    String? captainPhone,
    String? pickupAddress,
    String? destinationAddress,
    double? pickupLat,
    double? pickupLng,
    double? destLat,
    double? destLng,
    double? captainLat,
    double? captainLng,
    String? vehicleType,
    double? fare,
    double? distanceKm,
    int? durationMins,
    AdminRideStatus? status,
    DateTime? timestamp,
    String? cancelledBy,
    String? cancellationReason,
    String? cancellationDescription,
    double? cancellationFee,
    double? refundAmount,
    String? refundStatus,
    String? refundId,
    DateTime? refundedAt,
    DateTime? cancelledAt,
    String? paymentStatus,
    String? paymentMethod,
  }) {
    return AdminRideModel(
      id: id ?? this.id,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      captainName: captainName ?? this.captainName,
      captainPhone: captainPhone ?? this.captainPhone,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      destLat: destLat ?? this.destLat,
      destLng: destLng ?? this.destLng,
      captainLat: captainLat ?? this.captainLat,
      captainLng: captainLng ?? this.captainLng,
      vehicleType: vehicleType ?? this.vehicleType,
      fare: fare ?? this.fare,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMins: durationMins ?? this.durationMins,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancellationDescription:
          cancellationDescription ?? this.cancellationDescription,
      cancellationFee: cancellationFee ?? this.cancellationFee,
      refundAmount: refundAmount ?? this.refundAmount,
      refundStatus: refundStatus ?? this.refundStatus,
      refundId: refundId ?? this.refundId,
      refundedAt: refundedAt ?? this.refundedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
