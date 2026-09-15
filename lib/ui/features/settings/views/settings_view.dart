import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../../home/view_models/home_view_model.dart';
import '../../auth/views/login_view.dart';
import '../../auth/views/forgot_password_view.dart';
import '../../device/views/my_device_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/hardware_simulator_dialog.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final homeVm = Provider.of<HomeViewModel>(context);
    final user = authVm.currentUser;
    final device = homeVm.pairedDevice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // User Profile Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User Name',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? 'user@email.com',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Hardware & Testing',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),

            _buildTile(
              title: 'ESP32 Hardware Simulator',
              subtitle: 'Test IR removal, buzzer & 5-min timeout',
              icon: Icons.developer_board,
              onTap: () {
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

            _buildTile(
              title: 'My SmartMed Device',
              subtitle: device != null ? device.deviceName : 'No device paired',
              icon: Icons.router,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyDeviceView()),
                );
              },
            ),

            const SizedBox(height: 20),
            const Text(
              'Preferences & Security',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Push Notifications',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: const Text(
                  'Receive FCM alerts for missed medicines and offline device',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                secondary: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                value: _notificationsEnabled,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    _notificationsEnabled = val;
                  });
                },
              ),
            ),

            _buildTile(
              title: 'Change Password',
              subtitle: 'Send password reset link to your email',
              icon: Icons.lock_reset,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ForgotPasswordView()),
                );
              },
            ),

            const SizedBox(height: 20),
            const Text(
              'App Details',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),

            _buildTile(
              title: 'About SmartMed',
              subtitle: 'v1.0.0 • IoT Smart Medicine Reminder System',
              icon: Icons.info_outline,
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'SmartMed',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.medical_services, color: AppColors.primary, size: 40),
                  children: const [
                    Text('SmartMed is an IoT-based Smart Medicine Reminder and Monitoring System using Flutter, Firebase, and ESP32 with physical IR sensor verification.'),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.missedBg),
              ),
              tileColor: AppColors.missedBg,
              leading: const Icon(Icons.logout, color: AppColors.missed),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.missed,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                await authVm.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginView()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
