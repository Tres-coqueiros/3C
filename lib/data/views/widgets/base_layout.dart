import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/views/auth/auth_services.dart';
import 'package:senior/data/views/dbo/pages/DetailsRegister_page.dart';
import 'package:senior/data/views/horaextras/pages/navigation_page.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:senior/data/views/widgets/components/sidebar_components.dart';

class BaseLayout extends StatelessWidget {
  final PostAuth postAuth = PostAuth();
  final Widget body;

  BaseLayout({super.key, required this.body});

  // void _mostrarRegistros(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => BaseLayout(
  //         body: DetailsregisterPage(registros: []),
  //       ),
  //     ),
  //   );
  // }

  void Exit(BuildContext context) async {
    try {
      await postAuth.authlogout();
      context.go('/');
    } catch (error) {
      print('Erro ao encerrar app: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao tentar sair do aplicativo'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerScrimColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColorsComponents.primary,
        centerTitle: false,
        elevation: 0,
        // title: Row(
        //   children: [
        //     AnimatedContainer(
        //       duration: Duration(seconds: 1),
        //       curve: Curves.easeInOut,
        //       child: ClipRRect(
        //         child: Image.asset(
        //           'assets/images/logoBranca.png',
        //           height: 50,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            color: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Notificações ainda não implementadas')),
              );
            },
          ),
          IconButton(
              color: Colors.white,
              onPressed: () => print('object'),
              icon: const Icon(Icons.av_timer_rounded)),
          // IconButton(
          //   icon: const Icon(Icons.history, color: Colors.white),
          //   onPressed: () => _mostrarRegistros(context),
          // ),
          IconButton(
            icon: const Icon(Icons.exit_to_app_outlined),
            color: Colors.white,
            onPressed: () => Exit(context),
          ),
        ],
      ),
      drawer: Drawer(
        elevation: 4,
        // shadowColor: AppColorsComponents.hashours,
        backgroundColor: AppColorsComponents.hashours,
        child: Column(
          children: [Expanded(child: SidebarComponents())],
        ),
      ),
      backgroundColor: const Color(0xFFF3F7FB),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(child: body),
          ModernNavigationBar(),
        ],
      ),
    );
  }
}
