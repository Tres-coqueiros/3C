import 'package:flutter/material.dart';
import 'package:senior/data/core/network/api_services.dart';
import 'package:senior/data/features/widgets/components/app_colors_components.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  GetServices getServices = GetServices();

  List<Map<String, dynamic>> getLogin = [];
  String nameFun = "";
  String positionsFun = "";
  int numFun = 0;

  void initState() {
    super.initState();
    fetchLogin();
  }

  void fetchLogin() async {
    try {
      final result = await getServices.getLogin();

      if (result.isNotEmpty) {
        nameFun = result['getLogin']['nomfun'] ?? 'Desconhecido';
        positionsFun = result['getLogin']['titred'] ?? 'Desconhecido';
        numFun = result['getLogin']['numcad'] ?? 'Desconhecido';
      }

      print('Resultado da API: $nameFun');

      setState(() {
        getLogin = [result['getLogin']];
      });
    } catch (e) {
      print('Erro ao fazer a consulta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: Text('Profile'),
          // backgroundColor: Colors.white,
          // elevation: 0,
          ),
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColorsComponents.primary,
        borderRadius: BorderRadius.only(
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
          SizedBox(height: 10),
          Text(
            nameFun,
            style: TextStyle(
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
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações Pessoais',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.margin_outlined,
                color: AppColorsComponents.secondary),
            title: Text('Numero Matricula'),
            subtitle: Text(numFun.toString()),
          ),
          ListTile(
              leading:
                  Icon(Icons.near_me, color: AppColorsComponents.secondary),
              title: Text('Nome'),
              subtitle: Text(nameFun)),
          ListTile(
            leading: Icon(Icons.work, color: AppColorsComponents.secondary),
            title: Text('Cargo'),
            subtitle: Text(positionsFun),
          ),
        ],
      ),
    );
  }
}
