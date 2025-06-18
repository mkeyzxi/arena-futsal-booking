// lib/models/booking_model.dart
import 'package:flutter/foundation.dart'; // Untuk @required jika versi Dart < 2.12

enum BookingStatus {
  pendingPaymentDP, // Menunggu pembayaran DP
  dpPaid, // DP sudah dibayar, menunggu pelunasan / konfirmasi
  confirmed, // Booking dikonfirmasi penuh
  completed, // Booking selesai (setelah tanggal/waktu berlalu)
  cancelled, // Booking dibatalkan (oleh pengguna)
  rejectedByAdmin // Booking ditolak oleh admin
}

enum PaymentMethod {
  qris,
  cash,
}

class Booking {
  final String id;
  final String userId;
  final String userName;
  final String fieldId;
  final String fieldName;
  final DateTime bookingDate; // Tanggal booking
  final DateTime startTime;
  final DateTime endTime;
  final double totalCost;
  final double dpAmount;
  final PaymentMethod paymentMethod;
  final BookingStatus status;
  final DateTime? paymentDate; // Waktu pembayaran DP
  final String? paymentProofUrl; // URL bukti pembayaran (misal QRIS)
  final String? adminNotes; // Catatan dari admin jika dibatalkan/ditolak

  Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.fieldId,
    required this.fieldName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalCost,
    required this.dpAmount,
    required this.paymentMethod,
    this.status = BookingStatus.pendingPaymentDP,
    this.paymentDate,
    this.paymentProofUrl,
    this.adminNotes,
  });

  factory Booking.fromMap(Map<String, dynamic> data, String id) {
    return Booking(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown User',
      fieldId: data['fieldId'] ?? '',
      fieldName: data['fieldName'] ?? 'Unknown Field',
      bookingDate: (data['bookingDate'] as dynamic)
          .toDate(), // Contoh: Firebase Timestamp
      startTime:
          (data['startTime'] as dynamic).toDate(), // Contoh: Firebase Timestamp
      endTime:
          (data['endTime'] as dynamic).toDate(), // Contoh: Firebase Timestamp
      totalCost: (data['totalCost'] as num?)?.toDouble() ?? 0.0,
      dpAmount: (data['dpAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: PaymentMethod.values.firstWhere(
          (e) => e.toString() == 'PaymentMethod.${data['paymentMethod']}',
          orElse: () => PaymentMethod.cash),
      status: BookingStatus.values.firstWhere(
          (e) => e.toString() == 'BookingStatus.${data['status']}',
          orElse: () => BookingStatus.pendingPaymentDP),
      paymentDate: (data['paymentDate'] as dynamic?)
          ?.toDate(), // Contoh: Firebase Timestamp
      paymentProofUrl: data['paymentProofUrl'],
      adminNotes: data['adminNotes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'fieldId': fieldId,
      'fieldName': fieldName,
      'bookingDate': bookingDate,
      'startTime': startTime,
      'endTime': endTime,
      'totalCost': totalCost,
      'dpAmount': dpAmount,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'status': status.toString().split('.').last,
      'paymentDate': paymentDate,
      'paymentProofUrl': paymentProofUrl,
      'adminNotes': adminNotes,
    };
  }
}

// Tambahkan copyWith method di Booking model
extension BookingCopyWith on Booking {
  Booking copyWith({
    String? id,
    String? userId,
    String? userName,
    String? fieldId,
    String? fieldName,
    DateTime? bookingDate,
    DateTime? startTime,
    DateTime? endTime,
    double? totalCost,
    double? dpAmount,
    PaymentMethod? paymentMethod,
    BookingStatus? status,
    DateTime? paymentDate,
    String? paymentProofUrl,
    String? adminNotes,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      fieldId: fieldId ?? this.fieldId,
      fieldName: fieldName ?? this.fieldName,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalCost: totalCost ?? this.totalCost,
      dpAmount: dpAmount ?? this.dpAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentProofUrl: paymentProofUrl ?? this.paymentProofUrl,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }
}
