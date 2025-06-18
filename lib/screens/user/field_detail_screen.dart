// lib/screens/user/field_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:futsal_booking_app/models/field_model.dart';
import 'package:futsal_booking_app/utils/app_colors.dart';
import 'package:futsal_booking_app/screens/user/booking_form_screen.dart';

class FieldDetailScreen extends StatelessWidget {
  final Field field;

  const FieldDetailScreen({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(field.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: Image.asset(
                field.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/field_placeholder.png',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tipe Permukaan: ${field.surfaceType}',
                    style: const TextStyle(
                        fontSize: 18, color: AppColors.lightTextColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Harga Sewa: Rp ${field.pricePerHour.toStringAsFixed(0)} / jam',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    field.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  if (field.amenities.isNotEmpty) ...[
                    const Text(
                      'Fasilitas:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: field.amenities
                          .map((amenity) => Chip(
                                label: Text(amenity),
                                backgroundColor:
                                    AppColors.accentColor.withOpacity(0.2),
                                labelStyle:
                                    const TextStyle(color: AppColors.textColor),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                BookingFormScreen(field: field),
                          ),
                        );
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10.0),
                        child: Text('Pesan Lapangan Ini',
                            style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
