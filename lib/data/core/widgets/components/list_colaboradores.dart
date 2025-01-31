import 'package:flutter/material.dart';
import 'package:senior/data/features/auth/auth_services.dart';
import 'package:senior/data/features/horaextras/pages/list_hora_extra.dart';

class ListColaboradores extends StatefulWidget {
  @override
  _ListColaboradoresState createState() => _ListColaboradoresState();
}

class _ListColaboradoresState extends State<ListColaboradores> {
  final GetAuth getAuth = GetAuth();
  List<Map<String, dynamic>> listColaboradores = [];
  bool isLoading = true; // Inicializa como true para mostrar loading

  @override
  void initState() {
    super.initState();
    fetchColaboradores();
  }

  void fetchColaboradores() async {
    try {
      final result = await getAuth.getColaboradorGestor();
      setState(() {
        listColaboradores = result;
        isLoading = false;
      });
    } catch (error) {
      print('Erro ao carregar dados: $error');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Colaboradores")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : listColaboradores.isEmpty
              ? Center(child: Text("Nenhum colaborador encontrado."))
              : ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: listColaboradores.length,
                  itemBuilder: (context, index) {
                    final colaborador = listColaboradores[index];
                    return Card(
                      elevation: 4.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        leading: Icon(
                          Icons.person,
                          color: Colors.green,
                          size: 40.0,
                        ),
                        title: Text(
                          colaborador['nomfun'] ?? 'Sem nome',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Horas Extras: ${colaborador['horas_formatadas']?.join(", ") ?? 'Nenhuma'}',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.greenAccent,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListHoraExtra(
                                colaborador: Colaborador(
                                  nome: colaborador['nomfun'] ?? 'Sem nome',
                                  horasExtras: int.tryParse(
                                          colaborador['horas_formatadas'] ??
                                              '0') ??
                                      0,
                                  jornada:
                                      colaborador['despos'] ?? 'Não informado',
                                  matricula: colaborador['numcad'] ?? 0,
                                  cargo: colaborador['titred'] ?? 'Sem cargo',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class Colaborador {
  final String nome;
  final int horasExtras;
  final String jornada;
  final int matricula;
  final String cargo;

  Colaborador({
    required this.nome,
    required this.horasExtras,
    required this.jornada,
    required this.matricula,
    required this.cargo,
  });
}
