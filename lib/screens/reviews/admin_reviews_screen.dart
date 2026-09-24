import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_dimensions.dart';
import '../../models/admin_review_model.dart';
import '../../services/admin_state_service.dart';

class AdminReviewsScreen extends StatelessWidget {
  const AdminReviewsScreen({super.key});

  void _showReviewDialog(BuildContext context, AdminReviewModel review) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.rate_review_outlined, color: AdminColors.primary),
            const SizedBox(width: 8),
            Text(review.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AdminColors.warning,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdminColors.background,
                borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
              ),
              child: Text(
                '"${review.comment}"',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AdminColors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 24),
            _buildRow('Rider', review.userName),
            _buildRow('Captain', review.captainName),
            _buildRow('Trip Reference', review.rideId),
            _buildRow(
              'Date',
              '${review.date.day}/${review.date.month}/${review.date.year}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviews = AdminStateService().reviews;
    final averageRating = reviews.fold(0.0, (sum, r) => sum + r.rating) / (reviews.isNotEmpty ? reviews.length : 1);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AdminDimensions.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ratings & Rider Feedback',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Passenger experience reviews and service satisfaction metrics',
                      style: TextStyle(fontSize: 13, color: AdminColors.textSecondary),
                    ),
                  ],
                ),
                // Rating Score Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AdminColors.warningLight,
                    borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                    border: Border.all(color: AdminColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: AdminColors.warning, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${reviews.length})',
                        style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AdminDimensions.p16),

            // Reviews List
            Expanded(
              child: ListView.separated(
                itemCount: reviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: AdminDimensions.p8),
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: AdminColors.warning.withOpacity(0.12),
                        child: Text(
                          '${review.rating.toInt()}★',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AdminColors.warning),
                        ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            review.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            'Captain: ${review.captainName}',
                            style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '"${review.comment}"',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AdminColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Trip: ${review.rideId} • ${review.date.day}/${review.date.month}/${review.date.year}',
                              style: const TextStyle(fontSize: 11, color: AdminColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AdminColors.textMuted),
                      onTap: () => _showReviewDialog(context, review),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
