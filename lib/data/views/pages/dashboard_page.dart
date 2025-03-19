import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'dart:async';

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
  List<Map<String, dynamic>> agroCotacoes = [];
  final Map<String, String> codigoParaCidade = {
    'SPZ': 'Sapezal',
    'GNT': 'Gaúcha do Norte',
    'BRN': 'Brasnorte',
  };
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchDolar();
    fetchCotacoes();
    _startCarousel();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCarousel() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.page == agroCotacoes.length - 1) {
        _pageController.animateToPage(
          0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void fetchCotacoes() async {
    try {
      final cotacoesResult = await getServices.getCotacoes();
      setState(() {
        final Map<String, List<Map<String, dynamic>>> cotacoesPorCidade = {};
        for (final cotacao in cotacoesResult) {
          final descricao = cotacao['DESCRICAO'].toString().trim();
          final codigo = descricao.split(' ').last;
          final cidade = codigoParaCidade[codigo] ?? 'Outra';

          if (!cotacoesPorCidade.containsKey(cidade)) {
            cotacoesPorCidade[cidade] = [];
          }
          cotacoesPorCidade[cidade]!.add(cotacao);
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

  Future<void> fetchDolar() async {
    try {
      final dolarResult = await externoRepository.getDolar();
      setState(() {
        agroDolar = dolarResult ?? {};
      });
      print('dolarResult $dolarResult');
    } catch (error) {
      print('Erro ao buscar cotações: $error');
      setState(() {
        agroDolar = {};
      });
    }
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
              _buildHeader(),
              const SizedBox(height: 24),
              // _buildInfoRow(),
              const SizedBox(height: 24),
              // Gráfico Mensal ao centro
              _buildChartSection(),
              const SizedBox(height: 24),
              // Carrossel de cotações agro
              _buildAgroCarousel(),
              const SizedBox(height: 24),
              // Card do dólar em tempo real
              _buildDolarCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bem-vindo, Usuário!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Aqui está o resumo do seu dia.',
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
      margin: const EdgeInsets.symmetric(vertical: 4), // Ajuste de espaçamento
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

  /// Seção do gráfico mensal
  Widget _buildChartSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Desempenho Mensal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChartSample2(),
            ),
          ],
        ),
      ),
    );
  }
}

class LineChartSample2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: const Color(0xff37434d),
            width: 1,
          ),
        ),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 6,
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3),
              FlSpot(1, 1),
              FlSpot(2, 4),
              FlSpot(3, 2),
              FlSpot(4, 5),
              FlSpot(5, 3),
              FlSpot(6, 4),
            ],
            isCurved: true,
            color: Colors.blue,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
