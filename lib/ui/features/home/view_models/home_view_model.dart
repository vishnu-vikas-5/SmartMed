import 'package:flutter/material.dart';
import '../../../../data/models/medicine_model.dart';
import '../../../../data/models/medicine_log_model.dart';
import '../../../../data/models/device_model.dart';
import '../../../../data/repositories/medicine_repository.dart';
import '../../../../data/repositories/device_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final MedicineRepository _medicineRepository;
  final DeviceRepository _deviceRepository;

  HomeViewModel({
    MedicineRepository? medicineRepository,
    DeviceRepository? deviceRepository,
  })  : _medicineRepository = medicineRepository ?? MedicineRepository(),
        _deviceRepository = deviceRepository ?? DeviceRepository();

  List<MedicineModel> _medicines = [];
  List<MedicineModel> get medicines => _medicines;

  List<MedicineLogModel> _todayLogs = [];
  List<MedicineLogModel> get todayLogs => _todayLogs;

  DeviceModel? _pairedDevice;
  DeviceModel? get pairedDevice => _pairedDevice;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void init(String userId, {String? deviceId}) {
    _isLoading = true;
    notifyListeners();

    // Stream user medicines
    _medicineRepository.getMedicinesStream(userId).listen((meds) {
      _medicines = meds;
      _isLoading = false;
      notifyListeners();
    });

    // Stream today's medicine logs
    _medicineRepository.getTodayLogsStream(userId).listen((logs) {
      _todayLogs = logs;
      notifyListeners();
    });

    // Stream paired device if deviceId is provided
    if (deviceId != null && deviceId.isNotEmpty) {
      _deviceRepository.getPairedDeviceStream(deviceId).listen((device) {
        _pairedDevice = device;
        notifyListeners();
      });
    }
  }

  // Dashboard Stats Calculations
  int get takenCount =>
      _todayLogs.where((l) => l.status == MedicineStatus.taken).length;

  int get pendingCount =>
      _todayLogs.where((l) => l.status == MedicineStatus.pending).length;

  int get missedCount =>
      _todayLogs.where((l) => l.status == MedicineStatus.missed).length;

  int get activeCount =>
      _todayLogs.where((l) => l.status == MedicineStatus.reminder_active).length;

  MedicineModel? get nextMedicine {
    if (_medicines.isEmpty) return null;
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    MedicineModel? next;
    int minDiff = 24 * 60;

    for (var med in _medicines) {
      final parts = med.time.split(':');
      final medHour = int.tryParse(parts[0]) ?? 8;
      final medMin = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      final medTotalMin = medHour * 60 + medMin;

      if (medTotalMin >= nowMinutes && (medTotalMin - nowMinutes) < minDiff) {
        minDiff = medTotalMin - nowMinutes;
        next = med;
      }
    }

    return next ?? _medicines.first;
  }
}
