import 'package:dio/dio.dart';

class ExternoRepository {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> getDolar() async {
    try {
      final response = await _dio.get(
        'https://economia.awesomeapi.com.br/json/last/USD-BRL',
      );

      if (response.statusCode == 200) {
        return response.data['USDBRL'];
      } else {
        throw Exception('Failed to load dolar rate');
      }
    } on DioException catch (error) {
      throw Exception('Dio error: $error');
    } catch (error) {
      throw Exception('Unexpected error: $error');
    }
  }
}
