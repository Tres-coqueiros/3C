class Operacao {
  final int safraId;
  final String Safra;
  final int talhaoId;
  final String Talhao;
  final double area;
  final int cicloId;
  final String Cicloprod;
  final int culturaId;
  final String cultura;
  final int variedadeId;
  final String variedade;
  final int FazendaId;
  final String Fazenda;

  Operacao({
    required this.safraId,
    required this.Safra,
    required this.talhaoId,
    required this.Talhao,
    required this.area,
    required this.cicloId,
    required this.Cicloprod,
    required this.culturaId,
    required this.cultura,
    required this.variedadeId,
    required this.variedade,
    required this.FazendaId,
    required this.Fazenda,
  });
}

class MotivoParada {
  final String descricao;
  final DateTime inicio;
  final DateTime fim;

  MotivoParada({
    required this.descricao,
    required this.inicio,
    required this.fim,
  });

  Duration get duracao => fim.difference(inicio);
}

class Operador {
  int Codigo;
  String Nome;

  Operador({required this.Codigo, required this.Nome});
}

class Patrimonio {
  int bensId;
  String bens;
  String bensImple;
  String Unidade;

  Patrimonio(
      {required this.bensId,
      required this.bens,
      required this.bensImple,
      required this.Unidade});
}

class Servicos {
  int Codigo;
  String Servico;
  int Tipo;

  Servicos({required this.Codigo, required this.Servico, required this.Tipo});
}

class LogEntry {
  final int usuario;
  final String atividade;
  final DateTime dataHora;
  final String descricao;

  LogEntry({
    required this.usuario,
    required this.atividade,
    required this.dataHora,
    required this.descricao,
  });
}

class Gestor {
  final String gestor;

  Gestor({required this.gestor});
}
