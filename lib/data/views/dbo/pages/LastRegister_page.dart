import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/global_data.dart';

class LastRegisterPage extends StatefulWidget {
  final Map<String, dynamic> registro;

  const LastRegisterPage({super.key, required this.registro});

  @override
  State<LastRegisterPage> createState() => _LastRegisterPageState();
}

class _LastRegisterPageState extends State<LastRegisterPage> {
  PostServices postServices = PostServices();

  final TextEditingController _novoMotivoController = TextEditingController();
  final TextEditingController _horimetroFinalController =
      TextEditingController();
  final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  // Lista local de motivos de parada
  late List<dynamic> _motivosParada;

  // Flag para saber se o registro está concluído
  late bool _isConcluido;

  @override
  void initState() {
    super.initState();

    // Carrega motivosParada localmente
    if (widget.registro.containsKey('motivosParada') &&
        widget.registro['motivosParada'] is List) {
      _motivosParada = List.from(widget.registro['motivosParada']);
    } else {
      _motivosParada = [];
    }

    // Verifica se está concluído
    _isConcluido = (widget.registro['status'] == 'concluido');

    // Carrega o horímetro final (se existir)
    final horimetroFinalStr =
        widget.registro['horimetroFinal']?.toString() ?? '';
    _horimetroFinalController.text = horimetroFinalStr;
  }

  /// Monta widget de exibição para cada campo (exceto motivosParada e horimetroFinal)
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

  // Adiciona novo motivo de parada
  Future<void> _addNovoMotivo() async {
    if (_isConcluido) return; // Se concluído, não faz nada

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
          content: Text("Hora final não pode ser antes da inicial!"),
        ),
      );
      return;
    }

    final duracaoMin = fim.difference(inicio).inMinutes;
    final novoMotivo = {
      'descricao': descricao,
      'inicio': _dateTimeFormat.format(inicio),
      'fim': _dateTimeFormat.format(fim),
      'duracaoMin': duracaoMin,
      'horimetroFinal': _horimetroFinalController.text,
    };

    bool success = await postServices.postBDOMotivo(novoMotivo);
    print('novoMotivo $novoMotivo');
    if (success) {}
  }

  // Salva alterações no registro global e fecha a tela
  void _salvarAlteracoes() {
    // Se concluído, não atualiza nada
    if (_isConcluido) {
      Navigator.pop(context);
      return;
    }

    // Regras de horímetro: Final não pode ser menor que Inicial, nem exceder 12
    final horimetroFinalStr = _horimetroFinalController.text.trim();
    final double? horimetroFinal = double.tryParse(horimetroFinalStr);

    // Se o registro tiver horimetroInicial, convertemos
    final horimetroInicialStr = widget.registro['horimetroInicial']?.toString();
    final double? horimetroInicial = horimetroInicialStr != null
        ? double.tryParse(horimetroInicialStr)
        : null;

    if (horimetroFinal != null && horimetroInicial != null) {
      if (horimetroFinal <= horimetroInicial) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horímetro Final deve ser maior que o Inicial!'),
          ),
        );
        return; // Impede de salvar
      }
      if ((horimetroFinal - horimetroInicial) > 12) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horímetro excede as 12 horas de trabalho!'),
          ),
        );
        return; // Impede de salvar
      }
    }

    // Atualiza o registro original com a nova lista de motivos
    widget.registro['motivosParada'] = _motivosParada;

    // Atualiza o horimetroFinal no registro
    widget.registro['horimetroFinal'] = _horimetroFinalController.text;

    // Também atualiza na listaDeRegistros global
    final idx = listaDeRegistros.indexOf(widget.registro);
    if (idx != -1) {
      listaDeRegistros[idx] = widget.registro;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.registro.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes do Registro'),
          shadowColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 26, 55, 27),
        ),
        body: const Center(
          child: Text(
            'Nenhum registro selecionado.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Registro'),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            onPressed: _salvarAlteracoes,
            icon: const Icon(Icons.save),
            tooltip: _isConcluido
                ? 'Registro concluído, sem alterações'
                : 'Salvar alterações',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Exibe demais campos (exceto motivosParada e horimetroFinal)
            ...widget.registro.entries.map((entry) {
              if (entry.key == 'motivosParada' ||
                  entry.key == 'horimetroFinal') {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  _buildDetailRow(entry.key, entry.value),
                  const Divider(),
                ],
              );
            }).toList(),

            // Se concluído, exibe horimetroFinal em modo leitura
            if (_isConcluido) ...[
              const SizedBox(height: 16),
              const Text(
                'Registro Concluído',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text('Edição de motivos de parada não é permitida.'),
              const SizedBox(height: 16),
              // Exibe Horímetro Final em modo somente leitura
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Horímetro Final: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.registro['horimetroFinal']?.toString() ??
                          'Não informado',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Se não concluído, pode editar Horímetro Final e Motivos
              const SizedBox(height: 16),
              TextField(
                controller: _horimetroFinalController,
                decoration: const InputDecoration(
                  labelText: 'Horímetro Final',
                  hintText: 'Digite o Horímetro Final',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),
              const Text(
                'Editar Motivos de Parada',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _novoMotivoController,
                      decoration: const InputDecoration(
                        labelText: 'Novo Motivo',
                        hintText: 'Ex: Chuva',
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
            ],

            const SizedBox(height: 16),
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
                    ),
                  );
                },
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
