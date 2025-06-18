// lib/providers/booking_provider.dart
import 'package:flutter/material.dart';
import 'package:futsal_booking_app/models/booking_model.dart';
import 'package:futsal_booking_app/models/schedule_model.dart';
import 'package:futsal_booking_app/models/field_model.dart'; // Diperlukan untuk simulasi data
import 'package:uuid/uuid.dart';

class BookingProvider with ChangeNotifier {
  List<Booking> _bookings = [];
  List<ScheduleSlot> _scheduleSlots = []; // Untuk simulasi slot waktu
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();

  List<Booking> get bookings => _bookings;
  List<ScheduleSlot> get scheduleSlots => _scheduleSlots;
  bool get isLoading => _isLoading;

  BookingProvider() {
    // Muat data booking dan jadwal saat inisialisasi
    fetchBookings();
    fetchScheduleSlots();
  }

  // --- Methods untuk Booking ---

  Future<void> fetchBookings() async {
    _isLoading = true;
    notifyListeners();

    // Simulasi pengambilan data booking dari database
    await Future.delayed(const Duration(seconds: 1));

    // Dummy data booking (akan diganti dengan data dari backend)
    // Gunakan tanggal di masa depan agar bisa terlihat di daftar booking
    final today = DateTime.now();
    _bookings = [
      Booking(
        id: 'bk_001',
        userId: 'user_id_1',
        userName: 'John Doe',
        fieldId: 'field_001',
        fieldName: 'Lapangan 1',
        bookingDate: DateTime(
            today.year, today.month, today.day + 2), // 2 hari dari sekarang
        startTime: DateTime(today.year, today.month, today.day + 2, 18, 0),
        endTime: DateTime(today.year, today.month, today.day + 2, 19, 0),
        totalCost: 100000.0,
        dpAmount: 50000.0,
        paymentMethod: PaymentMethod.qris,
        status: BookingStatus.dpPaid,
        paymentDate: DateTime(today.year, today.month, today.day + 1, 10, 30),
      ),
      Booking(
        id: 'bk_002',
        userId: 'user_id_2',
        userName: 'Jane Smith',
        fieldId: 'field_002',
        fieldName: 'Lapangan 2',
        bookingDate: DateTime(
            today.year, today.month, today.day + 3), // 3 hari dari sekarang
        startTime: DateTime(today.year, today.month, today.day + 3, 20, 0),
        endTime:
            DateTime(today.year, today.month, today.day + 3, 22, 0), // 2 jam
        totalCost: 170000.0,
        dpAmount: 85000.0,
        paymentMethod: PaymentMethod.cash,
        status: BookingStatus.confirmed,
      ),
      Booking(
        id: 'bk_003',
        userId: 'user_id_1',
        userName: 'John Doe',
        fieldId: 'field_003',
        fieldName: 'Lapangan 3 (Profesional)',
        bookingDate: DateTime(today.year, today.month, today.day + 1), // Besok
        startTime: DateTime(today.year, today.month, today.day + 1, 19, 0),
        endTime: DateTime(today.year, today.month, today.day + 1, 20, 0),
        totalCost: 150000.0,
        dpAmount: 75000.0,
        paymentMethod: PaymentMethod.qris,
        status: BookingStatus.pendingPaymentDP,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createBooking(Booking newBooking) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulasi API call
      // Assign unique ID for the booking
      final bookingWithId = newBooking.copyWith(id: _uuid.v4());
      _bookings.add(bookingWithId);

      // Update schedule slot status
      // (Di dunia nyata, ini akan berinteraksi dengan backend untuk mengunci slot)
      for (int i = 0;
          i < (bookingWithId.endTime.hour - bookingWithId.startTime.hour);
          i++) {
        final slotStartTime = DateTime(
          bookingWithId.startTime.year,
          bookingWithId.startTime.month,
          bookingWithId.startTime.day,
          bookingWithId.startTime.hour + i,
          0,
        );
        final slotIndex = _scheduleSlots.indexWhere(
          (slot) =>
              slot.fieldId == bookingWithId.fieldId &&
              slot.startTime == slotStartTime &&
              !slot.isBooked,
        );
        if (slotIndex != -1) {
          _scheduleSlots[slotIndex].isBooked = true;
          _scheduleSlots[slotIndex].bookingId = bookingWithId.id;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus,
      {String? adminNotes}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulasi API call
      int index = _bookings.indexWhere((booking) => booking.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index]
            .copyWith(status: newStatus, adminNotes: adminNotes);

        // Jika dibatalkan atau ditolak, bebaskan slot jadwal
        if (newStatus == BookingStatus.cancelled ||
            newStatus == BookingStatus.rejectedByAdmin) {
          final booking = _bookings[index];
          for (int i = 0;
              i < (booking.endTime.hour - booking.startTime.hour);
              i++) {
            final slotStartTime = DateTime(
              booking.startTime.year,
              booking.startTime.month,
              booking.startTime.day,
              booking.startTime.hour + i,
              0,
            );
            final scheduleIndex = _scheduleSlots.indexWhere((slot) =>
                slot.fieldId == booking.fieldId &&
                slot.startTime == slotStartTime &&
                slot.bookingId == bookingId);
            if (scheduleIndex != -1) {
              _scheduleSlots[scheduleIndex].isBooked = false;
              _scheduleSlots[scheduleIndex].bookingId = null;
            }
          }
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // --- Methods untuk Jadwal ---

  Future<void> fetchScheduleSlots() async {
    _isLoading = true;
    notifyListeners();

    // Simulasi pengambilan data jadwal dari database
    await Future.delayed(const Duration(seconds: 1));

    // Dummy data jadwal untuk semua lapangan (hanya contoh untuk beberapa jam)
    final today = DateTime.now();
    _scheduleSlots = [];
    final List<String> fieldIds = [
      'field_001',
      'field_002',
      'field_003'
    ]; // Ambil dari FieldProvider di app nyata

    for (int i = 0; i < 7; i++) {
      // Untuk 7 hari ke depan
      final date =
          DateTime(today.year, today.month, today.day).add(Duration(days: i));
      for (String fieldId in fieldIds) {
        for (int hour = 9; hour <= 22; hour++) {
          // Dari jam 9 pagi sampai 10 malam
          _scheduleSlots.add(ScheduleSlot(
            id: _uuid.v4(),
            fieldId: fieldId,
            startTime: DateTime(date.year, date.month, date.day, hour, 0),
            endTime: DateTime(date.year, date.month, date.day, hour + 1, 0),
            isBooked: false, // Default tidak dibooking
          ));
        }
      }
    }

    // Tandai slot yang sudah dibooking dari _bookings dummy
    for (var booking in _bookings) {
      for (int i = 0;
          i < (booking.endTime.hour - booking.startTime.hour);
          i++) {
        final slotStartTime = DateTime(
          booking.startTime.year,
          booking.startTime.month,
          booking.startTime.day,
          booking.startTime.hour + i,
          0,
        );
        final slotIndex = _scheduleSlots.indexWhere(
          (slot) =>
              slot.fieldId == booking.fieldId &&
              slot.startTime == slotStartTime &&
              !slot.isBooked,
        );
        if (slotIndex != -1) {
          _scheduleSlots[slotIndex].isBooked = true;
          _scheduleSlots[slotIndex].bookingId = booking.id;
        }
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Mendapatkan slot jadwal untuk lapangan dan tanggal tertentu
  List<ScheduleSlot> getAvailableSlots(String fieldId, DateTime date) {
    return _scheduleSlots.where((slot) {
      return slot.fieldId == fieldId &&
          slot.startTime.year == date.year &&
          slot.startTime.month == date.month &&
          slot.startTime.day == date.day &&
          !slot.isBooked;
    }).toList();
  }
}
