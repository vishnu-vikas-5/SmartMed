import '../models/device_model.dart';
import '../services/firestore_service.dart';

class DeviceRepository {
  final FirestoreService _firestoreService;

  DeviceRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<DeviceModel?> getPairedDeviceStream(String deviceId) {
    return _firestoreService.streamPairedDevice(deviceId);
  }

  Future<DeviceModel?> getDevice(String deviceId) {
    return _firestoreService.getDevice(deviceId);
  }

  Future<void> pairDevice({
    required String userId,
    required String deviceId,
    required String deviceName,
  }) {
    return _firestoreService.pairDevice(
      userId: userId,
      deviceId: deviceId,
      deviceName: deviceName,
    );
  }

  Future<void> unpairDevice(String userId, String deviceId) {
    return _firestoreService.unpairDevice(userId, deviceId);
  }
}
