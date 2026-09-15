import 'package:flutter/material.dart';
import '../../../data/models/medicine_model.dart';
import '../theme/app_colors.dart';

class CompartmentGridWidget extends StatelessWidget {
  final List<MedicineModel> medicines;
  final Function(int compartmentNumber, MedicineModel? assignedMedicine)? onCompartmentTap;

  const CompartmentGridWidget({
    super.key,
    required this.medicines,
    this.onCompartmentTap,
  });

  @override
  Widget build(BuildContext context) {
    // Map medicines by compartment 1..4
    final Map<int, MedicineModel> compartmentMap = {};
    for (var med in medicines) {
      if (med.compartment >= 1 && med.compartment <= 4) {
        compartmentMap[med.compartment] = med;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'SmartMed Medicine Box',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '4 Compartments',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final compartmentNum = index + 1;
              final med = compartmentMap[compartmentNum];
              final isAssigned = med != null;

              return InkWell(
                onTap: () => onCompartmentTap?.call(compartmentNum, med),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAssigned ? AppColors.secondary.withOpacity(0.4) : AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isAssigned ? AppColors.primaryLight : AppColors.border,
                      width: isAssigned ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Compartment $compartmentNum',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isAssigned ? AppColors.primaryDark : AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            isAssigned ? '💊' : '⚪',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      if (isAssigned) ...[
                        Text(
                          med.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 12, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              '${med.time} (${med.dosage})',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        )
                      ] else ...[
                        const Text(
                          'Unassigned',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const Text(
                          '+ Tap to assign',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
