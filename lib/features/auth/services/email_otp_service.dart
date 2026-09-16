import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

class EmailOtpService {
  static const String _serviceId = 'service_vz51fxg';
  static const String _templateId = 'template_o5q172p';
  static const String _publicKey = 'w4FU0SHsQU6WYPkPn';

  static String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  static Future<bool> sendOtp({
    required String userEmail,
    required String firstName,
    required String lastName,
    required String otpCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'to_email': userEmail,
            'first_name': firstName,
            'last_name': lastName,
            'user_name': '$firstName $lastName'.trim(),
            'otp_code': otpCode,
          },
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
