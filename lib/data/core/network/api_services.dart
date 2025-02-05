import 'package:senior/data/core/network/api_client.dart';

class PostServices {
  Future<bool> postHours(data) async {
    try {
      final response = await dio.post('postHoras', data: {'data': data});
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print('Erro ao fazer a requisição na API: $error');
      return false;
    }
  }

  Future<bool> postSendEmail(data) async {
    try {
      final response = await dio.post('postSendEmail', data: {'data': data});
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print('Erro ao fazer a requisição na API: $error');
      return false;
    }
  }
}

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
