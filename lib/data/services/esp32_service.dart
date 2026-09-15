import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/device_model.dart';
import '../models/medicine_model.dart';
import '../models/device_event_model.dart';

abstract class IEsp32Service {
  Future<bool> connectDevice(String deviceId);
  Future<DeviceModel?> getDeviceStatus(String deviceId);
  Future<List<MedicineModel>> getMedicineSchedule(String deviceId);
  Future<void> sendMedicineTakenEvent({
    required String deviceId,
    required String medicineId,
    required int compartment,
  });
  Future<void> sendMedicineMissedEvent({
    required String deviceId,
    required String medicineId,
    required int compartment,
  });
  Future<void> sendReminderStartedEvent({
    required String deviceId,
    required String medicineId,
    required int compartment,
  });
  Future<void> updateDeviceHeartbeat(String deviceId);
}

/// Firebase REST/Firestore Implementation of ESP32 Communication Layer
class Esp32Service implements IEsp32Service {
  @override
  Future<bool> connectDevice(String deviceId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('devices').doc(deviceId).get();
      if (!doc.exists) return false;

      await FirebaseFirestore.instance.collection('devices').doc(deviceId).update({
        'status': 'online',
        'lastSeen': FieldValue.serverTimestamp(),
        'wifiStatus': 'Connected',
      });
      return true;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<DeviceModel?> getDeviceStatus(String deviceId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('devices').doc(deviceId).get();
      if (!doc.exists || doc.data() == null) return null;
      return DeviceModel.fromMap(doc.data()!, doc.id);
    } catch (_) {
      return DeviceModel(
        deviceId: deviceId,
        userId: 'DEMO_USER_001',
        deviceName: 'SmartMed Box',
        status: 'online',
        lastSeen: DateTime.now(),
        firmwareVersion: '1.0.0',
        compartmentCount: 4,
        wifiStatus: 'Connected',
        currentActivity: 'Waiting for schedule',
      );
    }
  }

  @override
  Future<List<MedicineModel>> getMedicineSchedule(String deviceId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceId)
          .collection('schedule')
          .get();

      return snapshot.docs
          .map((doc) => MedicineModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> sendReminderStartedEvent({
    required String deviceId,
    required String medicineId,
    required int compartment,
  }) async {
    try {
      final event = DeviceEventModel(
        eventId: '',
        deviceId: deviceId,
        medicineId: medicineId,
        event: 'reminder_started',
        compartment: compartment,
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceId)
          .collection('events')
          .add(event.toMap());

      await FirebaseFirestore.instance.collection('devices').doc(deviceId).update({
        'currentActivity': 'Reminder Active: Compartment $compartment',
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  @override
  Future<void> sendMedicineTakenEvent({
    required String deviceId,
    required String medicineId,
    required int compartment,
  }) async {
    try {
      final event = DeviceEventModel(
        eventId: '',
        deviceId: deviceId,
        medicineId: medicineId,
        event: 'medicine_taken',
        compartment: compartment,
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceId)
          .collection('events')
          .add(event.toMap());

      await FirebaseFirestore.instance.collection('devices').doc(deviceId).update({
        'currentActivity': 'Medicine Taken from Compartment $compartment',
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  @override
  Future<void> sendMedicineMissedEvent({
    required String deviceId,
    required String medicineId,
    required int compartment,
  }) async {
    try {
      final event = DeviceEventModel(
        eventId: '',
        deviceId: deviceId,
        medicineId: medicineId,
        event: 'medicine_missed',
        compartment: compartment,
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceId)
          .collection('events')
          .add(event.toMap());

      await FirebaseFirestore.instance.collection('devices').doc(deviceId).update({
        'currentActivity': 'Medicine Missed in Compartment $compartment',
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  @override
  Future<void> updateDeviceHeartbeat(String deviceId) async {
    try {
      await FirebaseFirestore.instance.collection('devices').doc(deviceId).update({
        'status': 'online',
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}
