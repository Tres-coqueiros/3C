import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior/data/core/provider/app_provider_departament.dart';
import 'package:senior/data/views/dbo/pages/RegisterPublic_page.dart';
import 'package:senior/data/views/horaextras/pages/list_colaboradores_page.dart';
import 'package:senior/data/views/suprimentos/pages/solicitacoes_list_page.dart';
import 'package:senior/data/views/widgets/base_layout.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';

class SidebarComponents extends StatefulWidget {
  @override
  _SidebarComponentsState createState() => _SidebarComponentsState();
}

class _SidebarComponentsState extends State<SidebarComponents> {
  final Map<String, bool> _submenuExpanded = {};
  final Map<String, Map<String, dynamic>> _departmentData = {
    'Recursos Humanos': {
      'icon': Icons.group_work_rounded,
      'items': {
        'Horas Extras': {
          'icon': Icons.timer_rounded,
          'page': ListColaboradores(),
        },
      },
    },
    'PCM': {
      'icon': Icons.construction_rounded,
      'items': {
        'BDO': {
          'icon': Icons.business_rounded,
          'page': RegisterPublicDBO(),
        },
      },
    },
    'Suprimentos': {
      'icon': Icons.agriculture_rounded,
      'items': {
        'Solicitações de Compras': {
          'icon': Icons.local_shipping_rounded,
          'page': SolicitacoesListPage(),
        },
      },
    },
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: AppColorsComponents.primary,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _departmentData.keys.map((department) {
                    return Column(
                      children: [
                        _buildDepartmentItem(
                          context,
                          _departmentData[department]!['icon'] as IconData,
                          department,
                          _departmentData[department]!['items']
                              as Map<String, dynamic>,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColorsComponents.hashours,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColorsComponents.hashours,
            child: Icon(Icons.business_rounded, color: Colors.white),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Departamentos',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'Selecione uma área',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentItem(
    BuildContext context,
    IconData icon,
    String title,
    Map<String, dynamic> submenuItems,
  ) {
    final isExpanded = _submenuExpanded[title] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _submenuExpanded[title] = !isExpanded),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isExpanded
                  ? const Color.fromARGB(252, 6, 34, 11)
                  : const Color.fromARGB(252, 6, 34, 11),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColorsComponents.hashours,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Padding(
                  padding: EdgeInsets.only(left: 24),
                  child: Column(
                    children: submenuItems.keys.map((item) {
                      return _buildSubmenuItem(
                        context,
                        submenuItems[item]['icon'] as IconData,
                        item,
                        submenuItems[item]['page'] as Widget,
                      );
                    }).toList(),
                  ),
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSubmenuItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return InkWell(
      onTap: () {
        Provider.of<AppProviderDepartament>(context, listen: false)
            .setSelectedDepartament(title);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BaseLayout(body: page),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: const Color.fromARGB(252, 6, 34, 11).withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColorsComponents.hashours, size: 20),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: AppColorsComponents.hashours,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Divider(color: Colors.white.withOpacity(0.12), height: 1),
          SizedBox(height: 12),
          Text(
            'v1.0.0',
            style: TextStyle(
              color: AppColorsComponents.hashours,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
