import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailsregisterPage extends StatefulWidget {
  final List<Map<String, dynamic>> dados; // Corrigindo o tipo da lista

  const DetailsregisterPage({Key? key, required this.dados}) : super(key: key);

  @override
  _DetailsregisterPageState createState() => _DetailsregisterPageState();
}

class _DetailsregisterPageState extends State<DetailsregisterPage> {
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
  Map<String, dynamic>? _registroSelecionado; // Armazena o registro selecionado

  /// Formata data e hora corretamente
  String _formatarData(dynamic valor) {
    if (valor == null) return 'Não informado';
    if (valor is DateTime) return dateFormat.format(valor);
    return valor.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_registroSelecionado == null
            ? 'Registros Cadastrados'
            : 'Detalhes do Registro'),
        leading: _registroSelecionado != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _registroSelecionado =
                        null; // Voltar para a lista de registros
                  });
                },
              )
            : null, // Se estiver na lista, não mostra o botão de voltar
      ),
      body: _registroSelecionado == null
          ? _buildListaRegistros() // Exibe os Cards dos registros
          : _buildDetalhesRegistro(), // Exibe os detalhes do registro selecionado
    );
  }

  /// Constrói a **lista de registros** e exibe como **Cards**
  Widget _buildListaRegistros() {
    print("Dados recebidos em DetailsregisterPage: ${widget.dados}");

    return widget.dados.isEmpty
        ? const Center(
            child: Text(
              'Nenhum registro disponível.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: widget.dados.length,
            itemBuilder: (context, index) {
              final item = widget.dados[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    'Registro #${index + 1}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfo('Matrícula', item['matricula']),
                      _buildInfo('Operação', item['operacao']),
                      _buildInfo('Talhão', item['talhao']),
                      _buildInfo('Hora Inicial',
                          _formatarData(item['horarioInicial'])),
                      _buildInfo(
                          'Hora Final', _formatarData(item['horarioFinal'])),
                    ],
                  ),
                  trailing: const Icon(
                      Icons.arrow_forward_ios), // Ícone para indicar navegação
                  onTap: () {
                    setState(() {
                      _registroSelecionado =
                          item; // Define o registro selecionado
                    });
                  },
                ),
              );
            },
          );
  }

  /// **Exibe os detalhes do registro selecionado**
  Widget _buildDetalhesRegistro() {
    final dados = _registroSelecionado!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: dados.entries.map((entry) {
                return _buildInfoRow(entry.key, entry.value);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// **Exibe informações dentro dos Cards**
  Widget _buildInfo(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text('$label: ${value ?? 'Não informado'}',
          style: const TextStyle(fontSize: 14)),
    );
  }

  /// **Exibe informações nos detalhes do registro**
  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text("$label: ${value ?? 'Não informado'}",
          style: const TextStyle(fontSize: 16)),
    );
  }
}
