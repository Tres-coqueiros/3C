// detalhes_solicitacao_page.dart

import 'package:flutter/material.dart';
import 'package:senior/data/core/utils/app_utils.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';

class DetalhesSolicitacaoPage extends StatefulWidget {
  final Map<String, dynamic> solicitacao;
  final String gestorName;
  final int gestorMatricula;

  const DetalhesSolicitacaoPage({
    Key? key,
    required this.solicitacao,
    this.gestorName = '',
    this.gestorMatricula = 0,
  }) : super(key: key);

  @override
  State<DetalhesSolicitacaoPage> createState() =>
      _DetalhesSolicitacaoPageState();
}

class _DetalhesSolicitacaoPageState extends State<DetalhesSolicitacaoPage> {
  late List<Map<String, dynamic>> _localItens;
  late DateTime requestDate;

  late String _statusSolicitacao;
  late bool _isEditable;

  // Controlador para a observação da solicitação
  late TextEditingController _observacaoCtrl;

  @override
  void initState() {
    super.initState();

    // Converte a data da solicitação; se inválido, usa DateTime.now()
    requestDate =
        DateTime.tryParse(widget.solicitacao["data_solicitacao"] ?? "") ??
            DateTime.now();

    // Itens da solicitação
    final itens = widget.solicitacao["itens"];
    if (itens is List) {
      _localItens =
          itens.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } else {
      _localItens = [];
    }

    // Define status e verifica se pode editar
    _statusSolicitacao = widget.solicitacao["status"]?.toString() ?? "";
    _isEditable = _statusSolicitacao.toLowerCase().contains("edição");

    // Observação
    _observacaoCtrl = TextEditingController(
      text: widget.solicitacao["observacao"]?.toString() ?? "",
    );
  }

  @override
  void dispose() {
    _observacaoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sem AppBar (como solicitado)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSolicitacao(),
            const Divider(),
            _buildListaItens(),
            const SizedBox(height: 16),
            _buildBotoesAcao(), // Botões de Aprovar e Reprovar
          ],
        ),
      ),
    );
  }

  // Exemplo de método para salvar as alterações
  void _salvarEdicao() {
    widget.solicitacao["observacao"] = _observacaoCtrl.text;
    // Aqui você pode enviar _localItens atualizado ao servidor, etc.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Alterações salvas!")),
    );
  }

  // Exemplo de método para Aprovar
  void _aprovar() {
    // Lógica de aprovação
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Solicitação Aprovada!")),
    );
  }

  // Exemplo de método para Reprovar
  void _reprovar() {
    // Lógica de reprovação
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Solicitação Reprovada!")),
    );
  }

  Widget _buildBotoesAcao() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _aprovar,
          child: const Text("Aprovar"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _reprovar,
          child: const Text("Reprovar"),
        ),
      ],
    );
  }

  Widget _buildInfoSolicitacao() {
    final s = widget.solicitacao;
    final id = s["id"]?.toString() ?? "";
    final usuario = s["usuario"]?.toString() ?? "";
    final dataSol = s["data_solicitacao"]?.toString() ?? "";
    final totalVal = s["total"];
    double totalDouble = 0;
    if (totalVal != null) {
      if (totalVal is double) {
        totalDouble = totalVal;
      } else {
        totalDouble = double.tryParse(totalVal.toString()) ?? 0;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow("Nº Solicitação", id),
        _buildInfoRow("Usuário", usuario),
        _buildInfoRow("Data da Solicitação", converterDataEHoras(dataSol)),
        _buildInfoRow("Status", _statusSolicitacao),
        _buildInfoRow("Total", "R\$ ${totalDouble.toStringAsFixed(2)}"),
        _buildInfoRow(
          "Gestor",
          "${widget.gestorName} (${widget.gestorMatricula})",
        ),
        const SizedBox(height: 8),
        Text(
          "Observação:",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        _isEditable
            ? Container(
                // Define uma altura fixa para impedir expansão ao dar Enter
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  controller: _observacaoCtrl,
                  maxLines: null,
                  expands: true, // Permite rolagem interna em vez de expandir
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    border: InputBorder.none, // Usamos o border externo
                    hintText: "Digite uma observação...",
                  ),
                ),
              )
            : Text(
                _observacaoCtrl.text,
                style: const TextStyle(fontSize: 14),
              ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaItens() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Itens da Solicitação",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Envolve a ListView em um Container (ou SizedBox) com altura limitada
        Container(
          height: 300, // Exemplo: altura para exibir ~2 itens e rolar o resto
          child: ListView.builder(
            itemCount: _localItens.length,
            itemBuilder: (context, index) => _buildItemCard(_localItens[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final qtdCtrl = TextEditingController(
      text: item["quantidade"]?.toString() ?? "0",
    );

    void _atualizarQuantidade() {
      if (!_isEditable) return;
      final newQtd = double.tryParse(qtdCtrl.text) ?? 0;
      setState(() {
        item["quantidade"] = newQtd;
        final preco = item["preco_unitario"] as double?;
        if (preco != null) {
          item["subtotal"] = newQtd * preco;
        }
      });
    }

    final dataLimiteStr = item["data_limite"] as String?;
    final nivelEspera = item["nivel_espera"];
    Color dotColor = Colors.grey;
    String urgencia = "Indefinido";

    // Lógica de cor e texto para urgência
    if (nivelEspera != null && nivelEspera.isNotEmpty) {
      if (nivelEspera.toUpperCase() == "EMERGENCIAL") {
        dotColor = Colors.red;
        urgencia = "Emergente";
      } else if (nivelEspera.toUpperCase() == "URGENTE") {
        dotColor = const Color.fromARGB(255, 202, 189, 70);
        urgencia = "Urgente";
      } else if (nivelEspera.toUpperCase() == "NORMAL") {
        dotColor = Colors.green;
        urgencia = "Normal";
      }
    } else if (dataLimiteStr != null) {
      final deadline = DateTime.tryParse(dataLimiteStr) ?? DateTime.now();
      final diffDays = deadline.difference(requestDate).inDays;
      if (diffDays <= 0) {
        dotColor = Colors.red;
        urgencia = "Emergente";
      } else if (diffDays >= 1 && diffDays <= 3) {
        dotColor = Colors.yellow;
        urgencia = "Urgente";
      } else if (diffDays > 3) {
        dotColor = Colors.green;
        urgencia = "Normal";
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Faixa no topo (height maior) com texto de urgência centralizado
          Container(
            height: 30,
            decoration: BoxDecoration(
              color: dotColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            // Centraliza o texto da urgência em branco
            child: Center(
              child: Text(
                urgencia,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Conteúdo do item
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome do material e botão remover (se editável)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        item["material"] ?? 'Material não informado',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (_isEditable)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          setState(() => _localItens.remove(item));
                        },
                      ),
                  ],
                ),
                const Divider(),
                // Local e Grupo um abaixo do outro, e Data Limite (se houver)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoColumn("Local", item["local"] ?? '-', 14),
                    _buildInfoColumn("Grupo", item["grupo"] ?? '-', 14),
                    if (dataLimiteStr != null)
                      _buildInfoColumn(
                        "Data Limite",
                        converterDataEHoras(dataLimiteStr),
                        14,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                // Linha com Quantidade (editável) e Preço Unitário
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Quantidade",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: qtdCtrl,
                            keyboardType: TextInputType.number,
                            readOnly: !_isEditable,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                            ),
                            onEditingComplete: _atualizarQuantidade,
                          ),
                        ),
                      ],
                    ),
                    _buildInfoColumn(
                      "Preço Unitário",
                      "R\$ ${item["preco_unitario"]?.toStringAsFixed(2) ?? '0.00'}",
                      14,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Exibe o subtotal
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColorsComponents.primary,
                  ),
                  child: Center(
                    child: Text(
                      "Subtotal: R\$ ${item["subtotal"]?.toStringAsFixed(2) ?? '0.00'}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColorsComponents.hashours,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4), // pequeno espaçamento
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
