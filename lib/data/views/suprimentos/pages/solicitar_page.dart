import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/core/repository/exceptions_network.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:senior/data/views/widgets/components/app_text_components.dart';
import 'package:senior/data/views/widgets/components/button_components.dart';
import 'package:senior/data/views/widgets/components/search_components.dart';

class SolicitarPage extends StatefulWidget {
  @override
  _SolicitarPageState createState() => _SolicitarPageState();
}

class _SolicitarPageState extends State<SolicitarPage> {
  final GetServices getServices = GetServices();
  final PostServices postServices = PostServices();

  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> getGestor = [];

  DateTime? _deadlineDate; // Armazena a data limite escolhida
  String _nivelEspera = ''; // Pode ser "EMERGENCIAL", "URGENTE" ou "NORMAL"

  TextEditingController materialCtrl = TextEditingController(),
      groupCtrl = TextEditingController(),
      quantCtrl = TextEditingController(),
      localCtrl = TextEditingController(),
      pcoCtrl = TextEditingController(),
      qtdCompradaCtrl = TextEditingController();

  List<Map<String, dynamic>> getMaterialSolicitacao = [],
      getMatricula = [],
      selectedLocais = [];
  int? localSelecionado, materialSelecionado;
  String usuario = '';
  int? matricula;

  String gestor = '';
  int gestorId = 0;

  @override
  void initState() {
    super.initState();
    fetchSolicitarMaterial();
    fetchMatricula();
    fetchGestor();
  }

  void fetchGestor() async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final result = await getServices.getGestor();
      if (result.isNotEmpty) {
        gestor = result[0]['GESTOR'];
        gestorId = result[0]['GESTOR_ID'];
      }
      setState(() => getGestor = result);
    } catch (error) {
      ErrorNotifier.showError('Erro ao buscar gestor: $error');
    }
  }

  /// Calcula o nível de espera de acordo com a data limite
  String _calculateWaitLevel(DateTime deadline) {
    final now = DateTime.now();
    final diffDays = deadline.difference(now).inDays;

    if (diffDays <= 0) return 'EMERGENCIAL'; // Mesmo dia ou já passou
    if (diffDays <= 3) return 'URGENTE'; // Até 3 dias
    return 'NORMAL'; // Mais de 3 dias
  }

  /// Formata data no padrão dd/MM/yyyy
  String _formatDateTime(DateTime dt) {
    final dia = dt.day.toString().padLeft(2, '0');
    final mes = dt.month.toString().padLeft(2, '0');
    final ano = dt.year;
    return '$dia/$mes/$ano';
  }

  /// Abre o DatePicker para escolher a data limite
  void _pickDeadlineDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _deadlineDate ?? now,
      firstDate: now, // não permite data anterior a hoje
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() {
        _deadlineDate = selected;
        _nivelEspera = _calculateWaitLevel(selected);
      });
    }
  }

  /// Cria um map com os dados do produto a ser adicionado
  Map<String, dynamic> _createProductData() => {
        'MATERIAL': materialCtrl.text,
        'GRUPO': groupCtrl.text,
        'QUANTIDADE': quantCtrl.text,
        'LOCAL': localCtrl.text,
        'PCOMEDIO': pcoCtrl.text,
        'QUANTIDADE_ASER_COMPRADA': qtdCompradaCtrl.text,
        'IS_OUTRA_UNIDADE': false,
        'DATA_LIMITE': _deadlineDate?.toIso8601String(),
        'NIVEL_ESPERA': _nivelEspera.isEmpty ? null : _nivelEspera,
      };

  /// Adiciona o produto, evitando duplicados (mesmo MATERIAL + LOCAL)
  void _addProduct() {
    if (_formKey.currentState!.validate()) {
      final data = _createProductData();
      // Cria uma "chave" para verificar duplicados (material+local)
      final itemKey = '${data['MATERIAL']}_${data['LOCAL']}';

      final alreadyExists = products.any((p) {
        final key = '${p['MATERIAL']}_${p['LOCAL']}';
        return key == itemKey;
      });

      if (alreadyExists) {
        // Já existe esse material+local na lista
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Esse item já foi adicionado.')),
        );
        return;
      }

      // Caso não exista, adiciona
      setState(() {
        products.add(data);
      });

      // Limpa campos
      materialCtrl.clear();
      groupCtrl.clear();
      quantCtrl.clear();
      qtdCompradaCtrl.clear();
      localCtrl.clear();
      pcoCtrl.clear();
      localSelecionado = null;
      materialSelecionado = null;

      // Verifica unidades alternativas
      final currentMat = materialSelecionado;
      final currentLoc = data['LOCAL'] ?? '';
      if (currentMat != null && currentMat > 0) {
        _checarLocaisAlternativos(currentMat, currentLoc.toString());
      }
    }
  }

  /// Verifica se há outras unidades disponíveis para esse material
  void _checarLocaisAlternativos(int materialId, String localAtual) {
    final locaisAlt = getLocaisByMaterial(materialId).where((loc) {
      final saldo = loc['SALDO'] ?? 0;
      // Exibe somente se for diferente do local atual e tiver saldo > 0
      return loc['LOCAIS'] != localAtual && saldo > 0;
    }).toList();

    if (locaisAlt.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false, // Impede fechar ao clicar fora
        builder: (_) => AlertDialog(
          title: const Text('Material disponível em outra unidade'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Selecione a quantidade que deseja requisitar de cada local:',
                ),
                const SizedBox(height: 16),
                for (var local in locaisAlt) _buildLocalAlternativoTile(local),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    }
  }

  /// Card de cada local alternativo
  Widget _buildLocalAlternativoTile(Map<String, dynamic> local) {
    final qtdController = TextEditingController();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    local['LOCAIS']?.toString().toUpperCase() ?? 'UNIDADE',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.location_on_outlined,
                      color: Colors.green.shade300),
                ],
              ),
              const Divider(thickness: 1.2),

              // Infos
              _buildInfo('Material', local['MATERIAL']),
              _buildInfo('Grupo', local['GRUPO']),
              _buildInfo('Saldo disponível', local['SALDO']),
              if (local['PCOMEDIO'] != null)
                _buildInfo('Preço Médio', local['PCOMEDIO']),

              const SizedBox(height: 12),
              TextFormField(
                controller: qtdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade a pedir',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Botão "Adicionar deste local"
              Align(
                alignment: Alignment.centerRight,
                child: ButtonComponents(
                  textAlign: Alignment.center,
                  onPressed: () {
                    final qtd = double.tryParse(qtdController.text) ?? 0;
                    if (qtd <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Digite uma quantidade válida')),
                      );
                      return;
                    }

                    // Cria chave para evitar duplicado
                    final itemKey = '${local['MATERIAL']}_${local['LOCAIS']}';
                    final alreadyExists = products.any((p) {
                      final key = '${p['MATERIAL']}_${p['LOCAL']}';
                      return key == itemKey;
                    });
                    if (alreadyExists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Esse item já foi adicionado.')),
                      );
                      return;
                    }

                    setState(() {
                      products.add({
                        'MATERIAL': local['MATERIAL'],
                        'GRUPO': local['GRUPO'],
                        'LOCAL': local['LOCAIS'],
                        'QUANTIDADE': local['SALDO'].toString(),
                        'PCOMEDIO': local['PCOMEDIO']?.toString() ?? '0',
                        'QUANTIDADE_ASER_COMPRADA': qtd.toString(),
                        'IS_OUTRA_UNIDADE': true,
                        // Reaproveita data limite e nível de espera
                        'DATA_LIMITE': _deadlineDate?.toIso8601String(),
                        'NIVEL_ESPERA':
                            _nivelEspera.isEmpty ? null : _nivelEspera,
                      });
                    });
                    Navigator.of(context).pop();
                  },
                  text: 'Adicionar deste local',
                  textColor: Colors.white,
                  backgroundColor: AppColorsComponents.primary,
                  fontSize: 16,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  icon: Icons.add,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(String label, dynamic value) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          '$label: ${value ?? 'N/A'}',
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
        ),
      );

  /// Envia a solicitação
  void addSubmit() async {
    if (products.isEmpty) {
      ErrorNotifier.showError("Adicione pelo menos um item antes de enviar.");
      return;
    }
    final data = {
      "usuario": usuario,
      "usuario_id": matricula,
      "data_solicitacao": DateTime.now().toIso8601String(),
      "itens": products
          .map((mat) => {
                "produto": mat['MATERIAL'],
                "quantidade": mat['QUANTIDADE_ASER_COMPRADA'],
                "preco_unitario": mat['PCOMEDIO'],
                "subtotal": (double.tryParse(
                            mat['QUANTIDADE_ASER_COMPRADA'].toString()) ??
                        0) *
                    (double.tryParse(mat['PCOMEDIO'].toString()) ?? 0),
                "local": mat['LOCAL'],
                "grupo": mat['GRUPO'],
                "is_outra_unidade": mat['IS_OUTRA_UNIDADE'] ?? false,
                "data_limite": mat['DATA_LIMITE'],
                "nivel_espera": mat['NIVEL_ESPERA'],
              })
          .toList(),
    };
    try {
      print('Enviando dados: $data');
      final success = await postServices.postSolicitacao(data);
      if (success) {
        context.go('/solicitacao');
      } else {
        ErrorNotifier.showError("Erro ao enviar pedido.");
      }
    } catch (e) {
      ErrorNotifier.showError("Erro ao enviar pedido: $e");
    }
  }

  /// Busca informações do usuário logado
  void fetchMatricula() async {
    try {
      final res = await getServices.getLogin();
      if (res.isNotEmpty) {
        usuario = res[0]['nomfun'];
        matricula = res[0]['numcad'];
      }
      setState(() => getMatricula = res);
    } catch (err) {
      ErrorNotifier.showError("Erro ao buscar matricula: $err");
    }
  }

  /// Busca materiais disponíveis
  void fetchSolicitarMaterial() async {
    try {
      final res = await getServices.getMaterialSolicitacao();
      setState(() => getMaterialSolicitacao = res);
    } catch (err) {
      ErrorNotifier.showError("Erro ao buscar gestor: $err");
    }
  }

  /// Retorna todos os locais de um determinado material
  List<Map<String, dynamic>> getLocaisByMaterial(int id) =>
      getMaterialSolicitacao
          .where((mat) => mat['ID_MATERIAL'] == id)
          .map((m) => {
                'ID_MATERIAL': m['ID_MATERIAL'],
                'MATERIAL': m['MATERIAL'],
                'GRUPO': m['GRUPO'],
                'LOCAIS': m['LOCAIS'],
                'SALDO': m['SALDO'],
                'PCOMEDIO': m['PCOMEDIO'],
              })
          .toList();

  /// Retorna materiais únicos (sem duplicar ID_MATERIAL)
  List<Map<String, dynamic>> getUniqueMaterials() {
    final seen = <int>{};
    return getMaterialSolicitacao
        .where((mat) {
          final id = mat['ID_MATERIAL'];
          if (id is int) return seen.add(id);
          if (id is String) {
            final parsed = int.tryParse(id);
            if (parsed != null) return seen.add(parsed);
          }
          return false;
        })
        .map((m) => {
              'ID_MATERIAL': m['ID_MATERIAL'],
              'MATERIAL': m['MATERIAL'],
              'GRUPO': m['GRUPO'],
              'SUBGRUPO': m['SUBGRUPO'],
              'SALDO': m['SALDO'],
              'PCOMEDIO': m['PCOMEDIO'],
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (ctx, ct) {
        final isMobile = ct.maxWidth < 800;
        return Padding(
          padding: const EdgeInsets.all(12), // Menor espaçamento
          child: isMobile ? _buildMobileLayout() : _buildWebLayout(),
        );
      }),
    );
  }

  /// Layout Mobile
  Widget _buildMobileLayout() => SingleChildScrollView(
        child: Column(
          children: [
            _buildForm(),
            const SizedBox(height: 16), // Menor espaçamento
            _buildProductList(),
            const SizedBox(height: 16),
            _buildSubmitButton(),
          ],
        ),
      );

  /// Layout Web
  Widget _buildWebLayout() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _buildForm()),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProductList(),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildSubmitButton(),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  /// Form principal, com espaçamentos reduzidos
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Código do Material
          const Text(
            "Código do Material",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          SearchableDropdown(
            items: getUniqueMaterials(),
            itemLabel: (m) => m['ID_MATERIAL'].toString(),
            onItemSelected: (m) {
              setState(() {
                materialSelecionado = m['ID_MATERIAL'];
                selectedLocais = getLocaisByMaterial(materialSelecionado!);
                groupCtrl.text = m['GRUPO'].toString();
                materialCtrl.text = m['MATERIAL'].toString();
              });
            },
            labelText: "Selecione o Código do Material",
            hintText: "Selecione o Código do Material",
          ),
          const SizedBox(height: 12),

          // Material
          const Text(
            "Material",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          AppTextComponents(
            label: '',
            controller: materialCtrl,
            hint: 'Material',
            readOnly: true,
          ),
          const SizedBox(height: 12),

          // Grupo
          const Text(
            "Grupo de Material",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          AppTextComponents(
            label: '',
            controller: groupCtrl,
            hint: 'Grupo de Material',
            readOnly: true,
          ),
          const SizedBox(height: 12),

          // Local
          const Text(
            "Local",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          SearchableDropdown(
            items: selectedLocais,
            itemLabel: (l) => l['LOCAIS'],
            onItemSelected: (l) {
              setState(() {
                localCtrl.text = l['LOCAIS'].toString();
                quantCtrl.text = l['SALDO'].toString();
                pcoCtrl.text = l['PCOMEDIO'].toString();
              });
            },
            labelText: "Selecione o Local",
            hintText: "Selecione o Local",
          ),
          const SizedBox(height: 12),

          // Linha Quantidade e Preço Médio
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Quantidade",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    AppTextComponents(
                      label: '',
                      controller: quantCtrl,
                      hint: 'Quantidade',
                      readOnly: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Preço Médio",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    AppTextComponents(
                      label: '',
                      controller: pcoCtrl,
                      hint: 'Preço Médio',
                      readOnly: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Linha Qtd a comprar, Data Limite e Botão
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Qtd a comprar
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Qtd a comprar",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    AppTextComponents(
                      label: '',
                      hint: 'Digite',
                      controller: qtdCompradaCtrl,
                      isRequired: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Data Limite
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Limite',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: _pickDeadlineDate,
                      child: Container(
                        height: 50,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.date_range, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              _deadlineDate == null
                                  ? 'Data Limite'
                                  : _formatDateTime(_deadlineDate!),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Botão "+"
              SizedBox(
                height: 50,
                child: ButtonComponents(
                  textAlign: Alignment.center,
                  onPressed: _addProduct,
                  textColor: Colors.white,
                  backgroundColor: AppColorsComponents.primary,
                  fontSize: 16,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  icon: Icons.add,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Exibe nível de espera, se calculado
          if (_nivelEspera.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Nível de Espera: $_nivelEspera',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _nivelEspera == 'EMERGENCIAL'
                      ? Colors.red
                      : (_nivelEspera == 'URGENTE'
                          ? Colors.orange
                          : Colors.green),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Lista de produtos adicionados
  Widget _buildProductList() {
    if (products.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text(
              'Nenhum produto adicionado ainda',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Text(
            'ITENS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (ctx, i) {
              final mat = products[i];
              final isOutraUn = mat['IS_OUTRA_UNIDADE'] == true;
              final dataLimite = mat['DATA_LIMITE'];
              final nivelEsp = mat['NIVEL_ESPERA'];

              return SizedBox(
                width: 320,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  shadowColor: Colors.grey.withOpacity(0.3),
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isOutraUn)
                          Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.deepPurple.shade300,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  mat['LOCAL']?.toString().toUpperCase() ??
                                      'LOCAL',
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          mat['MATERIAL']?.toString() ?? 'Desconhecido',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoText('Grupo', mat['GRUPO']),
                        _buildInfoText('Saldo', mat['QUANTIDADE']),
                        _buildInfoText('Preço Médio', mat['PCOMEDIO']),
                        _buildInfoText(
                            'Qtd. a comprar', mat['QUANTIDADE_ASER_COMPRADA']),
                        _buildInfoText('Local', mat['LOCAL']),
                        if (dataLimite != null)
                          _buildInfoText(
                            'Data Limite',
                            _formatDateTime(DateTime.parse(dataLimite)),
                          ),
                        if (nivelEsp != null)
                          _buildInfoText('Nível Espera', nivelEsp),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoText(String label, dynamic value) => Text(
        '$label: ${value?.toString() ?? 'N/A'}',
        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
      );

  Widget _buildSubmitButton() {
    return ButtonComponents(
      textAlign: Alignment.center,
      onPressed: addSubmit,
      text: 'Solicitar Compra',
      textColor: Colors.white,
      backgroundColor: AppColorsComponents.primary,
      fontSize: 18,
      padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 12),
    );
  }
}
