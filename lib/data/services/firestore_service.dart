import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_model.dart';
import '../models/device_model.dart';
import '../models/medicine_log_model.dart';

class FirestoreService {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // In-memory fallback state for demo mode
  final List<MedicineModel> _demoMedicines = [
    MedicineModel(
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
    ),
    MedicineModel(
      medicineId: 'MED002',
      name: 'Vitamin D3',
      dosage: '1000 IU',
      quantity: 1,
      time: '13:00',
      compartment: 1,
      frequency: 'Daily',
      instructions: 'Take with lunch',
      enabled: true,
      createdAt: DateTime.now(),
    ),
  ];

  final List<MedicineLogModel> _demoLogs = [
    MedicineLogModel(
      logId: 'LOG001',
      medicineId: 'MED001',
      medicineName: 'Paracetamol',
      dosage: '500 mg',
      scheduledTime: DateTime.now().subtract(const Duration(hours: 4)),
      takenTime: DateTime.now().subtract(const Duration(hours: 3, minutes: 55)),
      compartment: 2,
      status: MedicineStatus.taken,
    ),
    MedicineLogModel(
      logId: 'LOG002',
      medicineId: 'MED002',
      medicineName: 'Vitamin D3',
      dosage: '1000 IU',
      scheduledTime: DateTime.now().add(const Duration(hours: 2)),
      compartment: 1,
      status: MedicineStatus.pending,
    ),
  ];

  DeviceModel _demoDevice = DeviceModel(
    deviceId: 'SM-ESP32-001',
    userId: 'DEMO_USER_001',
    deviceName: 'SmartMed Box',
    status: 'online',
    lastSeen: DateTime.now(),
    firmwareVersion: '1.0.0',
    compartmentCount: 4,
    wifiStatus: 'Connected',
    currentActivity: 'Waiting for schedule',
  );

  final StreamController<List<MedicineModel>> _medController =
      StreamController<List<MedicineModel>>.broadcast();
  final StreamController<List<MedicineLogModel>> _logsController =
      StreamController<List<MedicineLogModel>>.broadcast();
  final StreamController<DeviceModel?> _deviceController =
      StreamController<DeviceModel?>.broadcast();

  // ---------------------------------------------------------------------------
  // MEDICINES MANAGEMENT
  // ---------------------------------------------------------------------------

  Stream<List<MedicineModel>> streamMedicines(String userId) {
    try {
      final fs = _firestore;
      if (fs != null) {
        return fs
            .collection('users')
            .doc(userId)
            .collection('medicines')
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => MedicineModel.fromMap(doc.data(), doc.id))
                .toList());
      }
    } catch (_) {}
    Future.microtask(() => _medController.add(_demoMedicines));
    return _medController.stream;
  }

  Future<void> addMedicine(String userId, MedicineModel medicine,
      {String? pairedDeviceId}) async {
    try {
      final fs = _firestore;
      if (fs != null) {
        final docRef = fs
            .collection('users')
            .doc(userId)
            .collection('medicines')
            .doc();

        final medicineWithId = medicine.copyWith(medicineId: docRef.id);
        await docRef.set(medicineWithId.toMap());
        if (pairedDeviceId != null && pairedDeviceId.isNotEmpty) {
          await syncScheduleToDevice(pairedDeviceId, medicineWithId);
        }
        await createDailyPendingLog(userId, medicineWithId);
        return;
      }
    } catch (_) {}

    final newId = 'MED_${DateTime.now().millisecondsSinceEpoch}';
    final medWithId = medicine.copyWith(medicineId: newId);
    _demoMedicines.add(medWithId);
    _medController.add(_demoMedicines);
    await createDailyPendingLog(userId, medWithId);
  }

  Future<void> updateMedicine(String userId, MedicineModel medicine,
      {String? pairedDeviceId}) async {
    try {
      final fs = _firestore;
      if (fs != null) {
        await fs
            .collection('users')
            .doc(userId)
            .collection('medicines')
            .doc(medicine.medicineId)
            .update(medicine.toMap());
        return;
      }
    } catch (_) {}

    final idx =
        _demoMedicines.indexWhere((m) => m.medicineId == medicine.medicineId);
    if (idx != -1) {
      _demoMedicines[idx] = medicine;
      _medController.add(_demoMedicines);
    }
  }

  Future<void> deleteMedicine(String userId, String medicineId,
      {String? pairedDeviceId}) async {
    try {
      final fs = _firestore;
      if (fs != null) {
        await fs
            .collection('users')
            .doc(userId)
            .collection('medicines')
            .doc(medicineId)
            .delete();
        return;
      }
    } catch (_) {}

    _demoMedicines.removeWhere((m) => m.medicineId == medicineId);
    _medController.add(_demoMedicines);
  }

  Future<void> syncScheduleToDevice(
      String deviceId, MedicineModel medicine) async {
    try {
      final fs = _firestore;
      if (fs != null) {
        await fs
            .collection('devices')
            .doc(deviceId)
            .collection('schedule')
            .doc(medicine.medicineId)
            .set(medicine.toScheduleMap());
      }
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // DEVICE MANAGEMENT
  // ---------------------------------------------------------------------------

  Stream<DeviceModel?> streamPairedDevice(String deviceId) {
    try {
      final fs = _firestore;
      if (fs != null && deviceId.isNotEmpty) {
        return fs
            .collection('devices')
            .doc(deviceId)
            .snapshots()
            .map((doc) {
          if (!doc.exists || doc.data() == null) return null;
          return DeviceModel.fromMap(doc.data()!, doc.id);
        });
      }
    } catch (_) {}
    Future.microtask(() => _deviceController.add(_demoDevice));
    return _deviceController.stream;
  }

  Future<DeviceModel?> getDevice(String deviceId) async {
    try {
      final fs = _firestore;
      if (fs != null) {
        final doc = await fs.collection('devices').doc(deviceId).get();
        if (!doc.exists || doc.data() == null) return null;
        return DeviceModel.fromMap(doc.data()!, doc.id);
      }
    } catch (_) {}
    return _demoDevice;
  }

  Future<void> pairDevice({
    required String userId,
    required String deviceId,
    required String deviceName,
  }) async {
    try {
      final fs = _firestore;
      if (fs != null) {
        final newDevice = DeviceModel(
          deviceId: deviceId,
          userId: userId,
          deviceName: deviceName,
          status: 'online',
          lastSeen: DateTime.now(),
          firmwareVersion: '1.0.0',
          compartmentCount: 4,
          wifiStatus: 'Connected',
        );
        await fs
            .collection('devices')
            .doc(deviceId)
            .set(newDevice.toMap(), SetOptions(merge: true));
        return;
      }
    } catch (_) {}

    _demoDevice = DeviceModel(
      deviceId: deviceId,
      userId: userId,
      deviceName: deviceName,
      status: 'online',
      lastSeen: DateTime.now(),
      firmwareVersion: '1.0.0',
      compartmentCount: 4,
      wifiStatus: 'Connected',
    );
    _deviceController.add(_demoDevice);
  }

  Future<void> unpairDevice(String userId, String deviceId) async {
    try {
      final fs = _firestore;
      if (fs != null) {
        await fs
            .collection('devices')
            .doc(deviceId)
            .update({'userId': ''});
        return;
      }
    } catch (_) {}

    _demoDevice = DeviceModel(
      deviceId: '',
      userId: '',
      deviceName: 'Unpaired Box',
      status: 'offline',
      lastSeen: DateTime.now().subtract(const Duration(days: 1)),
    );
    _deviceController.add(_demoDevice);
  }

  // ---------------------------------------------------------------------------
  // MEDICINE LOGS & HISTORY
  // ---------------------------------------------------------------------------

  Stream<List<MedicineLogModel>> streamTodayLogs(String userId) {
    try {
      final fs = _firestore;
      if (fs != null) {
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

        return fs
            .collection('users')
            .doc(userId)
            .collection('medicineLogs')
            .where('scheduledTime',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('scheduledTime',
                isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => MedicineLogModel.fromMap(doc.data(), doc.id))
                .toList());
      }
    } catch (_) {}

    Future.microtask(() => _logsController.add(_demoLogs));
    return _logsController.stream;
  }

  Stream<List<MedicineLogModel>> streamAllLogs(String userId) {
    try {
      final fs = _firestore;
      if (fs != null) {
        return fs
            .collection('users')
            .doc(userId)
            .collection('medicineLogs')
            .orderBy('scheduledTime', descending: true)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => MedicineLogModel.fromMap(doc.data(), doc.id))
                .toList());
      }
    } catch (_) {}

    Future.microtask(() => _logsController.add(_demoLogs));
    return _logsController.stream;
  }

  Future<void> createDailyPendingLog(
      String userId, MedicineModel medicine) async {
    final now = DateTime.now();
    final parts = medicine.time.split(':');
    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    final logId = "${medicine.medicineId}_${now.year}${now.month}${now.day}";

    try {
      final fs = _firestore;
      if (fs != null) {
        final logRef = fs
            .collection('users')
            .doc(userId)
            .collection('medicineLogs')
            .doc(logId);

        final doc = await logRef.get();
        if (!doc.exists) {
          final log = MedicineLogModel(
            logId: logId,
            medicineId: medicine.medicineId,
            medicineName: medicine.name,
            dosage: medicine.dosage,
            scheduledTime: scheduledDate,
            compartment: medicine.compartment,
            status: MedicineStatus.pending,
          );
          await logRef.set(log.toMap());
        }
        return;
      }
    } catch (_) {}

    final log = MedicineLogModel(
      logId: logId,
      medicineId: medicine.medicineId,
      medicineName: medicine.name,
      dosage: medicine.dosage,
      scheduledTime: scheduledDate,
      compartment: medicine.compartment,
      status: MedicineStatus.pending,
    );
    _demoLogs.add(log);
    _logsController.add(_demoLogs);
  }

  Future<void> updateLogStatus({
    required String userId,
    required String medicineId,
    required MedicineStatus status,
    DateTime? takenTime,
  }) async {
    try {
      final fs = _firestore;
      if (fs != null) {
        final now = DateTime.now();
        final logId = "${medicineId}_${now.year}${now.month}${now.day}";

        final map = <String, dynamic>{
          'status': status.toValue(),
        };
        if (takenTime != null) {
          map['takenTime'] = Timestamp.fromDate(takenTime);
        }

        await fs
            .collection('users')
            .doc(userId)
            .collection('medicineLogs')
            .doc(logId)
            .set(map, SetOptions(merge: true));
        return;
      }
    } catch (_) {}

    final idx = _demoLogs.indexWhere((l) => l.medicineId == medicineId);
    if (idx != -1) {
      final existing = _demoLogs[idx];
      _demoLogs[idx] = MedicineLogModel(
        logId: existing.logId,
        medicineId: existing.medicineId,
        medicineName: existing.medicineName,
        dosage: existing.dosage,
        scheduledTime: existing.scheduledTime,
        takenTime: takenTime ?? existing.takenTime,
        compartment: existing.compartment,
        status: status,
      );
      _logsController.add(_demoLogs);
    }
  }
}
