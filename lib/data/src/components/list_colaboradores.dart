import 'package:flutter/material.dart';
import 'package:senior/data/src/page/list_hora_extra.dart';

class ListColaboradores extends StatelessWidget {
  final List<Colaborador> colaboradores = [
    Colaborador(
      nome: 'João Silva',
      horasExtras: 10,
      Jornada: '07:34 11:00 13:00 17:21',
      Maticula: 2186,
      Cargo: 'Analista Administrativo',
    ),
    Colaborador(
      nome: 'Maria Oliveira',
      horasExtras: 15,
      Jornada: '07:34 11:00 13:00 17:21',
      Maticula: 2186,
      Cargo: 'Analista Administrativo',
    ),
    Colaborador(
      nome: 'Pedro Souza',
      horasExtras: 8,
      Jornada: '07:34 11:00 13:00 17:21',
      Maticula: 2186,
      Cargo: 'Analista Administrativo',
    ),
  ];

  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: colaboradores.length,
      itemBuilder: (context, index) {
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
              colaboradores[index].nome,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Horas Extras: ${colaboradores[index].horasExtras}',
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
                  builder: (context) =>
                      ListHoraExtra(colaborador: colaboradores[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class Colaborador {
  final String nome;
  final int horasExtras;
  final String Jornada;
  final int Maticula;
  final String Cargo;

  Colaborador(
      {required this.nome,
      required this.horasExtras,
      required this.Jornada,
      required this.Maticula,
      required this.Cargo});
}
