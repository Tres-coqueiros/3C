import 'package:flutter/material.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:senior/data/views/widgets/components/list_view_components.dart';

class ListColaboradores extends StatefulWidget {
  const ListColaboradores({super.key});

  @override
  _ListColaboradoresState createState() => _ListColaboradoresState();
}

class _ListColaboradoresState extends State<ListColaboradores> {
  final GetServices getServices = GetServices();
  List<Map<String, dynamic>> listColaboradores = [];
  Map<int, bool> expandedItems = {};
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchColaboradores();
  }

  void fetchColaboradores() async {
    try {
      final result = await getServices.getCollaborators();
      setState(() {
        listColaboradores = result;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erro ao carregar colaboradores. Tente novamente.';
      });
    }
  }

  void toggleExpand(int index) {
    setState(() {
      expandedItems[index] = !(expandedItems[index] ?? false);
    });
  }

  bool hasHorasExtras(Map<String, dynamic> colaborador) {
    return colaborador['ListHorasExtras'] != null &&
        colaborador['ListHorasExtras'].isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child:
                      Text(errorMessage, style: TextStyle(color: Colors.red)))
              : listColaboradores.isEmpty
                  ? Center(child: Text("Nenhum colaborador encontrado."))
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                      itemCount: listColaboradores.length,
                      itemBuilder: (context, index) {
                        final colaborador = listColaboradores[index];
                        final isExpanded = expandedItems[index] ?? false;
                        final hasExtras = hasHorasExtras(colaborador);
                        if (!hasExtras) {
                          return SizedBox.shrink();
                        }
                        return Card(
                          elevation: 6.0,
                          margin: EdgeInsets.only(bottom: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          color: hasExtras
                              ? AppColorsComponents.hashours
                              : Colors.white,
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 12.0),
                                title: Text(
                                  colaborador['NOMFUN'] ?? 'Sem nome',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          color: Colors.grey[600], size: 14.0),
                                      SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          'Cargo: ${colaborador['TITRED'] ?? 'Nenhuma'}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.grey[600]),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.mark_chat_read,
                                          color: Colors.grey[600], size: 16.0),
                                      SizedBox(width: 2),
                                      Text(
                                        'Matricula: ${colaborador['NUMCAD'].toString() ?? 'Nenhuma'}',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: hasExtras
                                    ? GestureDetector(
                                        onTap: () => toggleExpand(index),
                                        child: Icon(
                                          isExpanded
                                              ? Icons.arrow_drop_up
                                              : Icons
                                                  .arrow_drop_down_circle_sharp,
                                          color: AppColorsComponents.primary,
                                        ),
                                      )
                                    : null,
                              ),
                              if (isExpanded) ...[
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListViewComponents(
                                          colaborador: colaborador),
                                    ],
                                  ),
                                ),
                              ]
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
