import 'package:senior/data/core/repository/client_repository.dart';
import 'package:senior/data/core/repository/exceptions_network.dart';

class PostServices {
  Future<bool> postHours(data) async {
    try {
      final response = await dioSenior.post('postHours', data: {'data': data});
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      ErrorNotifier.showError(
          'Erro ao fazer a requisição na API: ${error.toString()}');
      return false;
    }
  }

  Future<bool> postSendEmail(data) async {
    try {
      final response =
          await dioSenior.post('postSendEmail', data: {'data': data});
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
      final response = await dioSenior.get('getColaboradorGestor');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
            response.data['getColaboradorGestor']);
      } else {
        ErrorNotifier.showError(
            'Erro ao fazer busca de colaboradores: ${response.statusMessage}');
        return [];
      }
    } catch (error) {
      ErrorNotifier.showError('Erro ao carregar API: ${error.toString()}');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLogin() async {
    try {
      final response = await dioSenior.get('getLogin');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['getLogin']);
      } else {
        ErrorNotifier.showError(
            'Erro ao fazer busca de colaboradore: ${response.statusMessage}');
        return [];
      }
    } catch (error) {
      print('Erro ao fazer a consulta na API: $error');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCiclo() async {
    try {
      final response = await dioAgrimanager.get('getCiclo');

      if (response.data != null && response.data['getCiclo'] != null) {
        return List<Map<String, dynamic>>.from(response.data['getCiclo']);
      } else {
        ErrorNotifier.showError(
            'Erro ao fazer busca ciclo: ${response.statusMessage}');
        return [];
      }
    } catch (error) {
      print('Erro ao fazer a consulta na API: $error');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSafra() async {
    try {
      final response = await dioAgrimanager.get('getSafra');
      if (response.data != null && response.data['getSafra'] != null) {
        return List<Map<String, dynamic>>.from(response.data['getSafra']);
      } else {
        ErrorNotifier.showError(
            'Erro ao fazer busca de safra: ${response.statusMessage}');
        return [];
      }
    } catch (error) {
      print('Erro ao fazer a consulta na API Safra: $error');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTalhao() async {
    try {
      final response = await dioAgrimanager.get('getTalhao');
      if (response.data != null && response.data['getTalhao'] != null) {
        return List<Map<String, dynamic>>.from(response.data['getTalhao']);
      } else {
        ErrorNotifier.showError(
            'Erro ao fazer busca de Talhões: ${response.statusMessage}');
        return [];
      }
    } catch (error) {
      print('Erro ao fazer a consulta na API Talhões: $error');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCultura() async {
    try {
      final response = await dioAgrimanager.get('getCultura');
      if (response.data != null && response.data['getCultura'] != null) {
        return List<Map<String, dynamic>>.from(response.data['getCultura']);
      } else {
        ErrorNotifier.showError(
            'Erro ao fazer busca de Talhões: ${response.statusMessage}');
        return [];
      }
    } catch (error) {
      print('Erro ao fazer a consulta na API Talhões: $error');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getOperador() async {
    try {
      final response = await dioAgrimanager.get('getOperador');
      if (response.data != null && response.data['getOperador'] != null) {
        return List<Map<String, dynamic>>.from(response.data['getOperador']);
      } else {
        ErrorNotifier.showError(
            'Erro ao fazer busca de operador: ${response.statusMessage}');
        return [];
      }
    } catch (error) {
      print('Erro ao fazer a consulta na API Operador: $error');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getFazenda() async {
    try {
      final response = await dioAgrimanager.get('getFazenda');
      if (response.data != null && response.data['getFazenda'] != null) {
        return List<Map<String, dynamic>>.from(response.data['getFazenda']);
      } else {
        ErrorNotifier.showError(
            'Erro ao fazer busca de operador: ${response.statusMessage}');
        return [];
      }
    } catch (error) {
      print('Erro ao fazer a consulta na API Operador: $error');
      return [];
    }
  }
}
