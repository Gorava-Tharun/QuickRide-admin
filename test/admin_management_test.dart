import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/models/admin_complaint_model.dart';
import 'package:quickride_admin/models/admin_ride_model.dart';
import 'package:quickride_admin/services/admin_state_service.dart';

void main() {
  late AdminStateService service;

  setUp(() {
    service = AdminStateService();
  });

  test('User management search and status toggle', () {
    expect(service.users.isNotEmpty, isTrue);
    final initialCount = service.users.length;

    // Search by name
    final searchResults = service.filterUsers(query: 'Aarav');
    expect(searchResults.length, 1);
    expect(searchResults.first.name, 'Aarav Sharma');

    // Toggle active status
    final user = service.users.first;
    final initialStatus = user.isActive;
    service.toggleUserStatus(user.id);
    final updatedUser = service.users.firstWhere((u) => u.id == user.id);
    expect(updatedUser.isActive, !initialStatus);

    // Revert status
    service.toggleUserStatus(user.id);
    expect(service.users.length, initialCount);
  });

  test('Captain management search and duty/account status', () {
    expect(service.captains.isNotEmpty, isTrue);

    // Search by vehicle number
    final searchVehicle = service.filterCaptains(query: 'KA 01');
    expect(searchVehicle.length, 1);
    expect(searchVehicle.first.name, 'Rajesh Kumar');

    // Toggle captain active status
    final captain = service.captains.first;
    final initialStatus = captain.isActive;
    service.toggleCaptainStatus(captain.id);
    final updatedCaptain = service.captains.firstWhere((c) => c.id == captain.id);
    expect(updatedCaptain.isActive, !initialStatus);

    // Revert
    service.toggleCaptainStatus(captain.id);
  });

  test('Ride filtering and active rides detection', () {
    expect(service.rides.isNotEmpty, isTrue);

    // Filter by completed
    final completed = service.filterRides(statusFilter: AdminRideStatus.completed);
    expect(completed.every((r) => r.status == AdminRideStatus.completed), isTrue);

    // Filter by in progress
    final inProgress = service.filterRides(statusFilter: AdminRideStatus.inProgress);
    expect(inProgress.every((r) => r.status == AdminRideStatus.inProgress), isTrue);

    // Check live rides getter
    final live = service.liveRides;
    expect(live.isNotEmpty, isTrue);
    expect(live.every((r) => r.status == AdminRideStatus.inProgress || r.status == AdminRideStatus.accepted), isTrue);
  });

  test('Complaints update workflow', () {
    expect(service.complaints.isNotEmpty, isTrue);
    final complaint = service.complaints.first;

    service.updateComplaintStatus(complaint.id, ComplaintStatus.inReview);
    var updated = service.complaints.firstWhere((c) => c.id == complaint.id);
    expect(updated.status, ComplaintStatus.inReview);

    service.updateComplaintStatus(complaint.id, ComplaintStatus.resolved);
    updated = service.complaints.firstWhere((c) => c.id == complaint.id);
    expect(updated.status, ComplaintStatus.resolved);
  });

  test('Reports and platform statistics calculations', () {
    final stats = service.reportStats;
    expect(stats.todayRevenue, greaterThan(0));
    expect(stats.weeklyRevenue, greaterThan(stats.todayRevenue));
    expect(stats.monthlyRevenue, greaterThan(stats.weeklyRevenue));
    expect(stats.completedRides, service.completedRidesCount);
    expect(stats.cancelledRides, service.cancelledRidesCount);
  });
}
