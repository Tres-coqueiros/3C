import 'package:flutter/material.dart';
import 'package:senior/data/core/network/api_services.dart';
import 'package:senior/data/features/horaextras/pages/detalis_colaborador_page.dart';

class ListColaboradores extends StatefulWidget {
  @override
  _ListColaboradoresState createState() => _ListColaboradoresState();
}

class _ListColaboradoresState extends State<ListColaboradores> {
  final GetServices getServices = GetServices();
  List<Map<String, dynamic>> listColaboradores = [];
  List<Map<String, dynamic>> selectedColaboradores = [];
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
      print('Erro ao carregar dados: $error');
      setState(() {
        isLoading = false;
        errorMessage = 'Erro ao carregar colaboradores. Tente novamente.';
      });
    }
  }

  void toggleSelection(Map<String, dynamic> colaborador) {
    setState(() {
      if (selectedColaboradores.contains(colaborador)) {
        selectedColaboradores.remove(colaborador);
      } else {
        selectedColaboradores.add(colaborador);
      }
    });
  }

  void approveSelected() {
    for (var colaborador in selectedColaboradores) {
      print("Aprovado: ${colaborador['NOMFUN']}");
    }
    setState(() {
      selectedColaboradores.clear();
    });
  }

  void rejectSelected() {
    for (var colaborador in selectedColaboradores) {
      print("Reprovado: ${colaborador['NOMFUN']}");
    }
    setState(() {
      selectedColaboradores.clear();
    });
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
                        return Card(
                          elevation: 6.0,
                          margin: EdgeInsets.only(bottom: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            leading: CircleAvatar(
                              radius: 30.0,
                              backgroundColor: Colors.green,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            ),
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
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.grey[600],
                                    size: 16.0,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Horas Extras: ${colaborador['HORA_EXTRA'] ?? 'Nenhuma'}',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Checkbox(
                              value:
                                  selectedColaboradores.contains(colaborador),
                              onChanged: (bool? value) {
                                toggleSelection(colaborador);
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ListHoraExtra(colaborador: colaborador),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              if (selectedColaboradores.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Selecione pelo menos um colaborador!'),
                ));
              } else {
                approveSelected();
              }
            },
            backgroundColor: Colors.green,
            child: Icon(Icons.check_box),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              if (selectedColaboradores.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Selecione pelo menos um colaborador!'),
                ));
              } else {
                rejectSelected();
              }
            },
            backgroundColor: Colors.red,
            child: Icon(Icons.cancel),
          ),
        ],
      ),
    );
  }
}
