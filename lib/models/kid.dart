import 'package:cloud_firestore/cloud_firestore.dart';

class Kid {
  final String id;
  final String name;
  final DateTime? birthdate;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final double? bmi;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Kid({
    required this.id,
    required this.name,
    this.birthdate,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.bmi,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'birthdate':
          birthdate != null ? Timestamp.fromDate(birthdate!) : null,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'bmi': bmi,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Kid.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    Timestamp? tBirth = data['birthdate'] as Timestamp?;
    Timestamp created = data['createdAt'] as Timestamp? ?? Timestamp.now();
    Timestamp updated = data['updatedAt'] as Timestamp? ?? Timestamp.now();

    return Kid(
      id: doc.id,
      name: data['name'] ?? '',
      birthdate: tBirth?.toDate(),
      gender: data['gender'],
      heightCm: (data['heightCm'] as num?)?.toDouble(),
      weightKg: (data['weightKg'] as num?)?.toDouble(),
      bmi: (data['bmi'] as num?)?.toDouble(),
      notes: data['notes'],
      createdAt: created.toDate(),
      updatedAt: updated.toDate(),
    );
  }
}
