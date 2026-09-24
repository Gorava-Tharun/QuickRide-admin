import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/models/admin_complaint_model.dart';
import 'package:quickride_admin/models/firestore_models.dart';
import 'package:quickride_admin/screens/complaints/admin_complaints_screen.dart';
import 'package:quickride_admin/services/admin_state_service.dart';

void main() {
  late AdminStateService service;

  setUp(() {
    service = AdminStateService();
  });

  group('Admin Complaints Management Unit Tests', () {
    test('Mock complaints are populated with both User and Captain tickets', () {
      expect(service.complaints.isNotEmpty, isTrue);
      expect(service.totalComplaintsCount, greaterThanOrEqualTo(6));
      expect(service.userComplaintsCount, greaterThan(0));
      expect(service.captainComplaintsCount, greaterThan(0));
      expect(service.openComplaintsCount, greaterThan(0));
      expect(service.urgentComplaintsCount, greaterThan(0));
    });

    test('Filter complaints by Role (USER vs CAPTAIN)', () {
      final userTickets = service.filterComplaints(role: 'USER');
      expect(userTickets.every((c) => c.isUser), isTrue);
      expect(userTickets.length, service.userComplaintsCount);

      final captainTickets = service.filterComplaints(role: 'CAPTAIN');
      expect(captainTickets.every((c) => c.isCaptain), isTrue);
      expect(captainTickets.length, service.captainComplaintsCount);

      final allTickets = service.filterComplaints(role: 'ALL');
      expect(allTickets.length, service.totalComplaintsCount);
    });

    test('Filter complaints by Status (Open, InReview, Resolved, Closed)', () {
      final openTickets = service.filterComplaints(status: ComplaintStatus.open);
      expect(openTickets.every((c) => c.status == ComplaintStatus.open), isTrue);

      final inReviewTickets = service.filterComplaints(status: ComplaintStatus.inReview);
      expect(inReviewTickets.every((c) => c.status == ComplaintStatus.inReview), isTrue);

      final resolvedTickets = service.filterComplaints(status: ComplaintStatus.resolved);
      expect(resolvedTickets.every((c) => c.status == ComplaintStatus.resolved), isTrue);
    });

    test('Filter complaints by Priority (URGENT, HIGH, NORMAL)', () {
      final urgentTickets = service.filterComplaints(priority: 'URGENT');
      expect(urgentTickets.every((c) => c.isUrgent), isTrue);

      final normalTickets = service.filterComplaints(priority: 'NORMAL');
      expect(normalTickets.every((c) => c.priority.toUpperCase() == 'NORMAL'), isTrue);
    });

    test('Search complaints by ID, Complainant Name, Ride ID, Payment ID, Subject', () {
      // Search by ticket ID
      final byId = service.filterComplaints(searchQuery: 'CMP-101');
      expect(byId.isNotEmpty, isTrue);
      expect(byId.first.id, 'CMP-101');

      // Search by passenger / captain name
      final byName = service.filterComplaints(searchQuery: 'Aarav');
      expect(byName.isNotEmpty, isTrue);
      expect(byName.any((c) => c.userName.contains('Aarav')), isTrue);

      // Search by Ride ID
      final byRide = service.filterComplaints(searchQuery: 'RD-901');
      expect(byRide.isNotEmpty, isTrue);
      expect(byRide.any((c) => c.rideId == 'RD-901'), isTrue);

      // Search by Payment ID
      final byPayment = service.filterComplaints(searchQuery: 'PAY_RD_901');
      expect(byPayment.isNotEmpty, isTrue);

      // Search by Subject
      final bySubject = service.filterComplaints(searchQuery: 'Route Deviation');
      expect(bySubject.isNotEmpty, isTrue);
    });

    test('Complaint Status and Resolution Update Workflow', () async {
      final ticket = service.complaints.firstWhere((c) => c.status == ComplaintStatus.open);

      // Step 1: Mark In Review
      await service.updateComplaintStatus(ticket.id, ComplaintStatus.inReview);
      var current = service.complaints.firstWhere((c) => c.id == ticket.id);
      expect(current.status, ComplaintStatus.inReview);

      // Step 2: Escalate priority
      await service.updateComplaintPriority(ticket.id, 'URGENT');
      current = service.complaints.firstWhere((c) => c.id == ticket.id);
      expect(current.priority, 'URGENT');
      expect(current.isUrgent, isTrue);

      // Step 3: Resolve ticket with resolution summary and internal notes
      const testSummary = 'Full refund of ₹150 processed to passenger wallet. Captain re-trained.';
      const testNotes = 'Verified GPS traces on live monitor. Driver took detour.';
      await service.updateComplaintStatus(
        ticket.id,
        ComplaintStatus.resolved,
        resolutionSummary: testSummary,
        adminNotes: testNotes,
      );
      current = service.complaints.firstWhere((c) => c.id == ticket.id);
      expect(current.status, ComplaintStatus.resolved);
      expect(current.resolutionSummary, testSummary);
      expect(current.adminNotes, testNotes);
      expect(current.resolvedAt, isNotNull);
    });

    test('Support conversation reply model helpers', () {
      final adminReply = FirestoreComplaintReplyModel(
        replyId: 'rep_1',
        complaintId: 'CMP-101',
        senderId: 'admin_1',
        senderName: 'Admin Support',
        senderRole: 'ADMIN',
        message: 'We are investigating your request.',
        createdAt: DateTime.now(),
      );
      expect(adminReply.isAdmin, isTrue);
      expect(adminReply.isUser, isFalse);
      expect(adminReply.isCaptain, isFalse);

      final userReply = FirestoreComplaintReplyModel(
        replyId: 'rep_2',
        complaintId: 'CMP-101',
        senderId: 'user_1',
        senderName: 'Aarav Sharma',
        senderRole: 'USER',
        message: 'Thank you for the quick update.',
        createdAt: DateTime.now(),
      );
      expect(userReply.isAdmin, isFalse);
      expect(userReply.isUser, isTrue);
      expect(userReply.isCaptain, isFalse);

      final captainReply = FirestoreComplaintReplyModel(
        replyId: 'rep_3',
        complaintId: 'CMP-102',
        senderId: 'cap_1',
        senderName: 'Rajesh Kumar',
        senderRole: 'CAPTAIN',
        message: 'Passenger was not at pickup point.',
        createdAt: DateTime.now(),
      );
      expect(captainReply.isAdmin, isFalse);
      expect(captainReply.isUser, isFalse);
      expect(captainReply.isCaptain, isTrue);
    });
  });

  group('Admin Complaints Screen Widget Tests', () {
    testWidgets('Renders complaints screen with search bar, filter chips, and ticket cards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminComplaintsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Header & Title
      expect(find.text('Complaints & Support'), findsOneWidget);
      expect(find.text('Search by ID, Complainant Name, Ride ID, Payment ID, Subject...'), findsOneWidget);

      // Filter chips & metric counters
      expect(find.text('Riders'), findsOneWidget);
      expect(find.text('Captains'), findsOneWidget);
      expect(find.text('Open'), findsWidgets);
      expect(find.text('In Review'), findsWidgets);
      expect(find.text('Resolved'), findsWidgets);
      expect(find.text('Urgent'), findsWidgets);

      // Verify at least one complaint card is rendered
      expect(find.text('CMP-101'), findsOneWidget);

      // Tap on Captains filter chip
      await tester.tap(find.text('Captains'));
      await tester.pumpAndSettle();

      // Only Captain tickets should be visible
      expect(find.text('CAPTAIN'), findsWidgets);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
