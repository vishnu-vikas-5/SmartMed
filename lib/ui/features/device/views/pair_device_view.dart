import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/device_view_model.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class PairDeviceView extends StatefulWidget {
  const PairDeviceView({super.key});

  @override
  State<PairDeviceView> createState() => _PairDeviceViewState();
}

class _PairDeviceViewState extends State<PairDeviceView> {
  final _formKey = GlobalKey<FormState>();
  final _deviceIdController =
      TextEditingController(text: 'SM-ESP32-001'); // Pre-fill default sample ID
  final _deviceNameController =
      TextEditingController(text: 'SmartMed Box');

  @override
  void dispose() {
    _deviceIdController.dispose();
    _deviceNameController.dispose();
    super.dispose();
  }

  void _onPair() async {
    if (!_formKey.currentState!.validate()) return;

    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final deviceVm = Provider.of<DeviceViewModel>(context, listen: false);
    final userId = authVm.currentUser?.uid ?? '';

    if (userId.isEmpty) return;

    final success = await deviceVm.pairDevice(
      userId: userId,
      deviceId: _deviceIdController.text.trim(),
      deviceName: _deviceNameController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device paired successfully!'),
          backgroundColor: AppColors.taken,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceVm = Provider.of<DeviceViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pair SmartMed Box'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(
                    Icons.qr_code_2_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Enter Device Credentials',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the unique Device ID printed on the bottom label of your physical SmartMed Box.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),

                if (deviceVm.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.missedBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.missed),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            deviceVm.errorMessage!,
                            style: const TextStyle(
                                color: AppColors.missed, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                CustomTextField(
                  label: 'Device ID',
                  hint: 'e.g. SM-ESP32-001',
                  controller: _deviceIdController,
                  prefixIcon: const Icon(Icons.developer_board, color: AppColors.primary),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a valid Device ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                CustomTextField(
                  label: 'Device Name',
                  hint: 'e.g. SmartMed Box',
                  controller: _deviceNameController,
                  prefixIcon: const Icon(Icons.label_outline, color: AppColors.primary),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a name for your device';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                CustomButton(
                  text: 'Confirm & Pair Box',
                  isLoading: deviceVm.isLoading,
                  onPressed: _onPair,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
