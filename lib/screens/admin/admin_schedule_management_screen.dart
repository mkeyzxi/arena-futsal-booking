// lib/screens/admin/admin_schedule_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:futsal_booking_app/providers/booking_provider.dart';
import 'package:futsal_booking_app/providers/field_provider.dart';
import 'package:futsal_booking_app/models/field_model.dart';
import 'package:futsal_booking_app/utils/app_colors.dart';

class AdminScheduleManagementScreen extends StatefulWidget {
  const AdminScheduleManagementScreen({super.key});

  @override
  State<AdminScheduleManagementScreen> createState() =>
      _AdminScheduleManagementScreenState();
}

class _AdminScheduleManagementScreenState
    extends State<AdminScheduleManagementScreen> {
  DateTime _selectedDate = DateTime.now();
  Field? _selectedField;

  @override
  void initState() {
    super.initState();
    // Memuat ulang jadwal setiap kali layar diakses
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchScheduleSlots();
      // Pastikan field provider juga sudah memuat fields
      Provider.of<FieldProvider>(context, listen: false).fetchFields();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now()
          .subtract(const Duration(days: 7)), // 7 hari ke belakang
      lastDate:
          DateTime.now().add(const Duration(days: 365)), // 1 tahun ke depan
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
      });
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final fieldProvider = Provider.of<FieldProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);

    // Filter jadwal berdasarkan tanggal dan lapangan yang dipilih
    final filteredSchedule = bookingProvider.scheduleSlots.where((slot) {
      return slot.startTime.year == _selectedDate.year &&
          slot.startTime.month == _selectedDate.month &&
          slot.startTime.day == _selectedDate.day &&
          (_selectedField == null || slot.fieldId == _selectedField!.id);
    }).toList();

    // Sort by field name and start time
    filteredSchedule.sort((a, b) {
      // Find field names from fieldProvider for sorting
      final fieldNameA = fieldProvider.fields
          .firstWhere(
            (f) => f.id == a.fieldId,
            orElse: () => Field(
                id: a.fieldId,
                name: 'Unknown Field',
                surfaceType: '',
                pricePerHour: 0.0),
          )
          .name;
      final fieldNameB = fieldProvider.fields
          .firstWhere(
            (f) => f.id == b.fieldId,
            orElse: () => Field(
                id: b.fieldId,
                name: 'Unknown Field',
                surfaceType: '',
                pricePerHour: 0.0),
          )
          .name;

      int fieldCompare = fieldNameA.compareTo(fieldNameB);
      if (fieldCompare != 0) return fieldCompare;
      return a.startTime.compareTo(b.startTime);
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Manajemen Jadwal'),
      ),
      body: bookingProvider.isLoading || fieldProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Pilih Tanggal'),
                        subtitle: Text(
                          DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                              .format(_selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        tileColor: AppColors.cardColor,
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<Field>(
                        decoration: const InputDecoration(
                          labelText: 'Pilih Lapangan',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.sports_soccer),
                        ),
                        value: _selectedField,
                        hint: const Text('Semua Lapangan'),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Semua Lapangan'),
                          ),
                          ...fieldProvider.fields
                              .map((field) => DropdownMenuItem(
                                    value: field,
                                    child: Text(field.name),
                                  ))
                              .toList(),
                        ],
                        onChanged: (Field? newValue) {
                          setState(() {
                            _selectedField = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredSchedule.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada jadwal tersedia untuk tanggal ini ${_selectedField == null ? 'untuk semua lapangan' : 'untuk ${_selectedField!.name}'}.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16, color: AppColors.lightTextColor),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: filteredSchedule.length,
                          itemBuilder: (context, index) {
                            final slot = filteredSchedule[index];
                            final field = fieldProvider.fields.firstWhere(
                              (f) => f.id == slot.fieldId,
                              orElse: () => Field(
                                  id: slot.fieldId,
                                  name: 'Unknown Field',
                                  surfaceType: '',
                                  pricePerHour: 0.0),
                            );
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              elevation: 4,
                              color: slot.isBooked
                                  ? AppColors.textFieldFillColor
                                  : AppColors
                                      .cardColor, // Warna abu jika booked
                              child: ListTile(
                                leading: Icon(
                                  slot.isBooked
                                      ? Icons.lock
                                      : Icons.check_circle_outline,
                                  color: slot.isBooked
                                      ? AppColors.errorColor
                                      : AppColors.successColor,
                                ),
                                title: Text(
                                  '${field.name} - ${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: slot.isBooked
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: slot.isBooked
                                        ? AppColors.lightTextColor
                                        : AppColors.textColor,
                                  ),
                                ),
                                subtitle: Text(
                                  slot.isBooked
                                      ? 'Status: Dibooking (ID Booking: ${slot.bookingId ?? 'N/A'})'
                                      : 'Status: Tersedia',
                                  style: TextStyle(
                                    color: slot.isBooked
                                        ? AppColors.errorColor
                                        : AppColors.successColor,
                                  ),
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
