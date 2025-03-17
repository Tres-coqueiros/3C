import 'package:flutter/material.dart';
import 'package:senior/data/core/utils/app_utils.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:senior/data/views/widgets/components/button_components.dart';

class DetalhesSolicitacaoPage extends StatefulWidget {
  final Map<String, dynamic> solicitacao;

  DetalhesSolicitacaoPage({
    Key? key,
    required this.solicitacao,
  }) : super(key: key);

  @override
  State<DetalhesSolicitacaoPage> createState() =>
      _DetalhesSolicitacaoPageState();
}

class _DetalhesSolicitacaoPageState extends State<DetalhesSolicitacaoPage> {
  List<Map<String, dynamic>> get _itens =>
      (widget.solicitacao["itens"] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();

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
    final solicitacao = widget.solicitacao;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow("Nº Solicitação", solicitacao["id"].toString()),
        _buildInfoRow("Usuário", solicitacao["usuario"]),
        _buildInfoRow("Data da Solicitação",
            converterDataEHoras(solicitacao["data_solicitacao"])),
        _buildInfoRow("Status", solicitacao["status"]),
        _buildInfoRow(
            "Total", "R\$ ${solicitacao["total"].toStringAsFixed(2)}"),
        if (solicitacao["observacao"] != null)
          _buildInfoRow("Observação", solicitacao["observacao"]),
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
          itemCount: _itens.length,
          itemBuilder: (context, index) {
            final item = _itens[index];
            return _buildItemCard(item);
          },
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
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
            Text(
              item["material"],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),

            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildInfoColumn("Local", item["local"], 16),
                _buildInfoColumn("Grupo", item["grupo"], 16),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn(
                    "Quantidade", item["quantidade"].toString(), 18),
                _buildInfoColumn(
                  "Preço Unitário",
                  "R\$ ${item["preco_unitario"].toStringAsFixed(2)}",
                  18,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Subtotal destacado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColorsComponents.primary,
              ),
              child: Center(
                child: Text(
                  "Subtotal: R\$ ${item["subtotal"].toStringAsFixed(2)}",
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
            onPressed: () {},
            text: 'Aprovar',
            textColor: AppColorsComponents.background,
            backgroundColor: AppColorsComponents.primary,
            fontSize: 12,
            padding: EdgeInsets.symmetric(horizontal: 37, vertical: 12),
            textAlign: Alignment.bottomLeft),
        ButtonComponents(
            onPressed: () {},
            text: 'Reprovar',
            textColor: AppColorsComponents.background,
            backgroundColor: AppColorsComponents.error,
            fontSize: 12,
            padding: EdgeInsets.symmetric(horizontal: 37, vertical: 12),
            textAlign: Alignment.bottomRight),
      ],
    );
  }
}
