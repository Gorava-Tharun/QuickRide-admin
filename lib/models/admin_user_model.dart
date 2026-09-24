class AdminUserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final bool isActive;
  final int totalRides;
  final DateTime joinedDate;
  final String? profileImage;

  const AdminUserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.isActive,
    required this.totalRides,
    required this.joinedDate,
    this.profileImage,
  });

  AdminUserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    bool? isActive,
    int? totalRides,
    DateTime? joinedDate,
    String? profileImage,
  }) {
    return AdminUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      totalRides: totalRides ?? this.totalRides,
      joinedDate: joinedDate ?? this.joinedDate,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'isActive': isActive,
    'totalRides': totalRides,
    'joinedDate': joinedDate.toIso8601String(),
    'profileImage': profileImage,
  };

  factory AdminUserModel.fromJson(Map<String, dynamic> json) => AdminUserModel(
    id: json['id'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String,
    isActive: json['isActive'] as bool,
    totalRides: json['totalRides'] as int,
    joinedDate: DateTime.parse(json['joinedDate'] as String),
    profileImage: (json['profilePhotoUrl'] ?? json['profileImage']) as String?,
  );
}
