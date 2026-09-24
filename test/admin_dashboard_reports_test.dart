import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/screens/dashboard/admin_dashboard_screen.dart';
import 'package:quickride_admin/screens/reports/admin_reports_screen.dart';
import 'package:quickride_admin/services/admin_state_service.dart';

void main() {
  late AdminStateService service;

  setUp(() {
    service = AdminStateService();
    service.resetMockData();
  });

  group('Step 47: Admin Dashboard Metrics & Overview Tests', () {
    test('Dashboard Overview contains all 8 required real metrics', () {
      final overview = service.dashboardOverview;

      // 1. Total Users
      expect(overview.totalUsers, equals(service.totalUsersCount));
      expect(overview.totalUsers, greaterThan(0));

      // 2. Total Captains
      expect(overview.totalCaptains, equals(service.totalCaptainsCount));
      expect(overview.totalCaptains, greaterThan(0));

      // 3. Verified Captains
      expect(overview.verifiedCaptains, equals(service.verifiedCaptainsCount));
      expect(overview.verifiedCaptains, greaterThanOrEqualTo(0));

      // 4. Total Rides
      expect(overview.totalRides, equals(service.totalRidesCount));
      expect(overview.totalRides, greaterThan(0));

      // 5. Completed Rides
      expect(overview.completedRides, equals(service.completedRidesCount));
      expect(overview.completedRides, greaterThan(0));

      // 6. Cancelled Rides
      expect(overview.cancelledRides, equals(service.cancelledRidesCount));
      expect(overview.cancelledRides, greaterThan(0));

      // 7. Active Rides
      expect(overview.activeRides, equals(service.activeRidesCount));
      expect(overview.activeRides, greaterThanOrEqualTo(0));

      // 8. Total Revenue
      expect(overview.totalRevenue, equals(service.totalRevenue));
      expect(overview.totalRevenue, greaterThan(0));
    });

    test('Dashboard Overview handles empty database state safely', () {
      service.clearAllData();
      final emptyOverview = service.dashboardOverview;

      expect(emptyOverview.isEmpty, isTrue);
      expect(emptyOverview.totalUsers, 0);
      expect(emptyOverview.totalCaptains, 0);
      expect(emptyOverview.verifiedCaptains, 0);
      expect(emptyOverview.totalRides, 0);
      expect(emptyOverview.completedRides, 0);
      expect(emptyOverview.cancelledRides, 0);
      expect(emptyOverview.activeRides, 0);
      expect(emptyOverview.totalRevenue, 0.0);

      // Restore
      service.resetMockData();
      expect(service.dashboardOverview.isEmpty, isFalse);
    });
  });

  group('Step 47: Ride Reports & Vehicle Type Analytics Tests', () {
    test('Ride reports correctly aggregate Bike, Auto, and Car statistics', () {
      final rideStats = service.rideReportStats;

      expect(rideStats.totalRides, service.totalRidesCount);
      expect(rideStats.completedRides, service.completedRidesCount);
      expect(rideStats.cancelledRides, service.cancelledRidesCount);

      // Vehicle-type counts
      expect(rideStats.ridesByVehicleType.containsKey('Bike'), isTrue);
      expect(rideStats.ridesByVehicleType.containsKey('Auto'), isTrue);
      expect(rideStats.ridesByVehicleType.containsKey('Car'), isTrue);

      final sumVehicleRides = (rideStats.ridesByVehicleType['Bike'] ?? 0) +
          (rideStats.ridesByVehicleType['Auto'] ?? 0) +
          (rideStats.ridesByVehicleType['Car'] ?? 0);
      expect(sumVehicleRides, equals(rideStats.totalRides));

      // Vehicle-type revenue
      final sumVehicleRevenue = (rideStats.revenueByVehicleType['Bike'] ?? 0.0) +
          (rideStats.revenueByVehicleType['Auto'] ?? 0.0) +
          (rideStats.revenueByVehicleType['Car'] ?? 0.0);
      expect(sumVehicleRevenue, equals(rideStats.completedRides > 0 ? service.totalRevenue : 0.0));

      // Rates
      expect(rideStats.completionRate, greaterThan(0));
      expect(rideStats.cancellationRate, greaterThan(0));
      expect(rideStats.completionRate + rideStats.cancellationRate, lessThanOrEqualTo(100.0));
    });

    test('Ride reports calculate daily, weekly, and monthly ride counts', () {
      final stats = service.rideReportStats;
      expect(stats.dailyRides, greaterThanOrEqualTo(0));
      expect(stats.weeklyRides, greaterThanOrEqualTo(stats.dailyRides));
      expect(stats.monthlyRides, greaterThanOrEqualTo(stats.weeklyRides));
    });
  });

  group('Step 47: User Reports Statistics Tests', () {
    test('User reports aggregate active, inactive, and registration metrics', () {
      final userStats = service.userReportStats;

      expect(userStats.totalUsers, equals(service.totalUsersCount));
      expect(userStats.activeUsers + userStats.inactiveUsers, equals(userStats.totalUsers));
      expect(userStats.usersRegisteredToday, greaterThanOrEqualTo(0));
      expect(userStats.usersRegisteredThisWeek, greaterThanOrEqualTo(userStats.usersRegisteredToday));
      expect(userStats.usersRegisteredThisMonth, greaterThanOrEqualTo(userStats.usersRegisteredThisWeek));
      expect(userStats.averageRidesPerUser, greaterThanOrEqualTo(0));
    });
  });

  group('Step 47: Captain Reports & Fleet Analytics Tests', () {
    test('Captain reports aggregate verification statuses, duty, and leaderboard', () {
      final capStats = service.captainReportStats;

      expect(capStats.totalCaptains, equals(service.totalCaptainsCount));
      expect(capStats.verifiedCaptains + capStats.pendingCaptains + capStats.rejectedCaptains,
          equals(capStats.totalCaptains));
      expect(capStats.onlineCaptains + capStats.offlineCaptains, equals(capStats.totalCaptains));

      // Fleet vehicle distribution
      final sumFleet = (capStats.captainsByVehicleType['Bike'] ?? 0) +
          (capStats.captainsByVehicleType['Auto'] ?? 0) +
          (capStats.captainsByVehicleType['Car'] ?? 0);
      expect(sumFleet, equals(capStats.totalCaptains));

      // Top performers
      expect(capStats.topCaptains.isNotEmpty, isTrue);
      expect(capStats.topCaptains.first.completedRides,
          greaterThanOrEqualTo(capStats.topCaptains.last.completedRides));
    });
  });

  group('Step 47: Revenue & Payment Reports Tests', () {
    test('Revenue reports compute gross volume, 15% platform fee, and 85% payouts', () {
      final revStats = service.revenueReportStats;

      expect(revStats.totalGrossCollected, greaterThan(0));
      expect(revStats.totalPlatformCommission, closeTo(revStats.totalGrossCollected * 0.15, 0.01));
      expect(revStats.totalCaptainEarnings, closeTo(revStats.totalGrossCollected * 0.85, 0.01));
      expect(revStats.totalPlatformCommission + revStats.totalCaptainEarnings,
          closeTo(revStats.totalGrossCollected, 0.01));

      // Payment Statuses
      expect(revStats.paymentStatusCounts.containsKey('PAID'), isTrue);
      expect(revStats.paymentStatusAmounts.containsKey('PAID'), isTrue);
      expect(revStats.totalRefundAmount, greaterThanOrEqualTo(0));
    });
  });

  group('Step 47: Admin UI Widget Tests', () {
    testWidgets('AdminDashboardScreen renders all 8 core KPI cards and header', (tester) async {
      int? navigatedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: AdminDashboardScreen(
            onNavigate: (idx) => navigatedIndex = idx,
          ),
        ),
      );
      await tester.pump();

      // Header
      expect(find.text('Platform Overview'), findsOneWidget);
      expect(find.text('Core System Indicators'), findsOneWidget);

      // Verify the 8 core KPI card titles
      expect(find.text('Total Users'), findsOneWidget);
      expect(find.text('Total Captains'), findsOneWidget);
      expect(find.text('Verified Captains'), findsOneWidget);
      expect(find.text('Total Rides'), findsOneWidget);
      expect(find.text('Completed Rides'), findsOneWidget);
      expect(find.text('Cancelled Rides'), findsOneWidget);
      expect(find.text('Active Rides'), findsOneWidget);
      expect(find.text('Total Revenue'), findsOneWidget);

      // Tap on Total Users card -> navigates to Users tab (index 1)
      await tester.tap(find.text('Total Users'));
      expect(navigatedIndex, equals(1));
    });

    testWidgets('AdminReportsScreen renders all 4 tabs and switches content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminReportsScreen(),
        ),
      );
      await tester.pump();

      // Header
      expect(find.text('Platform Analytics & Reports'), findsOneWidget);

      // Tabs
      expect(find.text('Revenue & Payments'), findsOneWidget);
      expect(find.text('Ride Analytics'), findsOneWidget);
      expect(find.text('User Reports'), findsOneWidget);
      expect(find.text('Captain & Fleet'), findsOneWidget);

      // Revenue tab initially visible
      expect(find.text('Total Gross Collected'), findsOneWidget);
      expect(find.text('Revenue Distribution & Payout Split'), findsOneWidget);

      // Switch to Ride Analytics tab
      await tester.tap(find.text('Ride Analytics'));
      await tester.pumpAndSettle();
      expect(find.text('Rides by Vehicle Type: Bike, Auto, Car'), findsOneWidget);

      // Switch to User Reports tab
      await tester.tap(find.text('User Reports'));
      await tester.pumpAndSettle();
      expect(find.text('User Registration Statistics Over Time'), findsOneWidget);

      // Switch to Captain & Fleet tab
      await tester.tap(find.text('Captain & Fleet'));
      await tester.pumpAndSettle();
      expect(find.text('Captain Fleet Distribution by Vehicle Category'), findsOneWidget);
      expect(find.text('Top Performing Captains Leaderboard'), findsOneWidget);
    });
  });
}
