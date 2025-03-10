import 'package:flutter/material.dart';
import 'package:senior/data/views/dbo/pages/home_page.dart';
import 'package:senior/data/views/horaextras/pages/profile_page.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';

class SidebarComponents extends StatefulWidget {
  @override
  _SidebarComponentsState createState() => _SidebarComponentsState();
}

class _SidebarComponentsState extends State<SidebarComponents> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: AppColorsComponents.primary,
      body: Container(
        color: AppColorsComponents.primary,
        child: Row(
          children: [
            Container(
              width: 80,
              color: AppColorsComponents.primary,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  IconButton(
                    icon: Icon(Icons.home, color: Colors.white),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HomePage()));
                    },
                  ),
                  SizedBox(height: 20),
                  IconButton(
                    icon: Icon(Icons.person, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
