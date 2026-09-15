import 'package:flutter/material.dart';
import '../../../data/models/medicine_model.dart';
import '../../../data/services/mock_esp32_hardware_service.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

class HardwareSimulatorDialog extends StatefulWidget {
  final String userId;
  final String deviceId;
  final List<MedicineModel> medicines;

  const HardwareSimulatorDialog({
    super.key,
    required this.userId,
    required this.deviceId,
    required this.medicines,
  });

  @override
  State<HardwareSimulatorDialog> createState() => _HardwareSimulatorDialogState();
}

class _HardwareSimulatorDialogState extends State<HardwareSimulatorDialog> {
  final MockEsp32HardwareService _simulator = MockEsp32HardwareService();
  MedicineModel? _selectedMedicine;
  String _hardwareLog = 'Select a medicine and action to simulate physical ESP32 events.';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.medicines.isNotEmpty) {
      _selectedMedicine = widget.medicines.first;
    }
  }

  void _updateLog(String msg) {
    setState(() {
      _hardwareLog = msg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.developer_board, color: AppColors.primary),
          SizedBox(width: 8),
          Text(
            'ESP32 Hardware Simulator',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Simulate physical IR sensors, buzzer, LCD display, and 5-minute timeout logic without physical ESP32 attached.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            if (widget.medicines.isEmpty)
              const Text(
                '⚠ Please add a medicine first to test hardware events.',
                style: TextStyle(color: AppColors.missed, fontWeight: FontWeight.bold),
              )
            else ...[
              const Text(
                'Select Target Medicine:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<MedicineModel>(
                value: _selectedMedicine,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: widget.medicines
                    .map((med) => DropdownMenuItem(
                          value: med,
                          child: Text('${med.name} (Compartment ${med.compartment})'),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedMedicine = val;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Simulator Actions
              CustomButton(
                text: '1. Trigger Scheduled Reminder (Buzzer/LED)',
                icon: Icons.notifications_active,
                backgroundColor: AppColors.active,
                isLoading: _isLoading,
                onPressed: () async {
                  if (_selectedMedicine == null) return;
                  setState(() => _isLoading = true);
                  await _simulator.simulateReminderStarted(
                    userId: widget.userId,
                    deviceId: widget.deviceId,
                    medicine: _selectedMedicine!,
                    onLogUpdate: _updateLog,
                  );
                  setState(() => _isLoading = false);
                },
              ),
              const SizedBox(height: 8),
              CustomButton(
                text: '2. IR Sensor: Tablet Removed (Taken)',
                icon: Icons.check_circle_outline,
                backgroundColor: AppColors.taken,
                isLoading: _isLoading,
                onPressed: () async {
                  if (_selectedMedicine == null) return;
                  setState(() => _isLoading = true);
                  await _simulator.simulateIRSensorTabletRemoved(
                    userId: widget.userId,
                    deviceId: widget.deviceId,
                    medicine: _selectedMedicine!,
                    onLogUpdate: _updateLog,
                  );
                  setState(() => _isLoading = false);
                },
              ),
              const SizedBox(height: 8),
              CustomButton(
                text: '3. 5-Min Timeout Expired (Missed)',
                icon: Icons.warning_amber_rounded,
                backgroundColor: AppColors.missed,
                isLoading: _isLoading,
                onPressed: () async {
                  if (_selectedMedicine == null) return;
                  setState(() => _isLoading = true);
                  await _simulator.simulateFiveMinuteTimeoutMissed(
                    userId: widget.userId,
                    deviceId: widget.deviceId,
                    medicine: _selectedMedicine!,
                    onLogUpdate: _updateLog,
                  );
                  setState(() => _isLoading = false);
                },
              ),
            ],
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ESP32 Terminal Log:',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _hardwareLog,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
