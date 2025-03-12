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
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Selecione o Departamento',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColorsComponents.primary, AppColorsComponents.primary],
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
                  _buildDepartmentItem(
                      context, Icons.people, 'Recursos Humanos'),
                  _buildDepartmentItem(context, Icons.build, 'PCM'),
                  _buildDepartmentItem(
                      context, Icons.shopping_cart, 'Suprimentos'),
                  Divider(color: Colors.white70, thickness: 1),
                ],
              ),
            ),
          ],
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem(IconData icon, String title, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        },
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
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
