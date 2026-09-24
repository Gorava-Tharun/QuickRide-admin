import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_dimensions.dart';
import '../../models/firestore_models.dart';
import '../../services/admin_state_service.dart';

class AdminOffersScreen extends StatefulWidget {
  const AdminOffersScreen({super.key});

  @override
  State<AdminOffersScreen> createState() => _AdminOffersScreenState();
}

class _AdminOffersScreenState extends State<AdminOffersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openOfferDialog([FirestoreOfferModel? existing]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _OfferFormDialog(offer: existing),
    );
  }

  void _confirmDelete(FirestoreOfferModel offer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Offer'),
        content: Text('Are you sure you want to delete "${offer.title}" (${offer.couponCode})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.danger),
            onPressed: () {
              Navigator.of(ctx).pop();
              AdminStateService().deleteOffer(offer.offerId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Offer ${offer.couponCode} deleted.')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminStateService(),
      builder: (context, _) {
        final service = AdminStateService();
        final filteredOffers = service.filterOffers(
          query: _searchController.text,
          status: _selectedStatus,
        );

        return Scaffold(
          backgroundColor: AdminColors.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AdminDimensions.p20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Action Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Offers & Promotions',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AdminColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Create and manage promotional discounts, coupon codes, and limits',
                            style: TextStyle(
                              fontSize: 13,
                              color: AdminColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openOfferDialog(),
                      icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                      label: const Text('Create Offer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AdminDimensions.p20),

                // Search & Status Filter Bar
                Container(
                  padding: const EdgeInsets.all(AdminDimensions.p12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
                    border: Border.all(color: AdminColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search by title, coupon code, or description...',
                            hintStyle: const TextStyle(fontSize: 13, color: AdminColors.textMuted),
                            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AdminColors.textMuted),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                              borderSide: const BorderSide(color: AdminColors.border),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AdminColors.border),
                          borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All Statuses', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'Active', child: Text('Active Only', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'Inactive', child: Text('Inactive Only', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'Expired', child: Text('Expired Only', style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedStatus = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AdminDimensions.p16),

                // Offers List or Empty View
                if (filteredOffers.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
                      border: Border.all(color: AdminColors.border),
                    ),
                    child: Center(
                      child: Column(
                        children: const [
                          Icon(Icons.local_offer_outlined, size: 48, color: AdminColors.textMuted),
                          SizedBox(height: 12),
                          Text('No offers found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Create a new promotion or adjust your search filter.', style: TextStyle(color: AdminColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredOffers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AdminDimensions.p12),
                    itemBuilder: (context, index) {
                      final offer = filteredOffers[index];
                      return _buildOfferCard(offer);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOfferCard(FirestoreOfferModel offer) {
    final now = DateTime.now();
    final isExpired = now.isAfter(offer.validUntil);
    final isUpcoming = now.isBefore(offer.validFrom);

    Color badgeBg;
    Color badgeText;
    String statusLabel;

    if (isExpired) {
      badgeBg = AdminColors.danger.withOpacity(0.12);
      badgeText = AdminColors.danger;
      statusLabel = 'EXPIRED';
    } else if (!offer.active) {
      badgeBg = Colors.grey.withOpacity(0.15);
      badgeText = Colors.grey[700]!;
      statusLabel = 'INACTIVE';
    } else if (isUpcoming) {
      badgeBg = Colors.blue.withOpacity(0.12);
      badgeText = Colors.blue[700]!;
      statusLabel = 'UPCOMING';
    } else {
      badgeBg = AdminColors.success.withOpacity(0.15);
      badgeText = AdminColors.success;
      statusLabel = 'ACTIVE';
    }

    final discountDisplay = offer.discountType == 'percentage'
        ? '${offer.discountValue.toStringAsFixed(0)}% OFF'
        : '₹${offer.discountValue.toStringAsFixed(0)} OFF';

    final maxDiscountDisplay = offer.maxDiscount != null
        ? ' (Max ₹${offer.maxDiscount!.toStringAsFixed(0)})'
        : '';

    return Container(
      padding: const EdgeInsets.all(AdminDimensions.p16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
        border: Border.all(
          color: offer.active && !isExpired
              ? AdminColors.border
              : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left coupon icon badge
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminColors.primaryLight,
              borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
              border: Border.all(color: AdminColors.primary.withOpacity(0.2)),
            ),
            child: const Icon(Icons.confirmation_number_outlined, color: AdminColors.primary, size: 24),
          ),
          const SizedBox(width: AdminDimensions.p16),

          // Main info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      offer.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: badgeText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  offer.description,
                  style: const TextStyle(fontSize: 13, color: AdminColors.textSecondary),
                ),
                const SizedBox(height: 10),

                // Metrics / Key Details
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _buildMetaChip(Icons.code_rounded, 'Code: ${offer.couponCode}'),
                    _buildMetaChip(Icons.percent_rounded, '$discountDisplay$maxDiscountDisplay'),
                    _buildMetaChip(Icons.currency_rupee_rounded, 'Min Fare: ₹${offer.minimumFare.toStringAsFixed(0)}'),
                    _buildMetaChip(Icons.event_available_rounded, 'Valid: ${offer.validUntil.day}/${offer.validUntil.month}/${offer.validUntil.year}'),
                    _buildMetaChip(Icons.people_outline_rounded, 'Uses: ${offer.usedCount}${offer.usageLimit != null ? "/${offer.usageLimit}" : ""}'),
                    if (offer.perUserLimit != null)
                      _buildMetaChip(Icons.person_pin_circle_outlined, 'Max/User: ${offer.perUserLimit}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AdminDimensions.p16),

          // Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Active toggle switch
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    offer.active ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: offer.active ? AdminColors.success : AdminColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: offer.active,
                      activeColor: AdminColors.success,
                      onChanged: (_) => AdminStateService().toggleOfferActive(offer.offerId),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AdminColors.primary),
                    tooltip: 'Edit Offer',
                    onPressed: () => _openOfferDialog(offer),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AdminColors.danger),
                    tooltip: 'Delete Offer',
                    onPressed: () => _confirmDelete(offer),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AdminColors.background,
        borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AdminColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
        ],
      ),
    );
  }
}

class _OfferFormDialog extends StatefulWidget {
  final FirestoreOfferModel? offer;
  const _OfferFormDialog({this.offer});

  @override
  State<_OfferFormDialog> createState() => _OfferFormDialogState();
}

class _OfferFormDialogState extends State<_OfferFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _codeController;
  late TextEditingController _valueController;
  late TextEditingController _maxDiscountController;
  late TextEditingController _minFareController;
  late TextEditingController _usageLimitController;
  late TextEditingController _perUserLimitController;

  String _discountType = 'percentage';
  late DateTime _validFrom;
  late DateTime _validUntil;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final o = widget.offer;
    _titleController = TextEditingController(text: o?.title ?? '');
    _descController = TextEditingController(text: o?.description ?? '');
    _codeController = TextEditingController(text: o?.couponCode ?? '');
    _valueController = TextEditingController(text: o?.discountValue != null ? '${o!.discountValue}' : '20');
    _maxDiscountController = TextEditingController(text: o?.maxDiscount != null ? '${o!.maxDiscount}' : '');
    _minFareController = TextEditingController(text: o?.minimumFare != null ? '${o!.minimumFare}' : '50');
    _usageLimitController = TextEditingController(text: o?.usageLimit != null ? '${o!.usageLimit}' : '');
    _perUserLimitController = TextEditingController(text: o?.perUserLimit != null ? '${o!.perUserLimit}' : '1');

    _discountType = o?.discountType ?? 'percentage';
    _validFrom = o?.validFrom ?? DateTime.now();
    _validUntil = o?.validUntil ?? DateTime.now().add(const Duration(days: 60));
    _active = o?.active ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _codeController.dispose();
    _valueController.dispose();
    _maxDiscountController.dispose();
    _minFareController.dispose();
    _usageLimitController.dispose();
    _perUserLimitController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    if (_validUntil.isBefore(_validFrom)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expiry date must be after start date.')),
      );
      return;
    }

    final double discountVal = double.tryParse(_valueController.text.trim()) ?? 0.0;
    final double? maxDisc = _maxDiscountController.text.trim().isNotEmpty
        ? double.tryParse(_maxDiscountController.text.trim())
        : null;
    final double minFare = double.tryParse(_minFareController.text.trim()) ?? 0.0;
    final int? usageLim = _usageLimitController.text.trim().isNotEmpty
        ? int.tryParse(_usageLimitController.text.trim())
        : null;
    final int? perUserLim = _perUserLimitController.text.trim().isNotEmpty
        ? int.tryParse(_perUserLimitController.text.trim())
        : null;

    final isNew = widget.offer == null;
    final offerId = widget.offer?.offerId ?? 'OFFER-${DateTime.now().millisecondsSinceEpoch}';

    final offer = FirestoreOfferModel(
      offerId: offerId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      couponCode: _codeController.text.trim().toUpperCase(),
      discountType: _discountType,
      discountValue: discountVal,
      maxDiscount: maxDisc,
      minimumFare: minFare,
      validFrom: _validFrom,
      validUntil: _validUntil,
      usageLimit: usageLim,
      perUserLimit: perUserLim,
      usedCount: widget.offer?.usedCount ?? 0,
      userUsage: widget.offer?.userUsage ?? {},
      active: _active,
      createdAt: widget.offer?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (isNew) {
      AdminStateService().addOffer(offer);
    } else {
      AdminStateService().updateOffer(offer);
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isNew ? 'Offer created successfully!' : 'Offer updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.offer == null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium)),
      child: Container(
        width: 580,
        padding: const EdgeInsets.all(AdminDimensions.p20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isNew ? 'Create New Offer' : 'Edit Offer',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Offer Title *', hintText: 'e.g. 20% OFF WEEKEND SPECIAL'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 12),

                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description *', hintText: 'Explain offer details and terms...'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
                ),
                const SizedBox(height: 12),

                // Coupon Code & Type
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(labelText: 'Coupon Code *', hintText: 'e.g. QUICK20'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Coupon code is required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _discountType,
                        decoration: const InputDecoration(labelText: 'Discount Type'),
                        items: const [
                          DropdownMenuItem(value: 'percentage', child: Text('Percentage (%)')),
                          DropdownMenuItem(value: 'fixed', child: Text('Fixed Amount (₹)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _discountType = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Value, Max Discount, Min Fare
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _valueController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: _discountType == 'percentage' ? 'Discount % *' : 'Amount (₹) *',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final numVal = double.tryParse(v.trim());
                          if (numVal == null || numVal <= 0) return 'Must be > 0';
                          if (_discountType == 'percentage' && numVal > 100) return 'Max 100%';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _maxDiscountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Max Cap (₹)',
                          hintText: 'Optional',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _minFareController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Min Fare (₹)'),
                        validator: (v) {
                          if (v != null && v.trim().isNotEmpty) {
                            final val = double.tryParse(v.trim());
                            if (val == null || val < 0) return 'Must be >= 0';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Limits: Usage Limit & Per-User Limit
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _usageLimitController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Total Usage Limit',
                          hintText: 'e.g. 500 (blank = unlimited)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _perUserLimitController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Per-User Limit',
                          hintText: 'e.g. 1',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Validity Dates
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Valid From', style: TextStyle(fontSize: 12, color: AdminColors.textSecondary)),
                        subtitle: Text('${_validFrom.day}/${_validFrom.month}/${_validFrom.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.calendar_today_rounded, size: 18),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _validFrom,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) setState(() => _validFrom = picked);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Valid Until', style: TextStyle(fontSize: 12, color: AdminColors.textSecondary)),
                        subtitle: Text('${_validUntil.day}/${_validUntil.month}/${_validUntil.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.event_busy_rounded, size: 18),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _validUntil,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) setState(() => _validUntil = picked);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Active Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _active,
                      activeColor: AdminColors.primary,
                      onChanged: (v) => setState(() => _active = v ?? true),
                    ),
                    const Text('Active (Visible to eligible users)', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: _handleSave,
                      child: Text(isNew ? 'Create Offer' : 'Save Changes', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
