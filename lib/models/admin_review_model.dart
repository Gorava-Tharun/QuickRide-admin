class AdminReviewModel {
  final String id;
  final String userName;
  final String captainName;
  final double rating;
  final String comment;
  final DateTime date;
  final String rideId;

  const AdminReviewModel({
    required this.id,
    required this.userName,
    required this.captainName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.rideId,
  });
}
