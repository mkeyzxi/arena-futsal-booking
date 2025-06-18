import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:futsal_booking_app/providers/auth_provider.dart';
import 'package:futsal_booking_app/providers/booking_provider.dart';
import 'package:futsal_booking_app/models/booking_model.dart';
import 'package:futsal_booking_app/utils/app_colors.dart';

class UserBookingHistoryScreen extends StatelessWidget {
  const UserBookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);

    // Filter booking berdasarkan user yang sedang login
    final userBookings = bookingProvider.bookings
        .where((booking) => booking.userId == authProvider.currentUser?.id)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Riwayat Booking Saya'),
      ),
      body: bookingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userBookings.isEmpty
              ? const Center(
                  child: Text(
                    'Anda belum memiliki riwayat booking.',
                    style: TextStyle(
                        fontSize: 16, color: AppColors.lightTextColor),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: userBookings.length,
                  itemBuilder: (context, index) {
                    final booking = userBookings[index];
                    return BookingHistoryCard(booking: booking);
                  },
                ),
    );
  }
}

class BookingHistoryCard extends StatelessWidget {
  final Booking booking;

  const BookingHistoryCard({super.key, required this.booking});

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pendingPaymentDP:
        return Colors.orange;
      case BookingStatus.dpPaid:
        return Colors.blue;
      case BookingStatus.confirmed:
        return AppColors.successColor;
      case BookingStatus.completed:
        return AppColors.lightTextColor;
      case BookingStatus.cancelled:
      case BookingStatus.rejectedByAdmin:
        return AppColors.errorColor;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pendingPaymentDP:
        return 'Menunggu DP';
      case BookingStatus.dpPaid:
        return 'DP Dibayar';
      case BookingStatus.confirmed:
        return 'Dikonfirmasi';
      case BookingStatus.completed:
        return 'Selesai';
      case BookingStatus.cancelled:
        return 'Dibatalkan';
      case BookingStatus.rejectedByAdmin:
        return 'Ditolak Admin';
      default:
        return 'Tidak Diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.fieldName,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(booking.status),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Tanggal: ${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(booking.bookingDate)}',
              style: const TextStyle(
                  fontSize: 15, color: AppColors.lightTextColor),
            ),
            const SizedBox(height: 5),
            Text(
              'Waktu: ${DateFormat('HH:mm').format(booking.startTime)} - ${DateFormat('HH:mm').format(booking.endTime)}',
              style: const TextStyle(
                  fontSize: 15, color: AppColors.lightTextColor),
            ),
            const SizedBox(height: 5),
            Text(
              'Metode Pembayaran: ${booking.paymentMethod == PaymentMethod.qris ? 'QRIS' : 'Cash'}',
              style: const TextStyle(
                  fontSize: 15, color: AppColors.lightTextColor),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Biaya:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text('Rp ${booking.totalCost.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('DP Dibayar:',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor)),
                Text('Rp ${booking.dpAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor)),
              ],
            ),
            if (booking.status == BookingStatus.pendingPaymentDP &&
                booking.paymentMethod == PaymentMethod.qris) ...[
              const Divider(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Logika untuk menampilkan QRIS atau petunjuk pembayaran
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Simulasi: Tampilkan QRIS untuk pembayaran DP.')),
                    );
                  },
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Bayar DP QRIS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.accentColor, // Warna kuning untuk pembayaran
                    foregroundColor: AppColors.textColor,
                  ),
                ),
              ),
            ],
            if (booking.adminNotes != null &&
                booking.adminNotes!.isNotEmpty) ...[
              const Divider(height: 20),
              Text(
                'Catatan Admin: ${booking.adminNotes}',
                style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppColors.errorColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
