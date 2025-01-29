import 'package:senior/data/dio/api_client.dart';

class PostAuth {
  Future<bool> AuthUser(String Matricula) async {
    try {
      final response =
          await dio.post('postLogin', data: {'matricula': Matricula});

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }
}
