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

class Operador {
  int Codigo;
  String Nome;

  Operador({required this.Codigo, required this.Nome});
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
