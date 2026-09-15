import 'dart:async';
import 'esp32_service.dart';
import 'firestore_service.dart';
import '../models/medicine_log_model.dart';
import '../models/medicine_model.dart';

class MockEsp32HardwareService {
  final Esp32Service _esp32service = Esp32Service();
  final FirestoreService _firestoreService = FirestoreService();

  Timer? _fiveMinTimer;

  /// Simulate ESP32 triggering a medicine reminder at scheduled time
  Future<void> simulateReminderStarted({
    required String userId,
    required String deviceId,
    required MedicineModel medicine,
    Function(String statusMessage)? onLogUpdate,
  }) async {
    onLogUpdate?.call('ESP32: Buzzer ON, Compartment ${medicine.compartment} LED Blinking, LCD: Take ${medicine.name}');
    
    // Send event to Firebase
    await _esp32service.sendReminderStartedEvent(
      deviceId: deviceId,
      medicineId: medicine.medicineId,
      compartment: medicine.compartment,
    );

    // Update log status to reminder_active
    await _firestoreService.updateLogStatus(
      userId: userId,
      medicineId: medicine.medicineId,
      status: MedicineStatus.reminder_active,
    );

    // Start 5-minute timer simulation (or 10 seconds in simulator mode for quick testing)
    _fiveMinTimer?.cancel();
  }

  /// Simulate IR Sensor detecting physical tablet removal
  Future<void> simulateIRSensorTabletRemoved({
    required String userId,
    required String deviceId,
    required MedicineModel medicine,
    Function(String statusMessage)? onLogUpdate,
  }) async {
    _fiveMinTimer?.cancel();

    onLogUpdate?.call('ESP32: IR Sensor detected tablet removed! Buzzer OFF, LED OFF.');

    await _esp32service.sendMedicineTakenEvent(
      deviceId: deviceId,
      medicineId: medicine.medicineId,
      compartment: medicine.compartment,
    );

    await _firestoreService.updateLogStatus(
      userId: userId,
      medicineId: medicine.medicineId,
      status: MedicineStatus.taken,
      takenTime: DateTime.now(),
    );
  }

  /// Simulate 5-minute timeout passing without tablet removal
  Future<void> simulateFiveMinuteTimeoutMissed({
    required String userId,
    required String deviceId,
    required MedicineModel medicine,
    Function(String statusMessage)? onLogUpdate,
  }) async {
    _fiveMinTimer?.cancel();

    onLogUpdate?.call('ESP32: 5 minutes expired! Tablet not removed. Status set to MISSED.');

    await _esp32service.sendMedicineMissedEvent(
      deviceId: deviceId,
      medicineId: medicine.medicineId,
      compartment: medicine.compartment,
    );

    await _firestoreService.updateLogStatus(
      userId: userId,
      medicineId: medicine.medicineId,
      status: MedicineStatus.missed,
    );
  }

  /// Simulate Device Offline / Online toggle
  Future<void> toggleDeviceOnlineStatus({
    required String deviceId,
    required bool online,
  }) async {
    if (online) {
      await _esp32service.updateDeviceHeartbeat(deviceId);
    }
  }
}
