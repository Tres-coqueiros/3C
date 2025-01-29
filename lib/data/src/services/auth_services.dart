import 'package:senior/data/dio/api_client.dart';

class PostAuth {
  Future<bool> authuser(String matricula) async {
    print(matricula);
    try {
      final response =
          await dio.post('postLogin', data: {'matricula': matricula});

      print(' RESPONSE: $response');

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
