// lib/providers/field_provider.dart
import 'package:flutter/material.dart';
import 'package:futsal_booking_app/models/field_model.dart';

class FieldProvider with ChangeNotifier {
  List<Field> _fields = [];
  bool _isLoading = false;

  List<Field> get fields => _fields;
  bool get isLoading => _isLoading;

  FieldProvider() {
    // Memuat data lapangan saat provider diinisialisasi
    fetchFields();
  }

  Future<void> fetchFields() async {
    _isLoading = true;
    notifyListeners();

    // Simulasi pengambilan data dari database
    await Future.delayed(const Duration(seconds: 1));

    _fields = [
      Field(
        id: 'field_001',
        name: 'Lapangan 1',
        surfaceType: 'Rumput Sintetis',
        pricePerHour: 100000.0,
        description:
            'Lapangan futsal modern dengan rumput sintetis berkualitas tinggi, nyaman untuk bermain. Ukuran lapangan standar nasional dengan pencahayaan yang memadai.',
        imageUrl: 'assets/images/field1.jpeg',
        amenities: ['Toilet', 'Musholla', 'Parkir Luas', 'Wifi Gratis'],
      ),
      Field(
        id: 'field_002',
        name: 'Lapangan 2',
        surfaceType: 'Karpet Vinyl',
        pricePerHour: 85000.0,
        description:
            'Lapangan dengan karpet vinyl yang empuk dan tidak licin, cocok untuk latihan rutin dan pertandingan santai bersama teman. Tersedia juga bola dan rompi.',
        imageUrl: 'assets/images/field2.jpeg',
        amenities: ['Cafeteria', 'Ruang Ganti', 'Area Tunggu Nyaman'],
      ),
      Field(
        id: 'field_003',
        name: 'Lapangan 3 (Profesional)',
        surfaceType: 'Interlock', // Contoh jenis profesional
        pricePerHour: 150000.0,
        description:
            'Lapangan khusus untuk pemain profesional, dilengkapi fasilitas pendukung turnamen seperti tribun penonton, papan skor digital, dan ruang ganti premium. Kualitas rumput terbaik.',
        imageUrl: 'assets/images/field3.jpeg',
        amenities: [
          'Tribun Penonton',
          'Papan Skor Digital',
          'Ruang Ganti Premium',
          'Area Pemanasan'
        ],
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  // Metode untuk Admin (untuk ditambahkan di AdminFieldManagementScreen)
  Future<void> addField(Field field) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1)); // Simulasi API call
    _fields.add(field.copyWith(
        id: 'field_${_fields.length + 1}')); // Generate simple ID
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateField(Field updatedField) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    int index = _fields.indexWhere((field) => field.id == updatedField.id);
    if (index != -1) {
      _fields[index] = updatedField;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteField(String fieldId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _fields.removeWhere((field) => field.id == fieldId);
    _isLoading = false;
    notifyListeners();
  }
}
