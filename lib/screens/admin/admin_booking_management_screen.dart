// lib/screens/admin/admin_booking_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:futsal_booking_app/providers/booking_provider.dart';
import 'package:futsal_booking_app/models/booking_model.dart';
import 'package:futsal_booking_app/utils/app_colors.dart';

class AdminBookingManagementScreen extends StatefulWidget {
  const AdminBookingManagementScreen({super.key});

  @override
  State<AdminBookingManagementScreen> createState() =>
      _AdminBookingManagementScreenState();
}

class _AdminBookingManagementScreenState
    extends State<AdminBookingManagementScreen> {
  String _selectedFilter =
      'Semua'; // Filter: 'Semua', 'Menunggu DP', 'DP Dibayar', 'Dikonfirmasi', 'Dibatalkan'

  @override
  void initState() {
    super.initState();
    // Memuat ulang data booking setiap kali layar diakses
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    });
  }

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

  Future<void> _showBookingDetailDialog(Booking booking) async {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    final TextEditingController adminNotesController = TextEditingController();

    // Isi catatan admin jika sudah ada
    if (booking.adminNotes != null) {
      adminNotesController.text = booking.adminNotes!;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detail Booking: ${booking.fieldName}'),
          content: StatefulBuilder(
            // Use StatefulBuilder to update dialog UI
            builder: (BuildContext context, StateSetter setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Booking ID: ${booking.id}',
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.lightTextColor)),
                    const Divider(),
                    Text('Pengguna: ${booking.userName}',
                        style: const TextStyle(fontSize: 16)),
                    Text(
                        'Email Pengguna: ${booking.userId == 'user_id_1' ? 'john.doe@example.com' : (booking.userId == 'user_id_2' ? 'jane.smith@example.com' : bookingProvider.bookings.firstWhere((b) => b.id == booking.id).userId)}', // Contoh simulasi email
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.lightTextColor)),
                    const SizedBox(height: 10),
                    Text('Lapangan: ${booking.fieldName}',
                        style: const TextStyle(fontSize: 16)),
                    Text(
                        'Tanggal: ${DateFormat('dd MMMM yyyy').format(booking.bookingDate)}',
                        style: const TextStyle(fontSize: 16)),
                    Text(
                        'Waktu: ${DateFormat('HH:mm').format(booking.startTime)} - ${DateFormat('HH:mm').format(booking.endTime)}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Text(
                        'Total Biaya: Rp ${booking.totalCost.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                        'DP Dibayar: Rp ${booking.dpAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold)),
                    Text(
                        'Metode Pembayaran: ${booking.paymentMethod == PaymentMethod.qris ? 'QRIS' : 'Cash'}'),
                    Text(
                        'Status Saat Ini: ${_getStatusText(bookingProvider.bookings.firstWhere((b) => b.id == booking.id).status)}', // Get latest status from provider
                        style: TextStyle(
                            color: _getStatusColor(bookingProvider.bookings
                                .firstWhere((b) => b.id == booking.id)
                                .status),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: adminNotesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Admin (opsional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Opsi perubahan status booking
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ubah Status Booking:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: BookingStatus.values.map((status) {
                            final currentBookingStatus = bookingProvider
                                .bookings
                                .firstWhere((b) => b.id == booking.id)
                                .status;
                            return ElevatedButton(
                              onPressed: currentBookingStatus == status
                                  ? null
                                  : () async {
                                      try {
                                        await bookingProvider
                                            .updateBookingStatus(
                                                booking.id, status,
                                                adminNotes:
                                                    adminNotesController.text);
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Status booking berhasil diubah menjadi ${_getStatusText(status)}.')),
                                        );
                                        setDialogState(
                                            () {}); // Update dialog UI
                                        Navigator.of(context)
                                            .pop(); // Close dialog after update
                                      } catch (e) {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Gagal mengubah status: $e')),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getStatusColor(status),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(_getStatusText(status)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    // Filter booking berdasarkan selectedFilter
    final filteredBookings = bookingProvider.bookings.where((booking) {
      if (_selectedFilter == 'Semua') {
        return true;
      } else if (_selectedFilter == 'Menunggu DP') {
        return booking.status == BookingStatus.pendingPaymentDP;
      } else if (_selectedFilter == 'DP Dibayar') {
        return booking.status == BookingStatus.dpPaid;
      } else if (_selectedFilter == 'Dikonfirmasi') {
        return booking.status == BookingStatus.confirmed;
      } else if (_selectedFilter == 'Dibatalkan') {
        return booking.status == BookingStatus.cancelled ||
            booking.status == BookingStatus.rejectedByAdmin;
      }
      return false;
    }).toList();

    // Urutkan booking dari yang terbaru
    filteredBookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Manajemen Booking'),
      ),
      body: bookingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Filter Status Booking',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.filter_list),
                    ),
                    value: _selectedFilter,
                    items: const [
                      DropdownMenuItem(
                          value: 'Semua', child: Text('Semua Booking')),
                      DropdownMenuItem(
                          value: 'Menunggu DP', child: Text('Menunggu DP')),
                      DropdownMenuItem(
                          value: 'DP Dibayar', child: Text('DP Dibayar')),
                      DropdownMenuItem(
                          value: 'Dikonfirmasi', child: Text('Dikonfirmasi')),
                      DropdownMenuItem(
                          value: 'Dibatalkan',
                          child: Text('Dibatalkan/Ditolak')),
                    ],
                    onChanged: (newValue) {
                      setState(() {
                        _selectedFilter = newValue!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: filteredBookings.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada booking dengan status "$_selectedFilter".',
                            style: const TextStyle(
                                fontSize: 16, color: AppColors.lightTextColor),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: filteredBookings.length,
                          itemBuilder: (context, index) {
                            final booking = filteredBookings[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              elevation: 4,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Icon(
                                  Icons.calendar_today,
                                  color: _getStatusColor(booking.status),
                                ),
                                title: Text(
                                  '${booking.fieldName} - ${DateFormat('dd MMM yyyy').format(booking.bookingDate)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('User: ${booking.userName}'),
                                    Text(
                                        'Waktu: ${DateFormat('HH:mm').format(booking.startTime)} - ${DateFormat('HH:mm').format(booking.endTime)}'),
                                    Text(
                                        'Status: ${_getStatusText(booking.status)}',
                                        style: TextStyle(
                                            color:
                                                _getStatusColor(booking.status),
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.info_outline,
                                      color: AppColors.primaryColor),
                                  onPressed: () =>
                                      _showBookingDetailDialog(booking),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
