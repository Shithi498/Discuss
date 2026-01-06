import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/employee_model.dart';

class EmployeeRepository {
  final String baseUrl;
  final String sessionCookie;

  EmployeeRepository({
    required this.baseUrl,
    required this.sessionCookie,
  });

  Future<EmployeeResponse> fetchEmployeeProfile() async {
    final url = Uri.parse('$baseUrl/api/my/employee');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': sessionCookie,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return EmployeeResponse.fromJson(data);
    } else {
      throw Exception('Failed to load employee data');
    }
  }
}
