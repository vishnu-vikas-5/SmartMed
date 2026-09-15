import 'package:flutter/material.dart';
import '../../../../data/models/device_model.dart';
import '../../../../data/repositories/device_repository.dart';

class DeviceViewModel extends ChangeNotifier {
  final DeviceRepository _deviceRepository;

  DeviceViewModel({DeviceRepository? deviceRepository})
      : _deviceRepository = deviceRepository ?? DeviceRepository();

  DeviceModel? _pairedDevice;
  DeviceModel? get pairedDevice => _pairedDevice;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void init(String userId, {String? deviceId}) {
    if (deviceId == null || deviceId.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    _deviceRepository.getPairedDeviceStream(deviceId).listen((device) {
      _pairedDevice = device;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> pairDevice({
    required String userId,
    required String deviceId,
    required String deviceName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _deviceRepository.pairDevice(
        userId: userId,
        deviceId: deviceId,
        deviceName: deviceName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> unpairDevice(String userId, String deviceId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _deviceRepository.unpairDevice(userId, deviceId);
      _pairedDevice = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
