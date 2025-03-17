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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSolicitacoes();
  }

  void fetchSolicitacoes() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      final result = await getServices.getSolicitacao();
      setState(() {
        solicitacoes = result.map<Map<String, dynamic>>((solicitacao) {
          return {
            'id': solicitacao['id'],
            'data_solicitacao':
                solicitacao['data_solicitacao'] ?? 'Data não disponível',
            'usuario': solicitacao['usuario'] ?? 'Usuário não encontrado',
            'status': solicitacao['status'] ?? 'Status não disponível',
            'total': solicitacao['total'] ?? 0.0,
            'usuario_id': solicitacao['usuario_id'],
            'supervisor': solicitacao['supervisor'],
            'supervisor_id': solicitacao['supervisor_id'],
            'observacao': solicitacao['observacao'],
            'itens': solicitacao['itens'] ?? [],
          };
        }).toList();
        isLoading = false;
      });
    } catch (error) {
      print('Falha ao carregar as solicitações: $error');
      setState(() {
        solicitacoes = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Solicitações a serem Aprovadas/Reprovadas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : solicitacoes.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          'Nenhuma solicitação encontrada.',
                          style: TextStyle(
                              fontSize: 16, fontStyle: FontStyle.italic),
                        ),
                      ],
                    )
                  : Expanded(
                      child: ListView.builder(
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                        Text(
                                          'Data: ${solicitacao["data_solicitacao"]}',
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                        Text(
                                          'Status: ${solicitacao["status"]}',
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
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
                    ),
        ],
      ),
    );
  }
}
