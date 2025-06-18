// lib/models/schedule_slot_model.dart

class ScheduleSlot {
  final String id;
  final String fieldId;
  final DateTime startTime;
  final DateTime endTime;
  bool isBooked;

  ScheduleSlot({
    required this.id,
    required this.fieldId,
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
  });

  // Metode copyWith untuk mempermudah perubahan objek
  ScheduleSlot copyWith({
    String? id,
    String? fieldId,
    DateTime? startTime,
    DateTime? endTime,
    bool? isBooked,
  }) {
    return ScheduleSlot(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isBooked: isBooked ?? this.isBooked,
    );
  }

  // Opsional: factory constructor untuk membuat ScheduleSlot dari Map (misal dari data Firestore/JSON)
  factory ScheduleSlot.fromMap(Map<String, dynamic> data) {
    return ScheduleSlot(
      id: data['id'] as String,
      fieldId: data['fieldId'] as String,
      // Contoh penanganan DateTime dari Firestore Timestamp atau ISO String
      startTime: (data['startTime'] is Map &&
              (data['startTime'] as Map).containsKey('_seconds'))
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['startTime']['_seconds'] * 1000).toInt() +
                  ((data['startTime']['_nanoseconds'] ?? 0) / 1000000)
                      .round(), // Handle null nanoseconds
              isUtc: true,
            ).toLocal() // Konversi ke waktu lokal jika disimpan dalam UTC
          : DateTime.parse(
              data['startTime'].toString()), // Jika disimpan sebagai ISO String
      endTime: (data['endTime'] is Map &&
              (data['endTime'] as Map).containsKey('_seconds'))
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['endTime']['_seconds'] * 1000).toInt() +
                  ((data['endTime']['_nanoseconds'] ?? 0) / 1000000)
                      .round(), // Handle null nanoseconds
              isUtc: true,
            ).toLocal() // Konversi ke waktu lokal jika disimpan dalam UTC
          : DateTime.parse(
              data['endTime'].toString()), // Jika disimpan sebagai ISO String
      isBooked: data['isBooked'] as bool? ?? false,
    );
  }

  // Opsional: Metode untuk mengubah ScheduleSlot menjadi Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fieldId': fieldId,
      'startTime': startTime.toIso8601String(), // Simpan sebagai ISO string
      'endTime': endTime.toIso8601String(),
      'isBooked': isBooked,
    };
  }
}
