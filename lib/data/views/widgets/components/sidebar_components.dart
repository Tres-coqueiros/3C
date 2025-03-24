import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior/data/core/provider/app_provider_departament.dart';
import 'package:senior/data/views/dbo/pages/RegisterPublic_page.dart';
import 'package:senior/data/views/horaextras/pages/list_colaboradores_page.dart';
import 'package:senior/data/views/suprimentos/pages/solicitacoes_list_page.dart';
import 'package:senior/data/views/widgets/base_layout.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';

class SidebarComponents extends StatefulWidget {
  @override
  _SidebarComponentsState createState() => _SidebarComponentsState();
}

class _SidebarComponentsState extends State<SidebarComponents> {
  Map<String, bool> _submenuExpanded = {};
  final Map<String, Widget> navigationMap = {
    "Horas Extras": ListColaboradores(),
    "BDO": RegisterPublicDBO(),
    "Solicitações de Compras": SolicitacoesListPage(),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppColorsComponents.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Cabeçalho do menu
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColorsComponents.hashours,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Text(
                'Selecione o Departamento',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          // Expandindo corretamente o conteúdo
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDepartmentItemWithSubmenu(
                      context,
                      Icons.person_2,
                      'Recursos Humanos',
                      ['Horas Extras'],
                    ),
                    _buildDepartmentItemWithSubmenu(
                      context,
                      Icons.ac_unit,
                      'PCM',
                      ['BDO'],
                    ),
                    _buildDepartmentItemWithSubmenu(
                      context,
                      Icons.abc,
                      'Suprimentos',
                      ['Solicitações de Compras'],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDepartmentItemWithSubmenu(BuildContext context, IconData icon,
      String title, List<String> submenuItems) {
    bool isExpanded = _submenuExpanded[title] ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _submenuExpanded[title] = !isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColorsComponents.primary,
                  AppColorsComponents.primary2
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: submenuItems.map((item) {
                      return _buildSubmenuItem(context, item);
                    }).toList(),
                  ),
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSubmenuItem(BuildContext context, String title) {
    return InkWell(
      onTap: () {
        Provider.of<AppProviderDepartament>(context, listen: false)
            .setSelectedDepartament(title);
        if (navigationMap.containsKey(title)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BaseLayout(body: navigationMap[title]!),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.arrow_upward, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
