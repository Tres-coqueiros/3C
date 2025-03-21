import 'dart:convert';

import 'package:http/http.dart' as http;

class ExternoRepository {
  Future<Map<String, dynamic>> getDolar() async {
    try {
      final response = await http.get(
        Uri.parse('https://economia.awesomeapi.com.br/json/last/USD-BRL'),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['USDBRL'];
      } else {
        throw Exception(
            'Failed to load dolar rate: Status code ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching dolar rate: $error');
      throw Exception('Error: $error');
    }
  }

  Future<List<dynamic>> getFeriados() async {
    final response = await http
        .get(Uri.parse('https://brasilapi.com.br/api/feriados/v1/2025'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Falha ao carregar feriados: Status code ${response.statusCode}');
    }
  }
}
