// profile_page.dart

import 'package:flutter/material.dart';
import 'package:senior/data/core/interface/app_interface.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/views/suprimentos/pages/detalhes_solicitacao_page.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  final GetServices getServices = GetServices();

  List<Map<String, dynamic>> getLogin = [];
  String nameFun = "";
  String positionsFun = "";
  int numFun = 0;
  String gestor = "";
  int numGestor = 0;

  bool _navegouAutomatico = false;

  @override
  void initState() {
    super.initState();
    fetchLogin();
  }

  void fetchLogin() async {
    try {
      final result = await getServices.getLogin();
      if (result.isNotEmpty) {
        nameFun = result[0]['COLABORADOR']?.toString() ?? 'Desconhecido';
        positionsFun = result[0]['COL_CARGO']?.toString() ?? 'Desconhecido';
        numFun = result[0]['COLID'] is int
            ? (result[0]['COLID'] as int)
            : int.tryParse(result[0]['COLID']?.toString() ?? '') ?? 0;
        gestor = result[0]['GESTOR']?.toString() ?? 'Desconhecido';
        numGestor = result[0]['GESTORID'] is int
            ? (result[0]['GESTORID'] as int)
            : int.tryParse(result[0]['GESTORID']?.toString() ?? '') ?? 0;
      }
      setState(() {
        getLogin = result;
      });
    } catch (e) {
      print('Erro ao fazer a consulta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Esta tela "ProfilePage" será rapidamente substituída (pushReplacement)
      // assim que fetchLogin() terminar, então não haverá tela "em branco".
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildProfileDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColorsComponents.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(13),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color.fromARGB(255, 235, 241, 246),
            child: Icon(
              Icons.person,
              size: 40,
              color: AppColorsComponents.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            nameFun,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações Pessoais',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: Icon(
              Icons.margin_outlined,
              color: AppColorsComponents.secondary,
            ),
            title: const Text('Numero Matricula'),
            subtitle: Text(numFun.toString()),
          ),
          ListTile(
            leading: Icon(
              Icons.near_me,
              color: AppColorsComponents.secondary,
            ),
            title: const Text('Nome'),
            subtitle: Text(nameFun),
          ),
          ListTile(
            leading: Icon(
              Icons.work,
              color: AppColorsComponents.secondary,
            ),
            title: const Text('Cargo'),
            subtitle: Text(positionsFun),
          ),
          const SizedBox(height: 10),
          const Text(
            'Gestão',
            style: TextStyle(fontSize: 20),
          ),
          ListTile(
            leading: Icon(
              Icons.person_pin,
              color: AppColorsComponents.secondary,
            ),
            title: const Text('Nome do Gestor'),
            subtitle: Text(gestor),
          ),
          ListTile(
            leading: Icon(
              Icons.margin_outlined,
              color: AppColorsComponents.secondary,
            ),
            title: const Text('Numero Matricula'),
            subtitle: Text(numGestor.toString()),
          ),
        ],
      ),
    );
  }
}
