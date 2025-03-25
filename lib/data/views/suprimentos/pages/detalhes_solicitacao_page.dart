import 'package:flutter/material.dart';
import 'package:senior/data/core/utils/app_utils.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:senior/data/views/widgets/components/button_components.dart';

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
  List<Map<String, dynamic>> _localItens = [];
  late DateTime requestDate;

  @override
  void initState() {
    super.initState();
    requestDate = DateTime.tryParse(widget.solicitacao["data_solicitacao"]) ??
        DateTime.now();
    if (widget.solicitacao["itens"] != null) {
      _localItens = (widget.solicitacao["itens"] as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
  }

  void _showReprovarDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Reprovar Solicitação",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Você deseja devolver a solicitação para o solicitante ou excluir a solicitação?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Solicitação devolvida.")),
                );
              },
              child: const Text("Devolver", style: TextStyle(fontSize: 16)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Solicitação excluída.")),
                );
              },
              child: const Text("Excluir",
                  style: TextStyle(fontSize: 16, color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar", style: TextStyle(fontSize: 16)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildInfoSolicitacao(),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildListaItens(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildBotoesAcao(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSolicitacao() {
    final s = widget.solicitacao;

    // Em vez de acessar diretamente, vamos converter com segurança:
    final id = s["id"]?.toString() ?? "";
    final usuario = s["usuario"]?.toString() ?? "";
    final dataSol = s["data_solicitacao"]?.toString() ?? "";
    final status = s["status"]?.toString() ?? "";
    final totalVal = s["total"]; // Pode ser double, string ou null
    double totalDouble = 0;

    if (totalVal != null) {
      // Se for double, mantém; se for string, tenta converter; se não der certo, vira 0
      if (totalVal is double) {
        totalDouble = totalVal;
      } else {
        totalDouble = double.tryParse(totalVal.toString()) ?? 0;
      }
    }

    final observacao = s["observacao"]?.toString() ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow("Nº Solicitação", id),
        _buildInfoRow("Usuário", usuario),
        _buildInfoRow("Data da Solicitação", converterDataEHoras(dataSol)),
        _buildInfoRow("Status", status),
        _buildInfoRow("Total", "R\$ ${totalDouble.toStringAsFixed(2)}"),
        if (observacao.isNotEmpty) _buildInfoRow("Observação", observacao),
        // Aqui, se quiser exibir gestorName e gestorMatricula:
        _buildInfoRow(
            "Gestor", "${widget.gestorName} (${widget.gestorMatricula})"),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
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
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _localItens.length,
          itemBuilder: (context, index) => _buildItemCard(_localItens[index]),
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final qtdCtrl = TextEditingController(text: item["quantidade"].toString());
    void _atualizarQuantidade() {
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
    if (nivelEspera != null && nivelEspera.isNotEmpty) {
      if (nivelEspera.toUpperCase() == "EMERGENCIAL") {
        dotColor = Colors.red;
        urgencia = "Emergente";
      } else if (nivelEspera.toUpperCase() == "URGENTE") {
        dotColor = Colors.yellow;
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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  urgencia,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    item["material"] ?? 'Material não informado',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => setState(() => _localItens.remove(item)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildInfoColumn("Local", item["local"] ?? '-', 16),
                _buildInfoColumn("Grupo", item["grupo"] ?? '-', 16),
                if (dataLimiteStr != null)
                  _buildInfoColumn(
                    "Data Limite",
                    converterDataEHoras(dataLimiteStr),
                    16,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      ),
                      onEditingComplete: _atualizarQuantidade,
                    ),
                  ),
                ]),
                _buildInfoColumn(
                  "Preço Unitário",
                  "R\$ ${item["preco_unitario"]?.toStringAsFixed(2) ?? '0.00'}",
                  18,
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColorsComponents.hashours,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
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
    );
  }

  Widget _buildBotoesAcao() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ButtonComponents(
          textAlign: Alignment.center,
          onPressed: () {},
          text: 'Aprovar',
          textColor: AppColorsComponents.background,
          backgroundColor: AppColorsComponents.primary,
          fontSize: 12,
          padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 12),
        ),
        ButtonComponents(
          textAlign: Alignment.center,
          onPressed: _showReprovarDialog,
          text: 'Reprovar',
          textColor: AppColorsComponents.background,
          backgroundColor: AppColorsComponents.error,
          fontSize: 12,
          padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 12),
        ),
      ],
    );
  }
}
