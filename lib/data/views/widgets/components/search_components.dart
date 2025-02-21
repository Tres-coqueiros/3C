import 'package:flutter/material.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T> onItemSelected;
  final String labelText;
  final String hintText;

  const SearchableDropdown({
    Key? key,
    required this.items,
    required this.itemLabel,
    required this.onItemSelected,
    this.labelText = "Pesquisar",
    this.hintText = "Digite para pesquisar",
  }) : super(key: key);

  @override
  _SearchableDropdownState<T> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<T> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredItems = widget.items
          .where((item) => widget.itemLabel(item).toLowerCase().contains(query))
          .toList();
    });

    if (_searchController.text.isEmpty) {
      // Se o campo estiver vazio, remova o overlay
      _removeOverlay();
    } else {
      // Se o texto não estiver vazio, mostre o overlay se necessário
      if (_overlayEntry == null) {
        _showOverlay();
      }
    }
  }

  void _showOverlay() {
    final overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 39,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            elevation: 4,
            child: GestureDetector(
              // Fecha o overlay quando clicar fora
              onTap: _removeOverlay,
              child: Container(
                height: 200,
                color: Colors.white,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return ListTile(
                      title: Text(widget.itemLabel(item)),
                      onTap: () {
                        _searchController.text = widget.itemLabel(item);
                        widget.onItemSelected(item);
                        _removeOverlay();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        // Detecta clique fora do widget para fechar o overlay
        onTap: _removeOverlay,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: widget.labelText,
                hintText: widget.hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColorsComponents.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                prefixIcon:
                    Icon(Icons.search, color: AppColorsComponents.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
