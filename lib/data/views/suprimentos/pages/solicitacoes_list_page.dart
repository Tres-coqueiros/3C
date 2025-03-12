import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SolicitacoesListPage extends StatelessWidget {
  const SolicitacoesListPage({super.key});

  // Exemplo de dados mock
  final List<Map<String, dynamic>> solicitacoes = const [
    {
      "numeroSolicitacao": 1001,
      "data": "12/03/2025",
      "solicitante": "João da Silva",
      "grupoMaterial": "Peças Elétricas",
      "codigoMaterial": "EL-ABC-123",
      "itens": [
        {"nome": "Fio de Cobre", "quantidade": 10, "valorUnit": "R\$ 15,00"},
        {"nome": "Bateria", "quantidade": 2, "valorUnit": "R\$ 120,00"},
        {
          "nome": "Extensão Elétrica 3m",
          "quantidade": 2,
          "valorUnit": "R\$ 45,00",
        },
        {
          "nome": "Adaptador de Tomada",
          "quantidade": 5,
          "valorUnit": "R\$ 12,00",
        },
        {
          "nome": "Pilha AA Recarregável",
          "quantidade": 6,
          "valorUnit": "R\$ 20,00",
        },
        {
          "nome": "Sensor de Movimento",
          "quantidade": 1,
          "valorUnit": "R\$ 80,00",
        },
        {
          "nome": "Relé Temporizador",
          "quantidade": 3,
          "valorUnit": "R\$ 35,00",
        },
        {
          "nome": "Chave Phillips",
          "quantidade": 2,
          "valorUnit": "R\$ 18,50",
        },
        {
          "nome": "Tomada USB",
          "quantidade": 4,
          "valorUnit": "R\$ 22,00",
        },
        {
          "nome": "Multímetro Digital",
          "quantidade": 1,
          "valorUnit": "R\$ 150,00",
        },
      ],
    },
    {
      "numeroSolicitacao": 1003,
      "data": "13/03/2025",
      "solicitante": "Maria Pereira",
      "grupoMaterial": "Ferramentas",
      "codigoMaterial": "FER-567",
      "itens": [
        {"nome": "Chave de Fenda", "quantidade": 4, "valorUnit": "R\$ 10,00"},
        {"nome": "Martelo", "quantidade": 1, "valorUnit": "R\$ 35,50"},
        {"nome": "Parafusos", "quantidade": 50, "valorUnit": "R\$ 0,50"},
      ],
    },
    {
      "numeroSolicitacao": 1004,
      "data": "13/03/2025",
      "solicitante": "Maria Pereira",
      "grupoMaterial": "Ferramentas",
      "codigoMaterial": "FER-567",
      "itens": [
        {"nome": "Chave de Fenda", "quantidade": 4, "valorUnit": "R\$ 10,00"},
        {"nome": "Martelo", "quantidade": 1, "valorUnit": "R\$ 35,50"},
        {"nome": "Parafusos", "quantidade": 50, "valorUnit": "R\$ 0,50"},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitações de Compra'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: solicitacoes.length,
        itemBuilder: (context, index) {
          final solicitacao = solicitacoes[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                /// 🔹 Ao clicar no Card, enviamos a solicitação para a rota de detalhes
                context.push(
                  '/solicitacoes/detalhes',
                  extra: solicitacao,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Lado esquerdo: Infos básicas
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nº ${solicitacao["numeroSolicitacao"]}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Solicitante: ${solicitacao["solicitante"]}',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          'Data: ${solicitacao["data"]}',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),

                    /// Ícone para indicar clique
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
