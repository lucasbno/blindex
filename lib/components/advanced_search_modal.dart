import 'package:flutter/material.dart';

enum SortCriteria {
  title,
  createdAt,
  updatedAt,
  site,
  login,
}

enum SortOrder {
  ascending,
  descending,
}

class SearchFilters {
  final String query;
  final SortCriteria sortBy;
  final SortOrder sortOrder;
  final bool favoritesOnly;
  final String siteFilter;

  SearchFilters({
    this.query = '',
    this.sortBy = SortCriteria.title,
    this.sortOrder = SortOrder.ascending,
    this.favoritesOnly = false,
    this.siteFilter = '',
  });

  SearchFilters copyWith({
    String? query,
    SortCriteria? sortBy,
    SortOrder? sortOrder,
    bool? favoritesOnly,
    String? siteFilter,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      siteFilter: siteFilter ?? this.siteFilter,
    );
  }
}

class AdvancedSearchModal extends StatefulWidget {
  final SearchFilters initialFilters;
  final Function(SearchFilters) onFiltersChanged;

  const AdvancedSearchModal({
    super.key,
    required this.initialFilters,
    required this.onFiltersChanged,
  });

  @override
  State<AdvancedSearchModal> createState() => _AdvancedSearchModalState();
}

class _AdvancedSearchModalState extends State<AdvancedSearchModal> {
  late SearchFilters _filters;
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _siteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _queryController.text = _filters.query;
    _siteController.text = _filters.siteFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 24),
                  _buildSortSection(),
                  const SizedBox(height: 24),
                  _buildFiltersSection(),
                  const SizedBox(height: 32),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(Icons.tune, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(
            'Filtros Avançados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Termo de Pesquisa',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _queryController,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(query: value);
            });
          },
          decoration: InputDecoration(
            hintText: 'Buscar por título, login ou site...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ordenação',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSortOption('Título', SortCriteria.title),
              _buildDivider(),
              _buildSortOption('Data de Criação', SortCriteria.createdAt),
              _buildDivider(),
              _buildSortOption('Última Modificação', SortCriteria.updatedAt),
              _buildDivider(),
              _buildSortOption('Site', SortCriteria.site),
              _buildDivider(),
              _buildSortOption('Login', SortCriteria.login),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildOrderButton(
                'Crescente',
                SortOrder.ascending,
                Icons.arrow_upward,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOrderButton(
                'Decrescente',
                SortOrder.descending,
                Icons.arrow_downward,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortOption(String title, SortCriteria criteria) {
    final isSelected = _filters.sortBy == criteria;
    return InkWell(
      onTap: () {
        setState(() {
          _filters = _filters.copyWith(sortBy: criteria);
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(title, style: TextStyle(fontSize: 14)),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderButton(String title, SortOrder order, IconData icon) {
    final isSelected = _filters.sortOrder == order;
    return InkWell(
      onTap: () {
        setState(() {
          _filters = _filters.copyWith(sortOrder: order);
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtros',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Apenas Favoritos'),
          subtitle: const Text('Mostrar somente senhas marcadas como favoritas'),
          value: _filters.favoritesOnly,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(favoritesOnly: value);
            });
          },
          activeColor: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _siteController,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(siteFilter: value);
            });
          },
          decoration: InputDecoration(
            labelText: 'Filtrar por Site',
            hintText: 'Ex: gmail.com, facebook.com...',
            prefixIcon: const Icon(Icons.web),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _filters = SearchFilters();
                _queryController.clear();
                _siteController.clear();
              });
            },
            child: const Text('Limpar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onFiltersChanged(_filters);
              Navigator.pop(context);
            },
            child: const Text('Aplicar'),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[300]);
  }

  @override
  void dispose() {
    _queryController.dispose();
    _siteController.dispose();
    super.dispose();
  }
}
