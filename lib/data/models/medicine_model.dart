import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineModel {
  final String medicineId;
  final String name;
  final String dosage;
  final int quantity;
  final String time; // HH:mm format e.g., "08:00"
  final int compartment; // 1 to 4
  final String frequency; // e.g. "Daily", "Weekly", "As Needed"
  final String instructions; // e.g. "Take after breakfast"
  final bool enabled;
  final DateTime createdAt;
  final DateTime? startDate;
  final DateTime? endDate;

  MedicineModel({
    required this.medicineId,
    required this.name,
    required this.dosage,
    required this.quantity,
    required this.time,
    required this.compartment,
    required this.frequency,
    required this.instructions,
    this.enabled = true,
    required this.createdAt,
    this.startDate,
    this.endDate,
  });

  factory MedicineModel.fromMap(Map<String, dynamic> map, String id) {
    return MedicineModel(
      medicineId: id,
      name: map['name'] as String? ?? '',
      dosage: map['dosage'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      time: map['time'] as String? ?? '08:00',
      compartment: (map['compartment'] as num?)?.toInt() ?? 1,
      frequency: map['frequency'] as String? ?? 'Daily',
      instructions: map['instructions'] as String? ?? '',
      enabled: map['enabled'] as bool? ?? true,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      startDate: map['startDate'] is Timestamp
          ? (map['startDate'] as Timestamp).toDate()
          : null,
      endDate: map['endDate'] is Timestamp
          ? (map['endDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicineId,
      'name': name,
      'dosage': dosage,
      'quantity': quantity,
      'time': time,
      'compartment': compartment,
      'frequency': frequency,
      'instructions': instructions,
      'enabled': enabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
    };
  }

  /// Convert to ESP32 Schedule item representation
  Map<String, dynamic> toScheduleMap() {
    return {
      'medicineId': medicineId,
      'medicineName': name,
      'dosage': dosage,
      'quantity': quantity,
      'time': time,
      'compartment': compartment,
      'instructions': instructions,
      'enabled': enabled,
    };
  }

  MedicineModel copyWith({
    String? medicineId,
    String? name,
    String? dosage,
    int? quantity,
    String? time,
    int? compartment,
    String? frequency,
    String? instructions,
    bool? enabled,
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return MedicineModel(
      medicineId: medicineId ?? this.medicineId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      quantity: quantity ?? this.quantity,
      time: time ?? this.time,
      compartment: compartment ?? this.compartment,
      frequency: frequency ?? this.frequency,
      instructions: instructions ?? this.instructions,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
