import 'package:flutter/material.dart';
import '../../../../data/models/medicine_model.dart';
import '../../../../data/models/medicine_log_model.dart';
import '../../../../data/repositories/medicine_repository.dart';

class MedicineViewModel extends ChangeNotifier {
  final MedicineRepository _medicineRepository;

  MedicineViewModel({MedicineRepository? medicineRepository})
      : _medicineRepository = medicineRepository ?? MedicineRepository();

  List<MedicineModel> _medicines = [];
  List<MedicineModel> get medicines => _medicines;

  List<MedicineLogModel> _todayLogs = [];
  List<MedicineLogModel> get todayLogs => _todayLogs;

  List<MedicineLogModel> _allLogs = [];
  List<MedicineLogModel> get allLogs => _allLogs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _pairedDeviceId;

  void init(String userId, {String? deviceId}) {
    _pairedDeviceId = deviceId;
    _isLoading = true;
    notifyListeners();

    _medicineRepository.getMedicinesStream(userId).listen((meds) {
      _medicines = meds;
      _isLoading = false;
      notifyListeners();
    });

    _medicineRepository.getTodayLogsStream(userId).listen((logs) {
      _todayLogs = logs;
      notifyListeners();
    });

    _medicineRepository.getAllLogsStream(userId).listen((logs) {
      _allLogs = logs;
      notifyListeners();
    });
  }

  Future<void> addMedicine(String userId, MedicineModel medicine) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _medicineRepository.addMedicine(userId, medicine,
          pairedDeviceId: _pairedDeviceId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMedicine(String userId, MedicineModel medicine) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _medicineRepository.updateMedicine(userId, medicine,
          pairedDeviceId: _pairedDeviceId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMedicine(String userId, String medicineId) async {
    await _medicineRepository.deleteMedicine(userId, medicineId,
        pairedDeviceId: _pairedDeviceId);
  }

  MedicineLogModel? getLogForMedicine(String medicineId) {
    for (var l in _todayLogs) {
      if (l.medicineId == medicineId) return l;
    }
    return null;
  }
}
