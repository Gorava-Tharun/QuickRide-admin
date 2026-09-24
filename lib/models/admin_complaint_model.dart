import 'firestore_models.dart';

enum ComplaintStatus {
  open,
  inReview,
  resolved,
  closed;

  String get label {
    switch (this) {
      case ComplaintStatus.open:
        return 'Open';
      case ComplaintStatus.inReview:
        return 'In Review';
      case ComplaintStatus.resolved:
        return 'Resolved';
      case ComplaintStatus.closed:
        return 'Closed';
    }
  }

  String get firestoreValue {
    switch (this) {
      case ComplaintStatus.open:
        return 'OPEN';
      case ComplaintStatus.inReview:
        return 'IN_REVIEW';
      case ComplaintStatus.resolved:
        return 'RESOLVED';
      case ComplaintStatus.closed:
        return 'CLOSED';
    }
  }

  static ComplaintStatus fromString(String val) {
    switch (val.toUpperCase()) {
      case 'OPEN':
        return ComplaintStatus.open;
      case 'IN_REVIEW':
        return ComplaintStatus.inReview;
      case 'RESOLVED':
        return ComplaintStatus.resolved;
      case 'CLOSED':
        return ComplaintStatus.closed;
      default:
        return ComplaintStatus.open;
    }
  }
}

class AdminComplaintModel {
  final String id;
  final String userName;
  final String captainName;
  final String rideId;
  final String subject;
  final String description;
  final DateTime date;
  final ComplaintStatus status;
  final String complainantRole; // 'USER' or 'CAPTAIN'
  final String complainantPhone;
  final String category;
  final String? paymentId;
  final String? attachmentUrl;
  final String priority; // 'LOW', 'NORMAL', 'HIGH', 'URGENT'
  final String? adminNotes;
  final String? resolutionSummary;
  final DateTime? resolvedAt;

  const AdminComplaintModel({
    required this.id,
    required this.userName,
    required this.captainName,
    required this.rideId,
    required this.subject,
    required this.description,
    required this.date,
    required this.status,
    this.complainantRole = 'USER',
    this.complainantPhone = '',
    this.category = 'GENERAL',
    this.paymentId,
    this.attachmentUrl,
    this.priority = 'NORMAL',
    this.adminNotes,
    this.resolutionSummary,
    this.resolvedAt,
  });

  bool get isUser => complainantRole.toUpperCase() == 'USER';
  bool get isCaptain => complainantRole.toUpperCase() == 'CAPTAIN';
  bool get isUrgent => priority.toUpperCase() == 'URGENT';
  bool get isHighPriority => priority.toUpperCase() == 'HIGH' || priority.toUpperCase() == 'URGENT';

  AdminComplaintModel copyWith({
    String? id,
    String? userName,
    String? captainName,
    String? rideId,
    String? subject,
    String? description,
    DateTime? date,
    ComplaintStatus? status,
    String? complainantRole,
    String? complainantPhone,
    String? category,
    String? paymentId,
    String? attachmentUrl,
    String? priority,
    String? adminNotes,
    String? resolutionSummary,
    DateTime? resolvedAt,
  }) {
    return AdminComplaintModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      captainName: captainName ?? this.captainName,
      rideId: rideId ?? this.rideId,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
      complainantRole: complainantRole ?? this.complainantRole,
      complainantPhone: complainantPhone ?? this.complainantPhone,
      category: category ?? this.category,
      paymentId: paymentId ?? this.paymentId,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      priority: priority ?? this.priority,
      adminNotes: adminNotes ?? this.adminNotes,
      resolutionSummary: resolutionSummary ?? this.resolutionSummary,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  factory AdminComplaintModel.fromFirestore(FirestoreComplaintModel f) {
    return AdminComplaintModel(
      id: f.complaintId,
      userName: f.complainantRole == 'USER'
          ? (f.complainantName.isNotEmpty ? f.complainantName : (f.userId ?? 'Rider'))
          : (f.userId ?? 'Rider'),
      captainName: f.complainantRole == 'CAPTAIN'
          ? (f.complainantName.isNotEmpty ? f.complainantName : (f.captainId ?? 'Captain'))
          : (f.captainId ?? 'Captain'),
      rideId: f.rideId ?? '',
      subject: f.subject,
      description: f.description,
      date: f.createdAt,
      status: ComplaintStatus.fromString(f.status),
      complainantRole: f.complainantRole,
      complainantPhone: f.complainantPhone,
      category: f.category,
      paymentId: f.paymentId,
      attachmentUrl: f.attachmentUrl,
      priority: f.priority,
      adminNotes: f.adminNotes,
      resolutionSummary: f.resolutionSummary,
      resolvedAt: f.resolvedAt,
    );
  }

  FirestoreComplaintModel toFirestore() {
    return FirestoreComplaintModel(
      complaintId: id,
      userId: isUser ? userName : null,
      captainId: isCaptain ? captainName : null,
      complainantRole: complainantRole,
      complainantName: isUser ? userName : captainName,
      complainantPhone: complainantPhone,
      category: category,
      subject: subject,
      description: description,
      rideId: rideId.isNotEmpty ? rideId : null,
      paymentId: paymentId,
      attachmentUrl: attachmentUrl,
      status: status.firestoreValue,
      priority: priority,
      adminNotes: adminNotes,
      resolutionSummary: resolutionSummary,
      createdAt: date,
      resolvedAt: resolvedAt,
    );
  }
}
