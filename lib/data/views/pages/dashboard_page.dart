import 'package:flutter/material.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'dart:async';
import 'package:table_calendar/table_calendar.dart';

import 'package:senior/data/core/repository/externo_repository.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPage createState() => _DashboardPage();
}

class _DashboardPage extends State<DashboardPage> {
  final GetServices getServices = GetServices();
  final ExternoRepository externoRepository = ExternoRepository();
  final PageController _pageController = PageController(viewportFraction: 0.9);

  Map<String, dynamic> agroDolar = {};
  List<Map<String, dynamic>> agroMatriculas = [];
  List<Map<String, dynamic>> agroCotacoes = [];

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<Map<String, dynamic>>> _feriados = {};
  Map<DateTime, List<Map<String, dynamic>>> _lembretes = {};

  final Map<String, String> codigoParaCidade = {
    'SPZ': 'Sapezal',
    'GNT': 'Gaúcha do Norte',
    'BRN': 'Brasnorte',
  };
  Timer? _timer;
  String usuarioLogado = "";

  @override
  void initState() {
    super.initState();
    fetchMatricula();
    fetchDolar();
    fetchCotacoes();
    fetchFeriados();
    startCarousel();
  }

  void fetchFeriados() async {
    try {
      final List<dynamic> response = await externoRepository.getFeriados();

      setState(() {
        _feriados.clear();
        for (var feriado in response) {
          if (feriado is Map<String, dynamic>) {
            DateTime data = DateTime.utc(
              DateTime.parse(feriado['date']).year,
              DateTime.parse(feriado['date']).month,
              DateTime.parse(feriado['date']).day,
            );
            String nome = feriado['name'];

            _feriados[data] = [
              {'nome': nome, 'tipo': 'feriado'}
            ];
          }
        }
      });
    } catch (error) {
      print('Erro ao carregar feriados: $error');
    }
  }

  void fetchDolar() async {
    try {
      final dolarResult = await externoRepository.getDolar();
      setState(() {
        agroDolar = dolarResult ?? {};
      });
    } catch (error) {
      print('Erro ao buscar dolar: $error');
      setState(() {
        agroDolar = {};
      });
    }
  }

  void fetchMatricula() async {
    try {
      final matriculaResult = await getServices.getLogin();
      if (matriculaResult.isNotEmpty) {
        usuarioLogado = matriculaResult[0]['COLABORADOR'];
      }
      setState(() {
        agroMatriculas = matriculaResult;
      });
    } catch (error) {
      print('Error fetching matricula: $error');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startCarousel() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (_pageController.page == agroCotacoes.length - 1) {
        _pageController.animateToPage(
          0,
          duration: Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.nextPage(
          duration: Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void fetchCotacoes() async {
    try {
      final cotacoesResult = await getServices.getCotacoes();

      setState(() {
        final Map<String, Map<String, dynamic>> ultimasCotacoes = {};

        for (final cotacao in cotacoesResult) {
          final descricao = cotacao['DESCRICAO'].toString().trim();
          final codigo = descricao.split(' ').last;
          final cidade = codigoParaCidade[codigo] ?? 'Outra';
          final produto = descricao.split(' ')[0];
          final dataCotacao =
              DateTime.tryParse(cotacao['DATA'] ?? '') ?? DateTime(2000);

          if (!ultimasCotacoes.containsKey("$cidade-$produto") ||
              dataCotacao.isAfter(DateTime.tryParse(
                      ultimasCotacoes["$cidade-$produto"]?['DATA'] ?? '') ??
                  DateTime(2000))) {
            ultimasCotacoes["$cidade-$produto"] = cotacao;
          }
        }

        final Map<String, List<Map<String, dynamic>>> cotacoesPorCidade = {};

        for (var entry in ultimasCotacoes.entries) {
          final cidadeProduto = entry.key.split('-');
          final cidade = cidadeProduto[0];

          if (!cotacoesPorCidade.containsKey(cidade)) {
            cotacoesPorCidade[cidade] = [];
          }
          cotacoesPorCidade[cidade]!.add(entry.value);
        }
        agroCotacoes = cotacoesPorCidade.entries.map((entry) {
          return {
            'cidade': entry.key,
            'cotacoes': entry.value,
          };
        }).toList();
      });
    } catch (error) {
      print('Erro ao buscar cotações: $error');
      setState(() {
        agroCotacoes = [];
      });
    }
  }

  void _showAddReminderDialog(DateTime selectedDay) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Lembrete'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Digite o lembrete'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _lembretes[selectedDay] = [
                    ...?_lembretes[selectedDay],
                    {'nome': _controller.text, 'tipo': 'lembrete'},
                  ];
                });
                Navigator.pop(context);
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(usuarioLogado),
              const SizedBox(height: 24),
              const SizedBox(height: 24),
              _buildCalendarSection(), // CALENDÁRIO
              const SizedBox(height: 24),
              _buildAgroCarousel(),
              const SizedBox(height: 24),
              _buildDolarCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String usuarioLogado) {
    final partesNome = usuarioLogado.split(' ');
    final nomeFormatado = partesNome.map((parte) {
      if (parte.isEmpty) return parte;
      return parte[0].toUpperCase() + parte.substring(1).toLowerCase();
    }).join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bem-vindo, $nomeFormatado',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Aqui temos algumas informações...',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAgroCarousel() {
    return SizedBox(
      height: 150,
      child: agroCotacoes != null && agroCotacoes.isNotEmpty
          ? PageView.builder(
              controller: _pageController,
              itemCount: agroCotacoes.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final cidade = agroCotacoes[index]['cidade'];
                final cotacoesCidade = agroCotacoes[index]['cotacoes'];
                if (cotacoesCidade == null || cotacoesCidade.isEmpty) {
                  return Center(
                      child: Text('Nenhuma cotação disponível para $cidade'));
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cidade,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getColorByCidade(cidade),
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: cotacoesCidade.length,
                        itemBuilder: (context, i) {
                          final cotacao = cotacoesCidade[i];
                          return _buildInfoCard(
                            icon: Icons.agriculture,
                            title: cotacao['DESCRICAO'].toString().trim(),
                            value:
                                'R\$ ${cotacao['COTACAO'].toStringAsFixed(2)}',
                            color: _getColorByCidade(cidade),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Color _getColorByCidade(String cidade) {
    switch (cidade) {
      case 'Sapezal':
        return Colors.green;
      case 'Gaúcha do Norte':
        return Colors.blue;
      case 'Brasnorte':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDolarCard() {
    return agroDolar.isNotEmpty && agroDolar['high'] != null
        ? _buildInfoCard(
            icon: Icons.monetization_on,
            title: 'Cotação Dólar',
            value:
                'R\$ ${(double.tryParse(agroDolar['high'].toString()) ?? 0.0).toStringAsFixed(2)}',
            color: Colors.blueAccent,
          )
        : _buildInfoCard(
            icon: Icons.monetization_on,
            title: 'Cotação Dólar',
            value: 'R\$ 0.00',
            color: Colors.blueAccent,
          );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Ícone à esquerda
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 12),
            // Texto (Título e Valor)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// --- AQUI ESTÁ O CÓDIGO DO CALENDÁRIO MODIFICADO ---
  Widget _buildCalendarSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar(
          // Intervalo de datas suportadas
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          // Dia selecionado e callback
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _showAddReminderDialog(selectedDay);
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          // Carregamos feriados + lembretes
          eventLoader: (day) {
            final eventos = [
              ...?_feriados[day],
              ...?_lembretes[day],
            ];
            return eventos;
          },
          // Estilização do calendário
          calendarStyle: CalendarStyle(
            // Tira a cor de fundo do "hoje", deixa apenas negrito no texto
            todayDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            todayTextStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),

            // Dia selecionado (círculo azul)
            selectedDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),

            // Marcadores (pontinhos de evento)
            markersAutoAligned: false,
            markersOffset: const PositionedOffset(bottom: 6),
            markersAlignment: Alignment.center,
            markerSize: 6,
            markerMargin: const EdgeInsets.symmetric(horizontal: 1.5),
            markerDecoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),

            // Dias fora do mês ainda visíveis
            outsideDaysVisible: true,
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible:
                false, // Não exibe botão de formato (semana/mês)
            titleCentered: true, // Centraliza o título (Mês/Ano)
            leftChevronIcon: Icon(Icons.chevron_left, size: 28),
            rightChevronIcon: Icon(Icons.chevron_right, size: 28),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekendStyle: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
