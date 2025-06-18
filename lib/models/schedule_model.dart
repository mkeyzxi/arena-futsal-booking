// lib/models/schedule_model.dart
import 'package:flutter/foundation.dart'; // Untuk @required jika versi Dart < 2.12

class ScheduleSlot {
  final String id;
  final String fieldId;
  final DateTime startTime;
  final DateTime endTime;
  bool isBooked; // true jika sudah dibooking
  String? bookingId; // ID booking jika slot ini sudah dibooking

  ScheduleSlot({
    required this.id,
    required this.fieldId,
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
    this.bookingId,
  });

  // Factory constructor untuk membuat ScheduleSlot dari map (misalnya dari Firestore)
  // Perlu penyesuaian jika tidak menggunakan Firebase Timestamp
  factory ScheduleSlot.fromMap(Map<String, dynamic> data, String id) {
    return ScheduleSlot(
      id: id,
      fieldId: data['fieldId'] ?? '',
      startTime: (data['startTime'] as dynamic)
          .toDate(), // Contoh: Firebase Timestamp to DateTime
      endTime: (data['endTime'] as dynamic)
          .toDate(), // Contoh: Firebase Timestamp to DateTime
      isBooked: data['isBooked'] ?? false,
      bookingId: data['bookingId'],
    );
  }

  // Method untuk mengkonversi ScheduleSlot ke map (misalnya untuk Firestore)
  // Perlu penyesuaian jika tidak menggunakan Firebase Timestamp
  Map<String, dynamic> toMap() {
    return {
      'fieldId': fieldId,
      'startTime': startTime, // Akan disimpan sebagai Timestamp di Firebase
      'endTime': endTime, // Akan disimpan sebagai Timestamp di Firebase
      'isBooked': isBooked,
      'bookingId': bookingId,
    };
  }
}
