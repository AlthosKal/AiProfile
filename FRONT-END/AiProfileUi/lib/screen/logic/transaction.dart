import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../dto/logic/rest/get_transaction_dto.dart';
import '../../core/constant/app_constant.dart';
import '../../core/service/app/transaction_service.dart';
import '../../route/app_routes.dart';
import '../../widget/custom_search_bar.dart';
import '../../widget/empty_state.dart';
import '../../widget/loading_overlay.dart';
import '../../widget/transaction_title.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TransactionService _transactionService = TransactionService();
  final TextEditingController _searchController = TextEditingController();

  List<GetTransactionDTO> _allTransactions = [];
  List<GetTransactionDTO> _filteredTransactions = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL'; // ALL, INCOME, EXPENSE
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _searchController.addListener(_filterTransactions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    try {
      final data = await _transactionService.getAllTransactions();
      setState(() {
        _allTransactions = data;
        _filteredTransactions = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar transacciones: $e')),
      );
    }
  }

  void _filterTransactions() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredTransactions =
          _allTransactions.where((transaction) {
            final matchesSearch = transaction.description.name
                .toLowerCase()
                .contains(query);

            final matchesType =
                _selectedFilter == 'ALL' ||
                (_selectedFilter == 'INCOME' &&
                    transaction.description.type.toUpperCase() == 'INCOME') ||
                (_selectedFilter == 'EXPENSE' &&
                    transaction.description.type.toUpperCase() == 'EXPENSE');

            final matchesDateRange =
                _selectedDateRange == null ||
                (transaction.description.registrationDate.isAfter(
                      _selectedDateRange!.start,
                    ) &&
                    transaction.description.registrationDate.isBefore(
                      _selectedDateRange!.end.add(const Duration(days: 1)),
                    ));

            return matchesSearch && matchesType && matchesDateRange;
          }).toList();
    });
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      _filterTransactions();
    }
  }

  void _clearDateFilter() {
    setState(() => _selectedDateRange = null);
    _filterTransactions();
  }

  Future<void> _exportTransactions() async {
    if (_filteredTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('No hay transacciones para exportar'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Generando archivo Excel...'),
                    ],
                  ),
                ),
              ),
            ),
      );

      final file = await _transactionService.exportTransactionsToExcel();

      // Cerrar loading
      Navigator.pop(context);

      // Mostrar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Archivo exportado exitosamente',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Guardado en: ${file.path}',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Ver',
            textColor: Colors.white,
            onPressed: () {
              // Aquí podrías abrir el archivo con un package como open_file
              // OpenFile.open(file.path);
            },
          ),
        ),
      );
    } catch (e) {
      // Cerrar loading si está abierto
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error al exportar: $e')),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDelete(GetTransactionDTO transaction, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('¿Eliminar transacción?'),
            content: Text(
              '¿Estás seguro de que deseas eliminar "${transaction.description.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await _transactionService.deleteTransaction(transaction.id);
        setState(() {
          _allTransactions.removeWhere((t) => t.id == transaction.id);
          _filteredTransactions.removeWhere((t) => t.id == transaction.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transacción eliminada exitosamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome = _filteredTransactions
        .where((t) => t.description.type.toUpperCase() == 'INCOME')
        .fold(0, (sum, t) => sum + t.amount);

    final totalExpense = _filteredTransactions
        .where((t) => t.description.type.toUpperCase() == 'EXPENSE')
        .fold(0, (sum, t) => sum + t.amount);

    final balance = totalIncome - totalExpense;

    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Cargando transacciones...',
        child: Column(
          children: [
            // Resumen financiero
            Container(
              padding: AppConstants.paddingMedium,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppConstants.radiusLarge),
                  bottomRight: Radius.circular(AppConstants.radiusLarge),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Balance Total',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${NumberFormat('#,###').format(balance)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Ingresos',
                          amount: totalIncome,
                          color: Colors.green,
                          icon: Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Gastos',
                          amount: totalExpense,
                          color: Colors.red,
                          icon: Icons.trending_down,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Barra de búsqueda
            const SizedBox(height: 16),
            CustomSearchBar(
              controller: _searchController,
              hintText: 'Buscar transacciones...',
              onClear: () => _filterTransactions(),
            ),

            // Filtros
            Container(
              padding: AppConstants.paddingHorizontalMedium,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Todas',
                      isSelected: _selectedFilter == 'ALL',
                      onTap: () {
                        setState(() => _selectedFilter = 'ALL');
                        _filterTransactions();
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Ingresos',
                      isSelected: _selectedFilter == 'INCOME',
                      onTap: () {
                        setState(() => _selectedFilter = 'INCOME');
                        _filterTransactions();
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Gastos',
                      isSelected: _selectedFilter == 'EXPENSE',
                      onTap: () {
                        setState(() => _selectedFilter = 'EXPENSE');
                        _filterTransactions();
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label:
                          _selectedDateRange != null
                              ? '${DateFormat('dd/MM').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM').format(_selectedDateRange!.end)}'
                              : 'Fechas',
                      isSelected: _selectedDateRange != null,
                      onTap: _showDateRangePicker,
                      onClear:
                          _selectedDateRange != null ? _clearDateFilter : null,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Lista de transacciones
            Expanded(
              child:
                  _filteredTransactions.isEmpty
                      ? EmptyState(
                        icon: Icons.receipt_long,
                        title:
                            _allTransactions.isEmpty
                                ? 'No hay transacciones'
                                : 'No se encontraron resultados',
                        subtitle:
                            _allTransactions.isEmpty
                                ? 'Comienza agregando tu primera transacción'
                                : 'Intenta ajustar los filtros de búsqueda',
                        action:
                            _allTransactions.isEmpty
                                ? ElevatedButton.icon(
                                  onPressed: () async {
                                    final created = await Navigator.pushNamed(
                                      context,
                                      AppRoutes.createTransaction,
                                    );
                                    if (created == true) _loadTransactions();
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Crear Transacción'),
                                )
                                : null,
                      )
                      : RefreshIndicator(
                        onRefresh: _loadTransactions,
                        child: ListView.separated(
                          padding: AppConstants.paddingHorizontalMedium,
                          itemCount: _filteredTransactions.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final transaction = _filteredTransactions[index];
                            return TransactionTile(
                              transaction: transaction,
                              onEdit: () async {
                                final updated = await Navigator.pushNamed(
                                  context,
                                  AppRoutes.editTransaction,
                                  arguments: {
                                    'id': transaction.id,
                                    'original': transaction,
                                  },
                                );
                                if (updated == true) _loadTransactions();
                              },
                              onDelete:
                                  () => _confirmDelete(transaction, index),
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón de exportar
          FloatingActionButton(
            heroTag: 'export',
            onPressed: _exportTransactions,
            backgroundColor: Colors.green.shade700,
            child: const Icon(Icons.file_download),
            tooltip: 'Exportar a Excel',
          ),
          const SizedBox(height: 12),
          // Botón principal
          FloatingActionButton.extended(
            heroTag: 'create',
            onPressed: () async {
              final created = await Navigator.pushNamed(
                context,
                AppRoutes.createTransaction,
              );
              if (created == true) _loadTransactions();
            },
            icon: const Icon(Icons.add),
            label: const Text('Nueva'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '\$${NumberFormat('#,###').format(amount)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: AppConstants.fontSizeMedium,
              ),
            ),
            if (isSelected && onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
