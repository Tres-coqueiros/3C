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

  Future<Map<String, dynamic>> postBDOperacao(data) async {
    try {
      final response =
          await dioAgrimanager.post('postBDOperacao', data: {'data': data});
      print(response);
      if (response.statusCode == 200) {
        return {'success': true, 'status': response.data['status']};
      } else {
        return {
          'success': false,
          'message': '${response.statusMessage}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Falha na requisição',
      };
    }
  }

  Future<Map<String, dynamic>> postBDOMotivo(novoMotivo) async {
    try {
      final response = await dioAgrimanager
          .post('postBDOmotivo', data: {'data': novoMotivo});
      if (response.statusCode == 200) {
        return {'success': true, 'motivo': response.data['motivo']};
      } else {
        return {
          'success': false,
          'message': '${response.statusMessage}',
        };
      }
    } catch (error) {
      ErrorNotifier.showError(
          'Erro ao fazer a requisição na API: ${error.toString()}');
      return {
        'success': false,
        'message': 'Falha na requisição',
      };
    }
  }

  Future<bool> postBDOHorimetro(novoHorimetro) async {
    try {
      final response = await dioAgrimanager
          .post('postBDOHorimetro', data: {'data': novoHorimetro});
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      ErrorNotifier.showError(
          'Erro ao fazer a requisição na API: ${error.toString()}');
      print(error.toString());

      return false;
    }
  }

  Future<Map<String, dynamic>> postBDO(data) async {
    try {
      final response =
          await dioAgrimanager.post('postBDO', data: {'data': data});

      if (response.statusCode == 201) {
        return {
          'success': true,
          'id': response.data['id'],
        };
      } else {
        return {
          'success': false,
          'message': 'Falha na requisição: ${response.statusCode}',
        };
      }
    } catch (error) {
      ErrorNotifier.showError('Erro na requisição');
      return {
        'success': false,
        'message': 'Falha na requisição',
      };
    }
  }

  Future<bool> postSolicitacao(data) async {
    try {
      final response =
          await dioAgrimanager.post('postSolicitacao', data: {'data': data});
      if (response.statusCode == 201) {
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
      print('Erro ao carregar API: ${error.toString()}');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLogin() async {
    try {
      final response = await dioSenior.get('getLogin');

      print(response.data['getLogin']);

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

  Future<List<Map<String, dynamic>>> getOperacao() async {
    try {
      final response = await dioAgrimanager.get('getOperacao');
      if (response.data != null && response.data['getOperacao'] != null) {
        return List<Map<String, dynamic>>.from(response.data['getOperacao']);
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

  Future<List<Map<String, dynamic>>> getMaterialSolicitacao() async {
    try {
      final response = await dioAgrimanager.get('getMaterialSolicitacao');
      if (response.data != null &&
          response.data['getMaterialSolicitacao'] != null) {
        return List<Map<String, dynamic>>.from(
            response.data['getMaterialSolicitacao']);
      } else {
        ErrorNotifier.showError(
            'Erro ao fazer busca de Talhões: ${response.statusMessage}');
        return [];
      }
    } catch (error) {
      print('Erro ao fazer a consulta na API Materias: $error');
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

  Future<List<Map<String, dynamic>>> getMaquina() async {
    try {
      final response = await dioAgrimanager.get('getMaquina');
      if (response.data != null && response.data['getMaquina'] != null) {
        return List<Map<String, dynamic>>.from(response.data['getMaquina']);
      } else {
        ErrorNotifier.showError(
            'Erro ao fazer busca de operador: ${response.statusMessage}');
        return [];
      }
    } catch (error) {
      print('Erro ao fazer a consulta na API Maquinas: $error');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getServicos() async {
    try {
      final response = await dioAgrimanager.get('getServicos');
      if (response.data != null && response.data['getServicos'] != null) {
        return List<Map<String, dynamic>>.from(response.data['getServicos']);
      } else {
        ErrorNotifier.showError(
            'Erro ao fazer busca de operador: ${response.statusMessage}');
        return [];
      }
    } catch (error) {
      print('Erro ao fazer a consulta na API Maquinas: $error');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getBDO() async {
    try {
      final response = await dioAgrimanager.get('getBDO');
      if (response.data != null && response.data['getBDO'] != null) {
        return List<Map<String, dynamic>>.from(response.data['getBDO']);
      } else {
        ErrorNotifier.showError(
            'Erro ao fazer busca de BDO: ${response.statusMessage}');
        return [];
      }
    } catch (error) {
      print('Erro ao fazer a consulta na API BDO: $error');
      return [];
    }
  }
}

class UpdateServices {
  Future<bool> updateBDO(data) async {
    try {
      final response =
          await dioAgrimanager.put('updateBDO', data: {'data': data});
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
}
