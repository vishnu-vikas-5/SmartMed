import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../../medicine/views/add_medicine_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/compartment_grid_widget.dart';
import '../../../core/widgets/hardware_simulator_dialog.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final homeVm = Provider.of<HomeViewModel>(context);
    final user = authVm.currentUser;

    final device = homeVm.pairedDevice;
    final isDeviceOnline = device?.isOnline ?? false;
    final nextMed = homeVm.nextMedicine;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                        'SMARTMED',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Good Morning, ${user?.name.split(' ').first ?? 'User'}!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.developer_board_rounded,
                          color: AppColors.primary, size: 22),
                    ),
                    tooltip: 'ESP32 Simulator',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => HardwareSimulatorDialog(
                          userId: user?.uid ?? '',
                          deviceId: device?.deviceId ?? 'SM-ESP32-001',
                          medicines: homeVm.medicines,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Device Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDeviceOnline
                        ? [AppColors.primary, AppColors.primaryDark]
                        : [const Color(0xFF475569), const Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isDeviceOnline ? AppColors.primary : Colors.black)
                          .withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.router_rounded,
                                color: Colors.white, size: 24),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  device?.deviceName ?? 'SmartMed Box',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  device?.deviceId ?? 'SM-ESP32-001',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        StatusBadge(isOnline: isDeviceOnline),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Colors.white24, height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDeviceStat(
                          'Wi-Fi',
                          device?.wifiStatus ?? 'Connected',
                          Icons.wifi,
                        ),
                        _buildDeviceStat(
                          'Activity',
                          device?.currentActivity ?? 'Waiting',
                          Icons.sensors,
                        ),
                        _buildDeviceStat(
                          'Compartments',
                          '${device?.compartmentCount ?? 4}',
                          Icons.grid_view_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Today's Summary Section Header
              const Text(
                "Today's Medicines Summary",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Summary Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      label: 'Taken',
                      count: homeVm.takenCount,
                      icon: Icons.check_circle_rounded,
                      color: AppColors.taken,
                      bgColor: AppColors.takenBg,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSummaryCard(
                      label: 'Pending',
                      count: homeVm.pendingCount,
                      icon: Icons.hourglass_top_rounded,
                      color: AppColors.pending,
                      bgColor: AppColors.pendingBg,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSummaryCard(
                      label: 'Missed',
                      count: homeVm.missedCount,
                      icon: Icons.warning_rounded,
                      color: AppColors.missed,
                      bgColor: AppColors.missedBg,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Next Scheduled Medicine
              if (nextMed != null) ...[
                const Text(
                  'Next Scheduled Medicine',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.medication_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nextMed.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${nextMed.dosage} • Compartment ${nextMed.compartment}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          nextMed.time,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Compartment Visual Grid Representation
              CompartmentGridWidget(
                medicines: homeVm.medicines,
                onCompartmentTap: (compartmentNum, assignedMedicine) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddMedicineView(
                        presetCompartment: compartmentNum,
                        existingMedicine: assignedMedicine,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddMedicineView()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Medicine',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDeviceStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
