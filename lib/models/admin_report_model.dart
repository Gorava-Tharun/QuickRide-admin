/// Step 47: Admin Dashboard & Reports Data Models
class AdminDashboardOverview {
  final int totalUsers;
  final int activeUsers;
  final int totalCaptains;
  final int verifiedCaptains;
  final int pendingCaptains;
  final int onlineCaptains;
  final int totalRides;
  final int completedRides;
  final int cancelledRides;
  final int activeRides;
  final double totalRevenue;
  final double todayRevenue;
  final double weeklyRevenue;
  final double monthlyRevenue;
  final int activeEmergencies;
  final int activeComplaints;

  const AdminDashboardOverview({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalCaptains,
    required this.verifiedCaptains,
    required this.pendingCaptains,
    required this.onlineCaptains,
    required this.totalRides,
    required this.completedRides,
    required this.cancelledRides,
    required this.activeRides,
    required this.totalRevenue,
    required this.todayRevenue,
    required this.weeklyRevenue,
    required this.monthlyRevenue,
    required this.activeEmergencies,
    required this.activeComplaints,
  });

  bool get isEmpty => totalUsers == 0 && totalCaptains == 0 && totalRides == 0;
}

/// Ride Performance & Volume Statistics
class AdminRideReportStats {
  final int totalRides;
  final int completedRides;
  final int cancelledRides;
  final int activeRides;
  final double completionRate; // percentage 0 - 100
  final double cancellationRate; // percentage 0 - 100
  final Map<String, int> ridesByVehicleType; // e.g. {'Bike': 4, 'Auto': 2, 'Car': 2}
  final Map<String, double> revenueByVehicleType;
  final int dailyRides;
  final int weeklyRides;
  final int monthlyRides;
  final double averageRideFare;
  final double averageRideDistance;

  const AdminRideReportStats({
    required this.totalRides,
    required this.completedRides,
    required this.cancelledRides,
    required this.activeRides,
    required this.completionRate,
    required this.cancellationRate,
    required this.ridesByVehicleType,
    required this.revenueByVehicleType,
    required this.dailyRides,
    required this.weeklyRides,
    required this.monthlyRides,
    required this.averageRideFare,
    required this.averageRideDistance,
  });
}

/// User Registration & Activity Statistics
class AdminUserReportStats {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int usersRegisteredToday;
  final int usersRegisteredThisWeek;
  final int usersRegisteredThisMonth;
  final int usersWithCompletedRides;
  final double averageRidesPerUser;

  const AdminUserReportStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.usersRegisteredToday,
    required this.usersRegisteredThisWeek,
    required this.usersRegisteredThisMonth,
    required this.usersWithCompletedRides,
    required this.averageRidesPerUser,
  });
}

/// Captain Top Performer Record
class AdminCaptainPerformance {
  final String captainId;
  final String name;
  final String vehicleType;
  final String vehicleNumber;
  final int completedRides;
  final double rating;
  final bool isOnline;
  final String verificationStatus;

  const AdminCaptainPerformance({
    required this.captainId,
    required this.name,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.completedRides,
    required this.rating,
    required this.isOnline,
    required this.verificationStatus,
  });
}

/// Captain Fleet & Duty Statistics
class AdminCaptainReportStats {
  final int totalCaptains;
  final int verifiedCaptains;
  final int pendingCaptains;
  final int rejectedCaptains;
  final int onlineCaptains;
  final int offlineCaptains;
  final Map<String, int> captainsByVehicleType;
  final double averageCompletedRides;
  final double averageRating;
  final List<AdminCaptainPerformance> topCaptains;

  const AdminCaptainReportStats({
    required this.totalCaptains,
    required this.verifiedCaptains,
    required this.pendingCaptains,
    required this.rejectedCaptains,
    required this.onlineCaptains,
    required this.offlineCaptains,
    required this.captainsByVehicleType,
    required this.averageCompletedRides,
    required this.averageRating,
    required this.topCaptains,
  });
}

/// Revenue & Financial Breakdown Statistics
class AdminRevenueReportStats {
  final double totalGrossCollected;
  final double todayGrossRevenue;
  final double weeklyGrossRevenue;
  final double monthlyGrossRevenue;
  final double totalPlatformCommission; // 15% platform share
  final double totalCaptainEarnings; // 85% captain share
  final double totalRefundAmount;
  final int totalRefundsCount;
  final double totalDiscountsGiven;
  final double totalCancellationFees;
  final Map<String, double> paymentMethodBreakdown;
  final Map<String, int> paymentStatusCounts;
  final Map<String, double> paymentStatusAmounts;

  const AdminRevenueReportStats({
    required this.totalGrossCollected,
    required this.todayGrossRevenue,
    required this.weeklyGrossRevenue,
    required this.monthlyGrossRevenue,
    required this.totalPlatformCommission,
    required this.totalCaptainEarnings,
    required this.totalRefundAmount,
    required this.totalRefundsCount,
    required this.totalDiscountsGiven,
    required this.totalCancellationFees,
    required this.paymentMethodBreakdown,
    required this.paymentStatusCounts,
    required this.paymentStatusAmounts,
  });
}

/// Legacy / Summary Report Stats (backward compatible)
class AdminReportStats {
  final double todayRevenue;
  final double weeklyRevenue;
  final double monthlyRevenue;
  final int dailyRides;
  final int weeklyRides;
  final int monthlyRides;
  final int completedRides;
  final int cancelledRides;
  final int activeCaptains;

  const AdminReportStats({
    required this.todayRevenue,
    required this.weeklyRevenue,
    required this.monthlyRevenue,
    required this.dailyRides,
    required this.weeklyRides,
    required this.monthlyRides,
    required this.completedRides,
    required this.cancelledRides,
    required this.activeCaptains,
  });
}

enum ReconciliationIssueType {
  completedRideUnpaid,
  paidPaymentIncompleteRide,
  duplicatePayment,
  amountMismatch,
}

class ReconciliationIssue {
  final String id;
  final ReconciliationIssueType type;
  final String title;
  final String description;
  final String? rideId;
  final String? paymentId;
  final double? amount;
  final DateTime timestamp;
  final String severity; // 'HIGH', 'MEDIUM', 'LOW'

  const ReconciliationIssue({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.rideId,
    this.paymentId,
    this.amount,
    required this.timestamp,
    this.severity = 'MEDIUM',
  });
}
