import 'package:senior/data/core/network/api_client.dart';

class PostAuth {
  Future<bool> authuser(String matricula) async {
    print(matricula);
    try {
      final response =
          await dio.post('postLogin', data: {'matricula': matricula});
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print('Erro ao fazer login $error');
      return false;
    }
  }
}

class GetAuth {
  Future<List<Map<String, dynamic>>> getColaboradorGestor() async {
    try {
      final response = await dio.get('getColaboradorGestor');
      print(' RESPONSE : $response.data');
      if (response.data != null) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        return [];
      }
    } catch (error) {
      print('Erro ao carregar dados do gestor $error');
      return [];
    }
  }
}
