class Ciclo {
  int Codigo;
  String Descricao;
  int Safra;
  int Cultura;

  Ciclo(
      {required this.Codigo,
      required this.Descricao,
      required this.Safra,
      required this.Cultura});
}

class Cultura {
  int Codigo;
  String Descricao;

  Cultura({required this.Codigo, required this.Descricao});
}

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

class Safra {
  int Codigo;
  String Descricao;

  Safra({required this.Codigo, required this.Descricao});
}

class Fazenda {
  int Codigo;
  String Descricao;
  int Sequencial;

  Fazenda(
      {required this.Codigo,
      required this.Descricao,
      required this.Sequencial});
}

class Talhoes {
  int Codigo;
  String Identificacao;
  int Fazenda;
  int Safra;

  Talhoes(
      {required this.Codigo,
      required this.Identificacao,
      required this.Fazenda,
      required this.Safra});
}
