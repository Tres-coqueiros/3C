import 'package:flutter/material.dart';

/// =================================
/// BASESOLICITACAOWIDGET
/// =================================
/// Este widget é a "tela base" da solicitação.
/// Ele exibe: cabeçalho (solicitante, data), lista de itens,
/// subtotal, botões de ação, etc.
/// Dividimos em métodos menores para que seja fácil
/// alterar ou substituir partes específicas.
class BaseSolicitacaoWidget extends StatefulWidget {
  final Map<String, dynamic> solicitacao;

  // Caso queira callbacks externos:
  final VoidCallback? onAprovar;
  final VoidCallback? onReprovar;

  const BaseSolicitacaoWidget({
    Key? key,
    required this.solicitacao,
    this.onAprovar,
    this.onReprovar,
  }) : super(key: key);

  @override
  State<BaseSolicitacaoWidget> createState() => _BaseSolicitacaoWidgetState();
}

class _BaseSolicitacaoWidgetState extends State<BaseSolicitacaoWidget> {
  // Acesso rápido aos itens
  List<Map<String, dynamic>> get _itens =>
      widget.solicitacao["itens"] as List<Map<String, dynamic>>;

  // Cálculo de subtotal de 1 item
  double _calcularSubtotalItem(Map<String, dynamic> item) {
    final valorUnit = item['valorUnit'] as String;
    final valorNumerico = double.parse(
      valorUnit.replaceAll(RegExp(r'[^\d,\.]'), '').replaceAll(',', '.'),
    );
    return valorNumerico * (item['quantidade'] as int);
  }

  // Cálculo do total
  double _calcularValorTotal() {
    double total = 0.0;
    for (var item in _itens) {
      total += _calcularSubtotalItem(item);
    }
    return total;
  }

  // Excluir item (com confirmação)
  void _excluirItem(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Item"),
        content: const Text("Tem certeza que deseja excluir este item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _itens.removeAt(index);
              });
              Navigator.pop(ctx);
            },
            child: const Text("Excluir"),
          ),
        ],
      ),
    );
  }

  // Alterar quantidade ao clicar no texto
  void _alterarQuantidade(int index) {
    final item = _itens[index];
    int quantidadeAtual = item['quantidade'] as int;
    int novaQuantidade = quantidadeAtual;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Alterar Quantidade - ${item['nome']}"),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Nova Quantidade"),
            onChanged: (value) {
              final parsed = int.tryParse(value);
              if (parsed != null && parsed > 0) {
                novaQuantidade = parsed;
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (novaQuantidade <= 0) {
                  return;
                }
                setState(() {
                  item['quantidade'] = novaQuantidade;
                });
                Navigator.pop(ctx);
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // MÉTODOS DE CONSTRUÇÃO (layout) -> cada um em um método
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final valorTotal = _calcularValorTotal();

    return Column(
      children: [
        _buildHeader(), // Cabeçalho (Solicitante, Data, etc.)
        const SizedBox(height: 8),
        const Divider(),

        _buildItensTitle(), // Título "Itens"
        const SizedBox(height: 8),

        _buildListaItens(), // Lista de itens
        const SizedBox(height: 16),

        _buildValorTotal(valorTotal), // Valor total
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 16),

        _buildBotoesAcao(), // Botões (Aprovar, Reprovar)
      ],
    );
  }

  // Cabeçalho
  Widget _buildHeader() {
    final solicitante = widget.solicitacao["solicitante"];
    final data = widget.solicitacao["data"];
    final numero = widget.solicitacao["numeroSolicitacao"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Solicitante: $solicitante',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Data: $data',
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            Text(
              'N° $numero',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  // Título "Itens"
  Widget _buildItensTitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Itens",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  // Lista de Itens
  Widget _buildListaItens() {
    const double alturaMaxima = 300; // Tamanho da listagem
    return SizedBox(
      height: alturaMaxima,
      child: ListView.builder(
        itemCount: _itens.length,
        itemBuilder: (contextList, index) {
          final item = _itens[index];
          return _buildItemCard(item, index);
        },
      ),
    );
  }

  // Card de cada item
  Widget _buildItemCard(Map<String, dynamic> item, int index) {
    final nome = item['nome'];
    final qtd = item['quantidade'];
    final valorUnit = item['valorUnit'];
    final subtotal = _calcularSubtotalItem(item);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        // Sombra leve
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: const Offset(2, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do item + X
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                nome,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: () => _excluirItem(index),
                icon: const Icon(Icons.close, color: Colors.red),
              ),
            ],
          ),
          const Divider(),

          // Linha 1: Grupo e Código
          Row(
            children: [
              Expanded(
                child: Text('Grupo: ${widget.solicitacao["grupoMaterial"]}'),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child:
                      Text('Código: ${widget.solicitacao["codigoMaterial"]}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Linha 2: Quantidade e Valor Unit
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _alterarQuantidade(index),
                  child: Row(
                    children: [
                      const Text('Quantidade: '),
                      Text(
                        '$qtd',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Text('Valor Unit: $valorUnit'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Subtotal
          Text(
            'Subtotal: R\$ ${subtotal.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Valor Total
  Widget _buildValorTotal(double valorTotal) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        'Valor Total: R\$ ${valorTotal.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }

  // Botões de ação (Aprovar / Reprovar)
  Widget _buildBotoesAcao() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('Aprovar'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
          ),
          onPressed: widget.onAprovar ?? () {},
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.close),
          label: const Text('Reprovar'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
          ),
          onPressed: widget.onReprovar ?? () {},
        ),
      ],
    );
  }
}

/// =====================================
/// 2) TELA QUE USA O WIDGET BASE
/// =====================================
/// Exemplo de como usar a tela base em um Scaffold
class TelaSolicitacaoBasePage extends StatelessWidget {
  final Map<String, dynamic> solicitacao;

  TelaSolicitacaoBasePage({
    Key? key,
    Map<String, dynamic>? solicitacao,
  })  : solicitacao = solicitacao ??
            {
              "numeroSolicitacao": 1000,
              "data": "12/03/2025",
              "solicitante": "João da Silva",
              "grupoMaterial": "Ferramentas",
              "codigoMaterial": "FER-567",
              "itens": [
                {
                  "nome": "Chave de Fenda",
                  "quantidade": 4,
                  "valorUnit": "R\$ 10,00",
                },
              ],
            },
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Solicitação Base"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        // Aqui usamos o widget base
        child: BaseSolicitacaoWidget(
          solicitacao: solicitacao,
          // Exemplo: callbacks externos se quiser
          onAprovar: () {
            // Ação ao aprovar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Aprovado!")),
            );
          },
          onReprovar: () {
            // Ação ao reprovar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Reprovado!")),
            );
          },
        ),
      ),
    );
  }
}
