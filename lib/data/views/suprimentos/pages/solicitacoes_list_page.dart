import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';

class SolicitacoesListPage extends StatefulWidget {
  const SolicitacoesListPage({Key? key}) : super(key: key);

  @override
  _SolicitacoesListPageState createState() => _SolicitacoesListPageState();
}

class _SolicitacoesListPageState extends State<SolicitacoesListPage> {
  final GetServices getServices = GetServices();
  List<Map<String, dynamic>> solicitacoes = [];
  bool isLoading = true;

  // Campos para busca e filtro
  String _searchQuery = "";
  String _statusFilter = "Todos";

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

  /// Retorna a cor da faixa no topo, de acordo com o status
  Color _getStatusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains("edição")) {
      return const Color.fromARGB(255, 72, 61, 231); // Azul
    } else if (lower.contains("andamento")) {
      return const Color.fromARGB(255, 202, 189, 70); // Amarelo
    } else if (lower.contains("concluído")) {
      return const Color.fromARGB(255, 56, 245, 69); // Verde
    }
    // Caso não identifique, usa um cinza claro
    return Colors.grey.shade400;
  }

  /// Retorna o texto do status para exibir na faixa
  String _getStatusText(String status) {
    return status; // exibe do jeito que vem
  }

  /// Filtra a lista original conforme _searchQuery e _statusFilter
  List<Map<String, dynamic>> _filteredSolicitacoes() {
    return solicitacoes.where((sol) {
      final status = sol["status"]?.toString().toLowerCase() ?? "";
      final usuario = sol["usuario"]?.toString().toLowerCase() ?? "";
      final id = sol["id"]?.toString() ?? "";
      final query = _searchQuery.toLowerCase();

      // Filtro por status
      if (_statusFilter != "Todos") {
        if (!status.contains(_statusFilter.toLowerCase())) {
          return false;
        }
      }

      // Filtro por busca (nome ou número da solicitação)
      if (query.isNotEmpty) {
        final matchUsuario = usuario.contains(query);
        final matchId = id.contains(query);
        if (!matchUsuario && !matchId) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final listaFiltrada = _filteredSolicitacoes();

    return Scaffold(
      body: Column(
        children: [
          // Cabeçalho com título e botão de adicionar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Solicitações',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    context.go('/solicitar');
                  },
                  color: AppColorsComponents.primary,
                  icon: const Icon(
                    Icons.add,
                    size: 28,
                    color: AppColorsComponents.primary,
                  ),
                ),
              ],
            ),
          ),

          // Linha para busca e filtro
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                // Campo de pesquisa
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: InputBorder.none,
                        hintText: 'Pesquisar...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Dropdown de status (com um estilo que combine)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, color: Colors.grey),
                      const SizedBox(width: 6),
                      DropdownButton<String>(
                        value: _statusFilter,
                        underline: const SizedBox(), // remove underline
                        style: const TextStyle(color: Colors.black87),
                        items: const [
                          DropdownMenuItem(
                            value: "Todos",
                            child: Text("Todos"),
                          ),
                          DropdownMenuItem(
                            value: "Em Edição",
                            child: Text("Em Edição"),
                          ),
                          DropdownMenuItem(
                            value: "Em Andamento",
                            child: Text("Em Andamento"),
                          ),
                          DropdownMenuItem(
                            value: "Concluído",
                            child: Text("Concluído"),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _statusFilter = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Corpo
          if (isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (listaFiltrada.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  _searchQuery.isEmpty && _statusFilter == "Todos"
                      ? 'Nenhuma solicitação encontrada.'
                      : 'Nenhuma solicitação corresponde ao filtro.',
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: listaFiltrada.length,
                itemBuilder: (context, index) {
                  final solicitacao = listaFiltrada[index];
                  final status = solicitacao["status"]?.toString() ?? "";
                  final topBarColor = _getStatusColor(status);
                  final statusText = _getStatusText(status);

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      context.push(
                        '/solicitacoes/detalhes',
                        extra: solicitacao,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          // sombra leve
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Faixa colorida no topo
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: topBarColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                statusText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // Conteúdo principal
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ícone à esquerda
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: topBarColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.receipt_long,
                                    color: topBarColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Informações
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Número da solicitação
                                      Text(
                                        'Nº ${solicitacao["id"]}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Solicitante
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person_outline,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              solicitacao["usuario"] ??
                                                  'Usuário não encontrado',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      // Data
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.date_range_outlined,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Data: ${solicitacao["data_solicitacao"]}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Ícone de navegação (seta)
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
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
