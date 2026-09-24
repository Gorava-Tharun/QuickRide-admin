class AdminCaptainModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String vehicleNumber;
  final String vehicleType;
  final String licenseNumber;
  final bool isOnline;
  final bool isActive;
  final double rating;
  final int completedRides;
  final DateTime joinedDate;
  final String? profileImage;
  final String? vehicleImage;
  final String verificationStatus;
  final String vehicleVerificationStatus;
  final DateTime? documentsSubmittedAt;
  final DateTime? verifiedAt;
  final String? rejectionReason;
  final String? drivingLicenseImageUrl;
  final String? vehicleDocumentImageUrl;

  bool get isApproved => verificationStatus == 'APPROVED';
  bool get isPending => verificationStatus == 'PENDING';
  bool get isRejected => verificationStatus == 'REJECTED';

  const AdminCaptainModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.licenseNumber,
    required this.isOnline,
    required this.isActive,
    required this.rating,
    required this.completedRides,
    required this.joinedDate,
    this.profileImage,
    this.vehicleImage,
    this.verificationStatus = 'APPROVED',
    this.vehicleVerificationStatus = 'APPROVED',
    this.documentsSubmittedAt,
    this.verifiedAt,
    this.rejectionReason,
    this.drivingLicenseImageUrl,
    this.vehicleDocumentImageUrl,
  });

  AdminCaptainModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? vehicleNumber,
    String? vehicleType,
    String? licenseNumber,
    bool? isOnline,
    bool? isActive,
    double? rating,
    int? completedRides,
    DateTime? joinedDate,
    String? profileImage,
    String? vehicleImage,
    String? verificationStatus,
    String? vehicleVerificationStatus,
    DateTime? documentsSubmittedAt,
    DateTime? verifiedAt,
    String? rejectionReason,
    String? drivingLicenseImageUrl,
    String? vehicleDocumentImageUrl,
  }) {
    return AdminCaptainModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      isOnline: isOnline ?? this.isOnline,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      completedRides: completedRides ?? this.completedRides,
      joinedDate: joinedDate ?? this.joinedDate,
      profileImage: profileImage ?? this.profileImage,
      vehicleImage: vehicleImage ?? this.vehicleImage,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      vehicleVerificationStatus: vehicleVerificationStatus ?? this.vehicleVerificationStatus,
      documentsSubmittedAt: documentsSubmittedAt ?? this.documentsSubmittedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      drivingLicenseImageUrl: drivingLicenseImageUrl ?? this.drivingLicenseImageUrl,
      vehicleDocumentImageUrl: vehicleDocumentImageUrl ?? this.vehicleDocumentImageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'vehicleNumber': vehicleNumber,
    'vehicleType': vehicleType,
    'licenseNumber': licenseNumber,
    'isOnline': isOnline,
    'isActive': isActive,
    'rating': rating,
    'completedRides': completedRides,
    'joinedDate': joinedDate.toIso8601String(),
    'profileImage': profileImage,
    'vehicleImage': vehicleImage,
    'verificationStatus': verificationStatus,
    'vehicleVerificationStatus': vehicleVerificationStatus,
    if (documentsSubmittedAt != null)
      'documentsSubmittedAt': documentsSubmittedAt!.toIso8601String(),
    if (verifiedAt != null) 'verifiedAt': verifiedAt!.toIso8601String(),
    if (rejectionReason != null) 'rejectionReason': rejectionReason,
    if (drivingLicenseImageUrl != null)
      'drivingLicenseImageUrl': drivingLicenseImageUrl,
    if (vehicleDocumentImageUrl != null)
      'vehicleDocumentImageUrl': vehicleDocumentImageUrl,
  };

  factory AdminCaptainModel.fromJson(Map<String, dynamic> json) => AdminCaptainModel(
    id: json['id'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String,
    vehicleNumber: json['vehicleNumber'] as String,
    vehicleType: json['vehicleType'] as String,
    licenseNumber: json['licenseNumber'] as String,
    isOnline: json['isOnline'] as bool,
    isActive: json['isActive'] as bool,
    rating: (json['rating'] as num).toDouble(),
    completedRides: json['completedRides'] as int,
    joinedDate: DateTime.parse(json['joinedDate'] as String),
    profileImage: (json['profilePhotoUrl'] ?? json['profileImage']) as String?,
    vehicleImage: (json['vehiclePhotoUrl'] ?? json['vehicleImage']) as String?,
    verificationStatus: json['verificationStatus'] as String? ?? 'APPROVED',
    vehicleVerificationStatus: json['vehicleVerificationStatus'] as String? ?? 'APPROVED',
    documentsSubmittedAt: json['documentsSubmittedAt'] != null
        ? DateTime.tryParse(json['documentsSubmittedAt'].toString())
        : null,
    verifiedAt: json['verifiedAt'] != null
        ? DateTime.tryParse(json['verifiedAt'].toString())
        : null,
    rejectionReason: json['rejectionReason'] as String?,
    drivingLicenseImageUrl: (json['drivingLicenseImageUrl'] ??
        json['licenseDocumentUrl'] ??
        json['licenseDocUrl']) as String?,
    vehicleDocumentImageUrl: (json['vehicleDocumentImageUrl'] ??
        json['vehicleRcImageUrl'] ??
        json['vehicleDocUrl']) as String?,
  );
}
