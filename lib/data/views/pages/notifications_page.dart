import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Exemplo de lista mock de notificações
    final List<Map<String, String>> notifications = [
      {
        "titulo": "Cadastro de Materiais/Produtos",
        "tempo": "10 min atrás",
        "descricao": "O processo 002318 foi publicado..."
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
      // Adicione quantas quiser
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificações"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(notif["titulo"] ?? ""),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif["tempo"] ?? "",
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(notif["descricao"] ?? ""),
                ],
              ),
              leading: const Icon(Icons.notifications),
              onTap: () {
                // Se quiser abrir detalhes da notificação, implemente aqui
              },
            ),
          );
        },
      ),
    );
  }
}
