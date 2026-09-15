import 'package:cloud_firestore/cloud_firestore.dart';

enum MedicineStatus { pending, reminder_active, taken, missed }

extension MedicineStatusExtension on MedicineStatus {
  String toValue() {
    switch (this) {
      case MedicineStatus.pending:
        return 'pending';
      case MedicineStatus.reminder_active:
        return 'reminder_active';
      case MedicineStatus.taken:
        return 'taken';
      case MedicineStatus.missed:
        return 'missed';
    }
  }

  static MedicineStatus fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'reminder_active':
      case 'active':
        return MedicineStatus.reminder_active;
      case 'taken':
        return MedicineStatus.taken;
      case 'missed':
        return MedicineStatus.missed;
      case 'pending':
      default:
        return MedicineStatus.pending;
    }
  }
}

class MedicineLogModel {
  final String logId;
  final String medicineId;
  final String medicineName;
  final String dosage;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final int compartment;
  final MedicineStatus status;

  MedicineLogModel({
    required this.logId,
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.scheduledTime,
    this.takenTime,
    required this.compartment,
    required this.status,
  });

  factory MedicineLogModel.fromMap(Map<String, dynamic> map, String id) {
    return MedicineLogModel(
      logId: id,
      medicineId: map['medicineId'] as String? ?? '',
      medicineName: map['medicineName'] as String? ?? 'Medicine',
      dosage: map['dosage'] as String? ?? '',
      scheduledTime: map['scheduledTime'] is Timestamp
          ? (map['scheduledTime'] as Timestamp).toDate()
          : DateTime.now(),
      takenTime: map['takenTime'] is Timestamp
          ? (map['takenTime'] as Timestamp).toDate()
          : null,
      compartment: (map['compartment'] as num?)?.toInt() ?? 1,
      status: MedicineStatusExtension.fromValue(
          map['status'] as String? ?? 'pending'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicineId,
      'medicineName': medicineName,
      'dosage': dosage,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'takenTime': takenTime != null ? Timestamp.fromDate(takenTime!) : null,
      'compartment': compartment,
      'status': status.toValue(),
    };
  }
}
