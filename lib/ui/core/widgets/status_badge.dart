import 'package:flutter/material.dart';
import '../../../data/models/medicine_log_model.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final MedicineStatus? status;
  final bool? isOnline;
  final String? customLabel;

  const StatusBadge({
    super.key,
    this.status,
    this.isOnline,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (isOnline != null) {
      final online = isOnline!;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: online ? AppColors.takenBg : AppColors.missedBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: online ? AppColors.taken : AppColors.missed,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: online ? AppColors.online : AppColors.offline,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              online ? '🟢 Online' : '🔴 Offline',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: online ? AppColors.taken : AppColors.missed,
              ),
            ),
          ],
        ),
      );
    }

    Color bgColor = AppColors.pendingBg;
    Color textColor = AppColors.pending;
    String label = customLabel ?? 'Pending';
    IconData icon = Icons.access_time_filled;

    if (status != null) {
      switch (status!) {
        case MedicineStatus.taken:
          bgColor = AppColors.takenBg;
          textColor = AppColors.taken;
          label = '✓ Taken';
          icon = Icons.check_circle;
          break;
        case MedicineStatus.reminder_active:
          bgColor = AppColors.activeBg;
          textColor = AppColors.active;
          label = '🔔 Active';
          icon = Icons.notifications_active;
          break;
        case MedicineStatus.missed:
          bgColor = AppColors.missedBg;
          textColor = AppColors.missed;
          label = '⚠ Missed';
          icon = Icons.warning_rounded;
          break;
        case MedicineStatus.pending:
          bgColor = AppColors.pendingBg;
          textColor = AppColors.pending;
          label = '⏳ Pending';
          icon = Icons.hourglass_top;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
