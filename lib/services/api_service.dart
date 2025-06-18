import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:futsal_booking_app/utils/app_constants.dart'; // Nanti kita buat ini

class ApiService {
  // Ganti dengan URL backend Anda
  final String _baseUrl =
      AppConstants.BASE_API_URL; // Misalnya: 'http://192.168.1.5:3000/api'

  Future<String?> createMidtransTransaction({
    required String orderId,
    required double totalAmount,
    required String userName,
    required String userEmail,
    required String userPhone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/create-midtrans-transaction'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'orderId': orderId,
          'totalAmount': totalAmount,
          'userName': userName,
          'userEmail': userEmail,
          'userPhone': userPhone,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['snapToken'];
      } else {
        print('Failed to create Midtrans transaction: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating Midtrans transaction: $e');
      return null;
    }
  }

  // Jika ada API lain untuk verifikasi status atau lainnya
  // Future<Map<String, dynamic>?> checkPaymentStatus(String orderId) async {
  //   // ... implementasi untuk check status di backend Anda
  // }
}
