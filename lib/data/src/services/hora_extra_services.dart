import 'package:senior/data/src/services/notification_services.dart';

class Colaborador {
  final String nome;
  final int horasExtras;

  Colaborador({required this.nome, required this.horasExtras});
}

class HoraExtraService {
  static final List<Colaborador> colaboradores = [
    Colaborador(nome: 'João Silva', horasExtras: 10),
    Colaborador(nome: 'Maria Oliveira', horasExtras: 15),
    Colaborador(nome: 'Pedro Souza', horasExtras: 8),
  ];

  static Future<void> checkForYesterdayHoraExtra() async {
    for (var colaborador in colaboradores) {
      if (colaborador.horasExtras > 5) {
        print('Hora extra detectada em ${colaborador.nome}!');
        await NotificationServices.showNotification(
          title: 'Hora Extra - ${colaborador.nome}',
          body:
              '${colaborador.nome} tem ${colaborador.horasExtras} horas extras!',
        );
      }
    }
  }
}
