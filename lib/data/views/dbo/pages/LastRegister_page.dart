import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:senior/data/global_data.dart';

class LastRegisterPage extends StatefulWidget {
  final Map<String, dynamic> registro;

  const LastRegisterPage({super.key, required this.registro});

  @override
  State<LastRegisterPage> createState() => _LastRegisterPageState();
}

class _LastRegisterPageState extends State<LastRegisterPage> {
  final TextEditingController _novoMotivoController = TextEditingController();
  final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  // Armazenaremos localmente a lista de motivos de parada para edição
  late List<dynamic> _motivosParada;

  @override
  void initState() {
    super.initState();

    // Se "motivosParada" existe e é uma lista, fazemos uma cópia local
    if (widget.registro.containsKey('motivosParada') &&
        widget.registro['motivosParada'] is List) {
      _motivosParada = List.from(widget.registro['motivosParada']);
    } else {
      _motivosParada = [];
    }
  }

  /// Retorna um widget para cada campo do registro (exceto motivosParada, que terá exibição customizada)
  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value != null ? value.toString() : 'Não informado',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Exibe o DateTimePicker para data/hora
  Future<DateTime?> _pickDateTime() async {
    DateTime? selecionado;
    await DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      onConfirm: (date) {
        selecionado = date;
      },
      currentTime: DateTime.now(),
      locale: LocaleType.pt,
    );
    return selecionado;
  }

  // Adiciona um novo motivo de parada
  Future<void> _addNovoMotivo() async {
    final descricao = _novoMotivoController.text.trim();
    if (descricao.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite o motivo antes de adicionar!")),
      );
      return;
    }

    final inicio = await _pickDateTime();
    if (inicio == null) return;

    final fim = await _pickDateTime();
    if (fim == null) return;

    if (fim.isBefore(inicio)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Hora final não pode ser antes da inicial!")),
      );
      return;
    }

    final duracaoMin = fim.difference(inicio).inMinutes;
    final novoMotivo = {
      'descricao': descricao,
      'inicio': _dateTimeFormat.format(inicio),
      'fim': _dateTimeFormat.format(fim),
      'duracaoMin': duracaoMin,
    };

    setState(() {
      _motivosParada.add(novoMotivo);
      _novoMotivoController.clear();
    });
  }

  // Remove um motivo de parada
  // void _removerMotivo(int index) {
  //   setState(() {
  //     _motivosParada.removeAt(index);
  //   });
  // }

  // Salva alterações no registro global e fecha a tela
  void _salvarAlteracoes() {
    // Atualiza o registro original com a nova lista de motivos
    widget.registro['motivosParada'] = _motivosParada;

    // Também atualiza na listaDeRegistros global
    final idx = listaDeRegistros.indexOf(widget.registro);
    if (idx != -1) {
      listaDeRegistros[idx] = widget.registro;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Se o registro está vazio, exibimos mensagem
    if (widget.registro.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes do Registro'),
          backgroundColor:
              const Color.from(alpha: 1, red: 0.18, green: 0.49, blue: 0.196),
        ),
        body: const Center(
          child: Text(
            'Nenhum registro selecionado.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Caso o registro tenha dados, exibimos
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Registro'),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            onPressed: _salvarAlteracoes,
            icon: const Icon(Icons.save),
            tooltip: 'Salvar alterações',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Exibição dos demais campos (sem edição)
            ...widget.registro.entries.map((entry) {
              // Se for 'motivosParada', não exibimos aqui (pois terá exibição custom)
              if (entry.key == 'motivosParada') {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  _buildDetailRow(entry.key, entry.value),
                  const Divider(),
                ],
              );
            }).toList(),

            // Agora exibimos a seção de "Motivos de Parada" com edição
            const SizedBox(height: 16),
            const Text(
              'Editar Motivos de Parada',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Campo para digitar um novo motivo
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _novoMotivoController,
                    decoration: const InputDecoration(
                      labelText: 'Novo Motivo',
                      hintText: 'Ex: Falta de material',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addNovoMotivo,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            // Lista de motivos de parada
            if (_motivosParada.isEmpty)
              const Text('Nenhum motivo de parada cadastrado.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _motivosParada.length,
                itemBuilder: (context, index) {
                  final m = _motivosParada[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(m['descricao'] ?? 'Sem descrição'),
                      subtitle: Text(
                        'Início: ${m['inicio']}\n'
                        'Fim: ${m['fim']}\n'
                        'Duração: ${m['duracaoMin']} min',
                      ),
                      // trailing: IconButton(
                      //   icon: const Icon(Icons.delete, color: Colors.red),
                      //   onPressed: () => _removerMotivo(index),
                      // ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.green[800],
      //   onPressed: () => Navigator.pop(context),
      //   child: const Icon(Icons.arrow_back),
      // ),
    );
  }
}
