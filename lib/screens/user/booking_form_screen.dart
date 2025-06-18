// lib/screens/user/booking_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:futsal_booking_app/models/field_model.dart';
import 'package:futsal_booking_app/models/booking_model.dart';
import 'package:futsal_booking_app/models/user_model.dart';
import 'package:futsal_booking_app/providers/booking_provider.dart';
import 'package:futsal_booking_app/providers/auth_provider.dart';
import 'package:futsal_booking_app/utils/app_colors.dart';

class BookingFormScreen extends StatefulWidget {
  final Field field;

  const BookingFormScreen({super.key, required this.field});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  DateTime? _selectedDate;
  int _selectedHour = -1;
  int _durationHours = 1; // Default 1 jam
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash; // Default cash

  List<DateTime> _availableTimeSlots = []; // Slot waktu yang tersedia
  double _totalCost = 0.0;
  double _dpAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _updateTotalCostAndDP();
    // Mengatur locale untuk intl agar format tanggal dalam Bahasa Indonesia
    Intl.defaultLocale = 'id_ID';
  }

  void _updateTotalCostAndDP() {
    setState(() {
      _totalCost = widget.field.pricePerHour * _durationHours;
      _dpAmount = _totalCost * 0.5; // DP 50%
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
          const Duration(days: 30)), // Bisa booking hingga 30 hari ke depan
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryColor,
            colorScheme:
                const ColorScheme.light(primary: AppColors.primaryColor),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedHour = -1; // Reset selected hour when date changes
        _fetchAvailableTimeSlots();
      });
    }
  }

  void _fetchAvailableTimeSlots() {
    if (_selectedDate == null) return;
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);

    // Filter slots by selected field and date
    final List<DateTime> newAvailableSlots = [];
    final allSlotsForDate = bookingProvider.scheduleSlots.where((slot) {
      return slot.fieldId == widget.field.id &&
          slot.startTime.year == _selectedDate!.year &&
          slot.startTime.month == _selectedDate!.month &&
          slot.startTime.day == _selectedDate!.day;
    }).toList();

    // Group by hour and check availability for desired duration
    for (int i = 9; i <= 22 - _durationHours; i++) {
      // Check hours, ensuring end time doesn't exceed 22:00
      final startHour = i;
      final endHour = i + _durationHours;

      // Check if all slots for the duration are available
      bool allSlotsAvailable = true;
      for (int h = startHour; h < endHour; h++) {
        final slotFound = allSlotsForDate.firstWhere(
          (s) => s.startTime.hour == h,
          orElse: () => null!, // Indicate slot not found
        );
        if (slotFound == null || slotFound.isBooked) {
          allSlotsAvailable = false;
          break;
        }
      }

      if (allSlotsAvailable) {
        newAvailableSlots.add(DateTime(_selectedDate!.year,
            _selectedDate!.month, _selectedDate!.day, startHour, 0));
      }
    }
    setState(() {
      _availableTimeSlots = newAvailableSlots;
    }); // Rebuild to show updated time slots
  }

  void _bookField() async {
    if (_selectedDate == null || _selectedHour == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih tanggal dan waktu booking.')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Anda harus login untuk melakukan booking.')),
      );
      return;
    }

    final User currentUser = authProvider.currentUser!;
    final DateTime bookingStartTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedHour,
      0,
    );
    final DateTime bookingEndTime =
        bookingStartTime.add(Duration(hours: _durationHours));

    // Basic client-side validation for slot availability (server-side is crucial)
    final bool isSlotAvailable = _availableTimeSlots.any((slotTime) =>
        slotTime.hour == _selectedHour &&
        slotTime.day == _selectedDate!.day &&
        slotTime.month == _selectedDate!.month &&
        slotTime.year == _selectedDate!.year);

    if (!isSlotAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Slot waktu yang Anda pilih sudah tidak tersedia atau tidak valid. Silakan pilih slot lain.')),
      );
      return;
    }

    final newBooking = Booking(
      id: '', // ID akan di-generate oleh provider
      userId: currentUser.id,
      userName: currentUser.name,
      fieldId: widget.field.id,
      fieldName: widget.field.name,
      bookingDate: _selectedDate!,
      startTime: bookingStartTime,
      endTime: bookingEndTime,
      totalCost: _totalCost,
      dpAmount: _dpAmount,
      paymentMethod: _selectedPaymentMethod,
      status: _selectedPaymentMethod == PaymentMethod.cash
          ? BookingStatus.confirmed
          : BookingStatus.pendingPaymentDP,
    );

    try {
      await bookingProvider.createBooking(newBooking);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Booking berhasil! Harap selesaikan pembayaran DP sebesar Rp ${_dpAmount.toStringAsFixed(0)}.'),
          backgroundColor: AppColors.successColor,
        ),
      );
      Navigator.of(context).pop(); // Kembali ke halaman detail lapangan
      Navigator.of(context).pushReplacementNamed(
          '/user_booking_history'); // Atau langsung ke riwayat booking
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal melakukan booking: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    // Dipastikan controller dibersihkan jika ada
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Booking ${widget.field.name}'),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Booking untuk ${widget.field.name}',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor),
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: const Text('Tanggal Booking'),
                  subtitle: Text(
                    _selectedDate == null
                        ? 'Pilih tanggal'
                        : DateFormat('EEEE, dd MMMM yyyy')
                            .format(_selectedDate!),
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  tileColor: AppColors.cardColor,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Durasi Sewa:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<int>(
                        title: const Text('1 Jam'),
                        value: 1,
                        groupValue: _durationHours,
                        onChanged: (value) {
                          setState(() {
                            _durationHours = value!;
                            _updateTotalCostAndDP();
                            _selectedHour = -1; // Reset jam saat durasi berubah
                            _fetchAvailableTimeSlots(); // Ambil slot baru
                          });
                        },
                        activeColor: AppColors.primaryColor,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<int>(
                        title: const Text('2 Jam'),
                        value: 2,
                        groupValue: _durationHours,
                        onChanged: (value) {
                          setState(() {
                            _durationHours = value!;
                            _updateTotalCostAndDP();
                            _selectedHour = -1; // Reset jam saat durasi berubah
                            _fetchAvailableTimeSlots(); // Ambil slot baru
                          });
                        },
                        activeColor: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pilih Jam Mulai:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                _selectedDate == null
                    ? const Text(
                        'Pilih tanggal terlebih dahulu untuk melihat jam tersedia.',
                        style: TextStyle(color: AppColors.lightTextColor))
                    : (_availableTimeSlots.isEmpty
                        ? const Text(
                            'Tidak ada jam tersedia untuk tanggal dan durasi ini.',
                            style: TextStyle(color: AppColors.lightTextColor))
                        : Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _availableTimeSlots.map((time) {
                              final hour = time.hour;
                              return ChoiceChip(
                                label: Text(
                                  '${hour.toString().padLeft(2, '0')}:00 - ${(hour + _durationHours).toString().padLeft(2, '0')}:00',
                                  style: TextStyle(
                                    color: _selectedHour == hour
                                        ? Colors.white
                                        : AppColors.textColor,
                                  ),
                                ),
                                selected: _selectedHour == hour,
                                selectedColor: AppColors.primaryColor,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedHour = selected ? hour : -1;
                                  });
                                },
                                backgroundColor: AppColors.cardColor,
                                elevation: 2,
                                pressElevation: 5,
                              );
                            }).toList(),
                          )),
                const SizedBox(height: 30),
                const Text(
                  'Metode Pembayaran DP:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<PaymentMethod>(
                        title: const Text('QRIS'),
                        value: PaymentMethod.qris,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                        activeColor: AppColors.primaryColor,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<PaymentMethod>(
                        title: const Text('Cash'),
                        value: PaymentMethod.cash,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                        activeColor: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Pembayaran',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor),
                      ),
                      const Divider(height: 20, thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Harga per Jam:',
                              style: TextStyle(fontSize: 16)),
                          Text(
                              'Rp ${widget.field.pricePerHour.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Durasi Sewa:',
                              style: TextStyle(fontSize: 16)),
                          Text('$_durationHours Jam',
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Biaya Sewa:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Rp ${_totalCost.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('DP (50%):',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor)),
                          Text('Rp ${_dpAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: bookingProvider.isLoading ? null : _bookField,
                    child: bookingProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Konfirmasi Booking',
                            style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
