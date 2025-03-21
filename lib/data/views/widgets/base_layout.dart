import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/views/auth/auth_services.dart';
import 'package:senior/data/views/horaextras/pages/navigation_page.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:senior/data/views/widgets/components/sidebar_components.dart';

class BaseLayout extends StatefulWidget {
  final PostAuth postAuth = PostAuth();
  final Widget body;
  BaseLayout({Key? key, required this.body}) : super(key: key);

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void Exit(BuildContext context) async {
    try {
      await widget.postAuth.authlogout();
      context.go('/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao tentar sair do aplicativo')),
      );
    }
  }

  void _showNotificationsOverlay() {
    if (_overlayEntry != null) return;
    final overlay = Overlay.of(context);
    final size = overlay.context.findRenderObject() as RenderBox;
    const w = 260.0, h = 240.0;
    final top = kToolbarHeight + MediaQuery.of(context).padding.top + 4;
    final left = size.size.width - w - 16;
    _overlayEntry = OverlayEntry(
      builder: (_) => FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                  onTap: _closeOverlay, behavior: HitTestBehavior.translucent),
            ),
            Positioned(
                left: left,
                top: top,
                child: _NotificationsDropdown(onClose: _closeOverlay)),
          ],
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
    _controller.forward();
  }

  int _unreadCount() => 2;

  Widget _buildNotificationIcon() {
    final n = _unreadCount();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications),
        if (n > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(10)),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text('$n',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  void _closeOverlay() {
    if (_overlayEntry != null) {
      _controller.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "3C CONNECT",
          style: TextStyle(
            color: AppColorsComponents.hashours,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: AppColorsComponents.primary,
        elevation: 0,
        actions: [
          IconButton(
              icon: _buildNotificationIcon(),
              color: Colors.white,
              onPressed: _showNotificationsOverlay),
          IconButton(
              icon: const Icon(Icons.av_timer_rounded),
              color: Colors.white,
              onPressed: () => context.go('/logs')),
          IconButton(
              icon: const Icon(Icons.exit_to_app_outlined),
              color: Colors.white,
              onPressed: () => Exit(context)),
        ],
      ),
      drawer: Drawer(
        elevation: 4,
        backgroundColor: AppColorsComponents.hashours,
        child: Column(children: [Expanded(child: SidebarComponents())]),
      ),
      backgroundColor: const Color(0xFFF3F7FB),
      resizeToAvoidBottomInset: true,
      body: Column(
          children: [Expanded(child: widget.body), ModernNavigationBar()]),
    );
  }
}

class _NotificationsDropdown extends StatelessWidget {
  final VoidCallback onClose;
  const _NotificationsDropdown({required this.onClose, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        "titulo": "Processo 002318",
        "tempo": "10 min atrás",
        "descricao": "Cadastro de Materiais/Produtos publicado"
      },
      {
        "titulo": "Solicitação de compra",
        "tempo": "1 h atrás",
        "descricao": "Nova solicitação de compra..."
      },
      {
        "titulo": "Verificar códigos cadastrados",
        "tempo": "2 h atrás",
        "descricao": "A tarefa para verificar códigos..."
      },
      {
        "titulo": "Reunião de equipe",
        "tempo": "3 h atrás",
        "descricao": "Foi agendada uma reunião..."
      },
    ];
    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 260,
            height: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
                  child: Text("Notificações",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 1),
                Expanded(
                  child: notifications.isEmpty
                      ? const Center(
                          child: Text("Você não possui nenhuma notificação"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: notifications.length,
                          itemBuilder: (ctx, i) {
                            final n = notifications[i];
                            return ListTile(
                              leading: const Icon(Icons.notifications),
                              title: Text(n["titulo"] ?? ""),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n["tempo"] ?? "",
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text(n["descricao"] ?? ""),
                                ],
                              ),
                              onTap: onClose,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 20,
            child: Transform.translate(
              offset: const Offset(0, -8),
              child: const Icon(Icons.arrow_drop_up,
                  color: Colors.white, size: 36),
            ),
          ),
        ],
      ),
    );
  }
}
