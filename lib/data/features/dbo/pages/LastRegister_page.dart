import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class TelaDetalhesRegistro extends StatefulWidget {
  final Map<String, dynamic> registro;

  const TelaDetalhesRegistro({Key? key, required this.registro})
      : super(key: key);

  @override
  _TelaDetalhesRegistroState createState() => _TelaDetalhesRegistroState();
}

class _TelaDetalhesRegistroState extends State<TelaDetalhesRegistro> {
  // Mesmo formato usado em RegisterPublicDBO
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

  String? _horarioInicial;
  String? _horarioFinal;

  @override
  void initState() {
    super.initState();

    // Inicializa horário inicial
    if (widget.registro['horarioInicial'] is DateTime) {
      _horarioInicial = dateFormat.format(widget.registro['horarioInicial']);
    } else if (widget.registro['horarioInicial'] != null) {
      _horarioInicial = widget.registro['horarioInicial'].toString();
    } else {
      _horarioInicial = 'Não informado';
    }

    // Inicializa horário final
    if (widget.registro['horarioFinal'] is DateTime) {
      _horarioFinal = dateFormat.format(widget.registro['horarioFinal']);
    } else if (widget.registro['horarioFinal'] != null) {
      _horarioFinal = widget.registro['horarioFinal'].toString();
    } else {
      _horarioFinal = 'Não informado';
    }
  }

  /// Seleciona Data + Hora
  void _selecionarHorario(BuildContext context, bool isInicial) {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      locale: LocaleType.pt, // Define para PT-BR
      onConfirm: (dateTime) {
        setState(() {
          final String dataFormatada = dateFormat.format(dateTime);
          if (isInicial) {
            _horarioInicial = dataFormatada;
          } else {
            _horarioFinal = dataFormatada;
          }
        });
      },
    );
  }

  /// Monta um resumo com todas as informações
  String _montarResumo() {
    final buffer = StringBuffer();

    buffer.writeln(
        "Matrícula: ${widget.registro['matricula'] ?? 'Não informado'}");
    buffer.writeln(
        "Patrimônio Implemento: ${widget.registro['patrimonioImplemento'] ?? 'Não informado'}");
    buffer.writeln("Horário Inicial: ${_horarioInicial ?? 'Não informado'}");
    buffer.writeln("Horário Final: ${_horarioFinal ?? 'Não informado'}");
    buffer.writeln(
        "Patrimônio: ${widget.registro['patrimonio'] ?? 'Não informado'}");
    buffer.writeln(
        "Nome do Coordenador: ${widget.registro['nomeCoordenador'] ?? 'Não informado'}");
    buffer
        .writeln("Operação: ${widget.registro['operacao'] ?? 'Não informado'}");
    buffer.writeln("Motivo: ${widget.registro['motivo'] ?? 'Não informado'}");
    buffer.writeln("Talhão: ${widget.registro['talhao'] ?? 'Não informado'}");
    buffer.writeln("Cultura: ${widget.registro['cultura'] ?? 'Não informado'}");
    buffer.writeln(
        "Horímetro Inicial: ${widget.registro['horimetroInicial']?.toString() ?? 'Não informado'}");
    buffer.writeln(
        "Horímetro Final: ${widget.registro['horimetroFinal']?.toString() ?? 'Não informado'}");

    return buffer.toString();
  }

  /// Exibe o diálogo e aguarda a resposta para efetuar a navegação
  Future<void> _mostrarConfirmacao() async {
    final resumo = _montarResumo();
    final bool? deveNavegar = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Registros Salvos com Sucesso!"),
          content: SingleChildScrollView(
            child: Text(resumo),
          ),
          actions: [
            TextButton(
              child: const Text("Voltar"),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: const Text("Ok"),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    // Após o diálogo ser fechado, se a resposta for positiva, navega para '/homepage'
    if (deveNavegar == true && mounted) {
      context.go('/homepage');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.registro.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes do Registro'),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Matrícula:', widget.registro['matricula']),
                _buildDetailRow('Patrimônio Implemento:',
                    widget.registro['patrimonioImplemento']),
                const SizedBox(height: 10),
                const Text(
                  "Horários*",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Inicial*"),
                          ElevatedButton(
                            onPressed: () => _selecionarHorario(context, true),
                            child: Text(_horarioInicial ?? "Selecione"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Final*"),
                          ElevatedButton(
                            onPressed: () => _selecionarHorario(context, false),
                            child: Text(_horarioFinal ?? "Selecione"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                    'Patrimônio:', widget.registro['patrimonio'] ?? ''),
                _buildDetailRow(
                    'Nome do Coordenador:', widget.registro['nomeCoordenador']),
                _buildDetailRow('Operação:',
                    widget.registro['operacao'] ?? 'Não informado'),
                _buildDetailRow(
                    'Motivo:', widget.registro['motivo'] ?? 'Não informado'),
                _buildDetailRow(
                    'Talhão:', widget.registro['talhao'] ?? 'Não informado'),
                _buildDetailRow(
                    'Cultura:', widget.registro['cultura'] ?? 'Não informado'),
                _buildDetailRow(
                  'Horímetro Inicial:',
                  widget.registro['horimetroInicial']?.toString() ??
                      'Não informado',
                ),
                _buildDetailRow(
                  'Horímetro Final:',
                  widget.registro['horimetroFinal']?.toString() ??
                      'Não informado',
                ),
                const SizedBox(height: 24),
                // Botão Avançar que abre o diálogo e, se confirmado, navega
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _mostrarConfirmacao,
                    child: const Text('Avançar'),
                  ),
                ),
                const SizedBox(height: 24),
                // Botão Voltar (opcional)
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Voltar"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    final String textValue = value != null ? value.toString() : 'Não informado';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              textValue,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
