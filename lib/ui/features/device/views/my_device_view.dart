import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/device_view_model.dart';
import '../../auth/view_models/auth_view_model.dart';
import 'pair_device_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/custom_button.dart';

class MyDeviceView extends StatelessWidget {
  const MyDeviceView({super.key});

  String _formatLastSeen(DateTime lastSeen) {
    final diff = DateTime.now().difference(lastSeen);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds} seconds ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else {
      return '${diff.inHours} hours ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final deviceVm = Provider.of<DeviceViewModel>(context);

    final device = deviceVm.pairedDevice;
    final isOnline = device?.isOnline ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My SmartMed Device'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (device == null) ...[
                // Unpaired state
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.router_outlined,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No SmartMed Box Paired',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pair your ESP32 Smart Medicine Box to enable automatic schedule syncing and physical IR detection.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: 'Pair Device',
                        icon: Icons.qr_code_scanner,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const PairDeviceView()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Paired Device Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
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
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isOnline
                                      ? AppColors.takenBg
                                      : AppColors.missedBg,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.developer_board_rounded,
                                  color: isOnline
                                      ? AppColors.taken
                                      : AppColors.missed,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.deviceName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'ID: ${device.deviceId}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          StatusBadge(isOnline: isOnline),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: AppColors.divider),
                      ),
                      _buildDetailRow(
                          'Connection Status', isOnline ? '🟢 Online' : '🔴 Offline'),
                      _buildDetailRow(
                          'Last Seen', _formatLastSeen(device.lastSeen)),
                      _buildDetailRow('Wi-Fi Status', device.wifiStatus),
                      _buildDetailRow(
                          'Compartments', '${device.compartmentCount} Boxes'),
                      _buildDetailRow(
                          'Firmware Version', device.firmwareVersion),
                      _buildDetailRow(
                          'Current Activity', device.currentActivity),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                CustomButton(
                  text: 'Pair Different Device',
                  isOutlined: true,
                  icon: Icons.sync,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const PairDeviceView()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Unpair Device',
                  backgroundColor: AppColors.missed,
                  onPressed: () async {
                    final userId = authVm.currentUser?.uid ?? '';
                    await deviceVm.unpairDevice(userId, device.deviceId);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
