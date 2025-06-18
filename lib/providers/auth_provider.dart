// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:futsal_booking_app/models/user_model.dart';
import 'package:futsal_booking_app/utils/app_constants.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isUser => _currentUser?.role == UserRole.user;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulasi proses login
      await Future.delayed(const Duration(seconds: 2));

      if (email == AppConstants.adminEmail &&
          password == AppConstants.adminPassword) {
        _currentUser = User(
            id: 'admin_id_123',
            email: email,
            name: 'Admin Futsal',
            role: UserRole.admin);
      } else {
        // Untuk user, kita bisa cek dari daftar user dummy atau dari backend (Firebase/API)
        // Contoh sederhana:
        if (password == 'user123') {
          // Contoh password statis untuk semua user dummy
          _currentUser = User(
              id: 'user_id_${email.hashCode}',
              email: email,
              name: email.split('@').first,
              role: UserRole.user);
        } else {
          throw Exception('Email atau password salah!');
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow; // Lempar kembali error agar bisa ditangani di UI
    }
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulasi proses registrasi
      await Future.delayed(const Duration(seconds: 2));

      // Di sini Anda akan mengintegrasikan dengan Firebase Auth atau backend Anda
      // Untuk tujuan demo, kita asumsikan registrasi berhasil dan user langsung dibuat
      _currentUser = User(
          id: 'new_user_id_${email.hashCode}',
          email: email,
          name: name,
          role: UserRole.user);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
