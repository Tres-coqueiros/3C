import 'package:flutter/material.dart';
import 'package:senior/data/core/utils/app_utils.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:senior/data/views/widgets/components/button_components.dart';

class DetalhesSolicitacaoPage extends StatefulWidget {
  final Map<String, dynamic> solicitacao;

  const DetalhesSolicitacaoPage({
    Key? key,
    required this.solicitacao,
  }) : super(key: key);

  @override
  State<DetalhesSolicitacaoPage> createState() =>
      _DetalhesSolicitacaoPageState();
}

class _DetalhesSolicitacaoPageState extends State<DetalhesSolicitacaoPage> {
  /// Inicia como lista vazia para evitar 'LateInitializationError'
  List<Map<String, dynamic>> _localItens = [];

  @override
  void initState() {
    super.initState();
    // Copiamos a lista de itens da solicitação para _localItens
    if (widget.solicitacao["itens"] != null) {
      _localItens = (widget.solicitacao["itens"] as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informações principais da solicitação
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildInfoSolicitacao(),
          ),
          const Divider(),

          // Lista de itens
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildListaItens(),
            ),
          ),

          // Botões de ação (Aprovar/Reprovar)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildBotoesAcao(),
          ),
        ],
      ),
    );
  }

  /// CABEÇALHO DA SOLICITAÇÃO
  Widget _buildInfoSolicitacao() {
    final solicitacao = widget.solicitacao;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow("Nº Solicitação", solicitacao["id"].toString()),
        _buildInfoRow("Usuário", solicitacao["usuario"]),
        _buildInfoRow(
          "Data da Solicitação",
          converterDataEHoras(solicitacao["data_solicitacao"]),
        ),
        _buildInfoRow("Status", solicitacao["status"]),
        _buildInfoRow(
          "Total",
          "R\$ ${solicitacao["total"].toStringAsFixed(2)}",
        ),
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

  /// LISTA DE ITENS
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
          itemBuilder: (context, index) {
            final item = _localItens[index];
            return _buildItemCard(item);
          },
        ),
      ],
    );
  }

  /// CONSTRUÇÃO DE CADA CARD DE ITEM
  Widget _buildItemCard(Map<String, dynamic> item) {
    // Controlador para a quantidade (permite edição)
    final TextEditingController qtdCtrl = TextEditingController(
      text: item["quantidade"].toString(),
    );

    // Função para atualizar a quantidade do item e recalcular subtotal
    void _atualizarQuantidade() {
      final newQtd = double.tryParse(qtdCtrl.text) ?? 0;
      setState(() {
        item["quantidade"] = newQtd;
        // Recalcula o subtotal (se preco_unitario não for nulo)
        final precoUnitario = item["preco_unitario"] as double?;
        if (precoUnitario != null) {
          item["subtotal"] = newQtd * precoUnitario;
        }
      });
    }

    // Verifica se é de outra unidade
    final bool isOutraUnidade = (item["is_outra_unidade"] == true);

    // Pega data limite, se houver
    final String? dataLimite = item["data_limite"] as String?;

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
            // Linha com título do material + botão de remover
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                // Ícone "X" para remover o card
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _localItens.remove(item); // Remove do estado local
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Se for de outra unidade, exibe informação de transferência
            if (isOutraUnidade)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.swap_horiz, color: Colors.deepPurple),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        "Transferência de Unidade: ${item["local"]}",
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const Divider(),

            // Linha com local, grupo e data limite (se houver)
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildInfoColumn("Local", item["local"] ?? '-', 16),
                _buildInfoColumn("Grupo", item["grupo"] ?? '-', 16),

                // Se tiver data limite, exibe
                if (dataLimite != null)
                  _buildInfoColumn(
                    "Data Limite",
                    converterDataEHoras(dataLimite),
                    16,
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Linha com QUANTIDADE (editável) e PREÇO UNITÁRIO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantidade - agora editável
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

                // Preço Unitário
                _buildInfoColumn(
                  "Preço Unitário",
                  "R\$ ${item["preco_unitario"]?.toStringAsFixed(2) ?? '0.00'}",
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

  /// Coluna com label (cinza) + valor (em destaque)
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

  /// BOTÕES APROVAR/REPROVAR
  Widget _buildBotoesAcao() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Botão Aprovar
        ButtonComponents(
          textAlign: Alignment.center,
          onPressed: () {
            // Lógica de aprovar
          },
          text: 'Aprovar',
          textColor: AppColorsComponents.background,
          backgroundColor: AppColorsComponents.primary,
          fontSize: 12,
          padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 12),
        ),

        // Botão Reprovar
        ButtonComponents(
          textAlign: Alignment.center,
          onPressed: () {
            // Lógica de reprovar
          },
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
