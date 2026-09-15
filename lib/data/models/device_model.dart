import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  final String deviceId;
  final String userId;
  final String deviceName;
  final String status; // "online" or "offline"
  final DateTime lastSeen;
  final String firmwareVersion;
  final int compartmentCount;
  final String wifiStatus;
  final String currentActivity;

  DeviceModel({
    required this.deviceId,
    required this.userId,
    required this.deviceName,
    required this.status,
    required this.lastSeen,
    this.firmwareVersion = '1.0.0',
    this.compartmentCount = 4,
    this.wifiStatus = 'Connected',
    this.currentActivity = 'Waiting',
  });

  bool get isOnline {
    final diff = DateTime.now().difference(lastSeen);
    return status == 'online' && diff.inMinutes < 2;
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map, String id) {
    final lastSeenTimestamp = map['lastSeen'];
    DateTime parsedLastSeen = DateTime.now();
    if (lastSeenTimestamp is Timestamp) {
      parsedLastSeen = lastSeenTimestamp.toDate();
    } else if (lastSeenTimestamp is String) {
      parsedLastSeen = DateTime.tryParse(lastSeenTimestamp) ?? DateTime.now();
    }

    return DeviceModel(
      deviceId: id,
      userId: map['userId'] as String? ?? '',
      deviceName: map['deviceName'] as String? ?? 'SmartMed Box',
      status: map['status'] as String? ?? 'offline',
      lastSeen: parsedLastSeen,
      firmwareVersion: map['firmwareVersion'] as String? ?? '1.0.0',
      compartmentCount: (map['compartmentCount'] as num?)?.toInt() ?? 4,
      wifiStatus: map['wifiStatus'] as String? ?? 'Connected',
      currentActivity: map['currentActivity'] as String? ?? 'Idle',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'userId': userId,
      'deviceName': deviceName,
      'status': status,
      'lastSeen': Timestamp.fromDate(lastSeen),
      'firmwareVersion': firmwareVersion,
      'compartmentCount': compartmentCount,
      'wifiStatus': wifiStatus,
      'currentActivity': currentActivity,
    };
  }
}
