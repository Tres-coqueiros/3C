import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior/data/core/provider/app_provider_departament.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';

class SidebarComponents extends StatefulWidget {
  @override
  _SidebarComponentsState createState() => _SidebarComponentsState();
}

class _SidebarComponentsState extends State<SidebarComponents> {
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
                  _buildDepartmentItem(
                      context, Icons.download, 'Recursos Humanos'),
                  _buildDepartmentItem(context, Icons.visibility, 'PCM'),
                  _buildDepartmentItem(context, Icons.analytics, 'Suprimentos'),
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
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.1),
          //     blurRadius: 5,
          //     spreadRadius: 1,
          //     offset: Offset(2, 2),
          //   ),
          // ],
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
}
