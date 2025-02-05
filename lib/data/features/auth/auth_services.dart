import 'package:senior/data/core/network/api_client.dart';

class PostAuth {
  Future<bool> authuser(String matricula) async {
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

  Future<bool> authlogout() async {
    try {
      final response = await dio.post('postLogout');
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print('Erro ao fazer logout $error');
      return false;
    }
  }
}
