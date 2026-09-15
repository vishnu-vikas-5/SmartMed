import 'package:flutter/material.dart';
import '../../../data/models/medicine_model.dart';
import '../../../data/models/medicine_log_model.dart';
import '../theme/app_colors.dart';
import 'status_badge.dart';

class MedicineCard extends StatelessWidget {
  final MedicineModel medicine;
  final MedicineLogModel? log;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleEnable;

  const MedicineCard({
    super.key,
    required this.medicine,
    this.log,
    this.onTap,
    this.onDelete,
    this.onToggleEnable,
  });

  @override
  Widget build(BuildContext context) {
    final status = log?.status ?? MedicineStatus.pending;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Compartment pill badge
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('💊', style: TextStyle(fontSize: 18)),
                    Text(
                      'Box ${medicine.compartment}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Medicine info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            medicine.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        StatusBadge(status: status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${medicine.dosage} • ${medicine.quantity} tablet',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          medicine.time,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        if (medicine.instructions.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${medicine.instructions}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
