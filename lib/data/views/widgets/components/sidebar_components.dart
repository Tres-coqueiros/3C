import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior/data/core/provider/app_provider_departament.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';

class SidebarComponents extends StatefulWidget {
  @override
  _SidebarComponentsState createState() => _SidebarComponentsState();
}

class _SidebarComponentsState extends State<SidebarComponents> {
  // Variável para controlar a expansão do submenu
  bool _isSubmenuExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColorsComponents.hashours,
        elevation: 0,
        title: Text(
          'Selecione o Departamento',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorsComponents.primary,
              AppColorsComponents.primary,
            ],
          ),
        ),
        child: Row(
          children: [
            // Sidebar container
            Container(
              width: 290,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Menu Principal'),
                  _buildDepartmentItemWithSubmenu(
                    context,
                    Icons.person_2,
                    'Recursos Humanos',
                    ['Item 1', 'Item 2', 'Item 3'],
                  ),
                  _buildDepartmentItemWithSubmenu(
                    context,
                    Icons.analytics,
                    'PCM',
                    ['Item 1', 'Item 2', 'Item 3'],
                  ),
                  _buildDepartmentItemWithSubmenu(
                    context,
                    Icons.analytics,
                    'Suprimentos',
                    ['Item 1', 'Item 2', 'Item 3'],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
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

  Widget _buildDepartmentItem(
      BuildContext context, IconData icon, String title) {
    return InkWell(
      onTap: () {
        Provider.of<AppProviderDepartament>(context, listen: false)
            .setSelectedDepartament(title);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                color: AppColorsComponents.hashours,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentItemWithSubmenu(BuildContext context, IconData icon,
      String title, List<String> submenuItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isSubmenuExpanded =
                  !_isSubmenuExpanded; // Alterna a expansão do submenu
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                SizedBox(width: 15),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColorsComponents.hashours,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Icon(
                  _isSubmenuExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        if (_isSubmenuExpanded) // Exibe o submenu se estiver expandido
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: submenuItems.map((item) {
                return _buildSubmenuItem(context, item);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmenuItem(BuildContext context, String title) {
    return InkWell(
      onTap: () {
        Provider.of<AppProviderDepartament>(context, listen: false)
            .setSelectedDepartament(title);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                color: AppColorsComponents.hashours,
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
