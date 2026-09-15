import '../models/medicine_model.dart';
import '../models/medicine_log_model.dart';
import '../services/firestore_service.dart';

class MedicineRepository {
  final FirestoreService _firestoreService;

  MedicineRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<MedicineModel>> getMedicinesStream(String userId) {
    return _firestoreService.streamMedicines(userId);
  }

  Future<void> addMedicine(String userId, MedicineModel medicine, {String? pairedDeviceId}) {
    return _firestoreService.addMedicine(userId, medicine, pairedDeviceId: pairedDeviceId);
  }

  Future<void> updateMedicine(String userId, MedicineModel medicine, {String? pairedDeviceId}) {
    return _firestoreService.updateMedicine(userId, medicine, pairedDeviceId: pairedDeviceId);
  }

  Future<void> deleteMedicine(String userId, String medicineId, {String? pairedDeviceId}) {
    return _firestoreService.deleteMedicine(userId, medicineId, pairedDeviceId: pairedDeviceId);
  }

  Stream<List<MedicineLogModel>> getTodayLogsStream(String userId) {
    return _firestoreService.streamTodayLogs(userId);
  }

  Stream<List<MedicineLogModel>> getAllLogsStream(String userId) {
    return _firestoreService.streamAllLogs(userId);
  }

  Future<void> updateLogStatus({
    required String userId,
    required String medicineId,
    required MedicineStatus status,
    DateTime? takenTime,
  }) {
    return _firestoreService.updateLogStatus(
      userId: userId,
      medicineId: medicineId,
      status: status,
      takenTime: takenTime,
    );
  }
}
