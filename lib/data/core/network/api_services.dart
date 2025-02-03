import 'package:senior/data/core/network/api_client.dart';

class PostServices {}

class GetServices {
  Future<List<Map<String, dynamic>>> getCollaborators() async {
    try {
      final response = await dio.get('getColaboradorGestor');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
            response.data['getColaboradorGestor']);
      } else {
        return [];
      }
    } catch (error) {
      print('Erro ao fazer a consulta na API: $error');
      return [];
    }
  }

  Future<Map<String, dynamic>> getLogin() async {
    try {
      final response = await dio.get('getLogin');

      if (response.statusCode == 200) {
        print('Resultado da API: ${response.data}');
        return response.data;
      } else {
        return {};
      }
    } catch (error) {
      print('Erro ao fazer a consulta na API: $error');
      return {};
    }
  }
}
