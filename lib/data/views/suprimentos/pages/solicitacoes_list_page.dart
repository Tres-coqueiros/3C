import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/core/repository/api_repository.dart';

class SolicitacoesListPage extends StatefulWidget {
  @override
  _SolicitacoesListPageState createState() => _SolicitacoesListPageState();
}

class _SolicitacoesListPageState extends State<SolicitacoesListPage> {
  final GetServices getServices = GetServices();

  List<Map<String, dynamic>> solicitacoes = [];

  @override
  void initState() {
    super.initState();
    fetchSolicitacoes();
  }

  void fetchSolicitacoes() async {
    try {
      await Future.delayed(Duration(seconds: 1));
      final result = await getServices.getMaterialSolicitacao();
      setState(() {
        solicitacoes = result.map<Map<String, dynamic>>((solicitacao) {
          return {
            'id': solicitacao['id'] ?? 0,
            'data_solicitacao': solicitacao['data_solicitacao'],
            'supervisor': solicitacao['supervisor'] ?? 'Não encontrado',
            'usuario': solicitacao['usuario'] ?? 'Não encontrado',
            'status': solicitacao['status'] ?? 'Não encontrado',
            'total': solicitacao['total'] ?? 'Não encontrado',
          };
        }).toList();
      });
    } catch (error) {
      print('Falha ao carregar as solicitações: $error');
    }
  }

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nº ${solicitacao["id"]}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Solicitante: ${solicitacao["usuario"]}',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          'Data: ${solicitacao["data_solicitacao"]}',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          'Status: ${solicitacao["status"]}',
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
