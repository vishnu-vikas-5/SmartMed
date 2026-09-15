import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceEventModel {
  final String eventId;
  final String deviceId;
  final String medicineId;
  final String event; // 'reminder_started', 'medicine_taken', 'medicine_missed'
  final int compartment;
  final DateTime timestamp;

  DeviceEventModel({
    required this.eventId,
    required this.deviceId,
    required this.medicineId,
    required this.event,
    required this.compartment,
    required this.timestamp,
  });

  factory DeviceEventModel.fromMap(Map<String, dynamic> map, String id) {
    return DeviceEventModel(
      eventId: id,
      deviceId: map['deviceId'] as String? ?? '',
      medicineId: map['medicineId'] as String? ?? '',
      event: map['event'] as String? ?? '',
      compartment: (map['compartment'] as num?)?.toInt() ?? 1,
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'medicineId': medicineId,
      'event': event,
      'compartment': compartment,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
