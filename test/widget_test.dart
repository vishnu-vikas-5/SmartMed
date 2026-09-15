import 'package:flutter_test/flutter_test.dart';
import 'package:smartmed/data/models/medicine_model.dart';
import 'package:smartmed/data/models/device_model.dart';
import 'package:smartmed/data/models/medicine_log_model.dart';

void main() {
  group('SmartMed Unit Tests', () {
    test('MedicineModel toScheduleMap conversion', () {
      final medicine = MedicineModel(
        medicineId: 'MED001',
        name: 'Paracetamol',
        dosage: '500 mg',
        quantity: 1,
        time: '08:00',
        compartment: 2,
        frequency: 'Daily',
        instructions: 'Take after breakfast',
        enabled: true,
        createdAt: DateTime.now(),
      );

      final scheduleMap = medicine.toScheduleMap();
      expect(scheduleMap['medicineId'], equals('MED001'));
      expect(scheduleMap['medicineName'], equals('Paracetamol'));
      expect(scheduleMap['compartment'], equals(2));
      expect(scheduleMap['time'], equals('08:00'));
    });

    test('DeviceModel isOnline evaluation', () {
      final onlineDevice = DeviceModel(
        deviceId: 'SM-ESP32-001',
        userId: 'USER123',
        deviceName: 'SmartMed Box',
        status: 'online',
        lastSeen: DateTime.now(),
      );

      final offlineDevice = DeviceModel(
        deviceId: 'SM-ESP32-001',
        userId: 'USER123',
        deviceName: 'SmartMed Box',
        status: 'online',
        lastSeen: DateTime.now().subtract(const Duration(minutes: 10)),
      );

      expect(onlineDevice.isOnline, isTrue);
      expect(offlineDevice.isOnline, isFalse);
    });

    test('MedicineStatus conversion', () {
      expect(MedicineStatusExtension.fromValue('taken'), equals(MedicineStatus.taken));
      expect(MedicineStatusExtension.fromValue('missed'), equals(MedicineStatus.missed));
      expect(MedicineStatusExtension.fromValue('reminder_active'), equals(MedicineStatus.reminder_active));
      expect(MedicineStatusExtension.fromValue('pending'), equals(MedicineStatus.pending));
    });
  });
}
