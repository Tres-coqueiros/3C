import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/features/widgets/components/app_colors_components.dart';

class ModernNavigationBar extends StatefulWidget {
  @override
  _ModernNavigationBarState createState() => _ModernNavigationBarState();
}

class _ModernNavigationBarState extends State<ModernNavigationBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColorsComponents.primary,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      currentIndex: _currentIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Perfil',
        ),
      ],
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        switch (index) {
          case 0:
            context.go('/homepage');
            break;
          case 1:
            context.go('/profile');
        }
      },
    );
  }
}
