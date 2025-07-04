import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../dto/logic/request/update_transaction_dto.dart';
import '../../../dto/logic/rest/get_transaction_dto.dart';
import '../../core/constant/app_constant.dart';
import '../../core/constant/app_theme.dart';
import '../../core/service/app/transaction_service.dart';
import '../../dto/logic/extra/transaction_description.dart';
import '../../widget/custom_card.dart';
import '../../widget/loading_button.dart';

class EditTransactionScreen extends StatefulWidget {
  final int id;
  final GetTransactionDTO original;

  const EditTransactionScreen({
    super.key,
    required this.id,
    required this.original,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType = 'INCOME';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final TransactionService _service = TransactionService();

  @override
  void initState() {
    super.initState();
    final tx = widget.original;
    _nameController.text = tx.description.name;
    _amountController.text = NumberFormat('#,###').format(tx.amount);
    _selectedType = tx.description.type;
    _selectedDate = tx.description.registrationDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dto = UpdateTransactionDTO(
        id: widget.id,
        description: TransactionDescription(
          name: _nameController.text.trim(),
          registrationDate: _selectedDate,
          type: _selectedType,
        ),
        amount: int.parse(_amountController.text.replaceAll(',', '')),
      );

      await _service.updateTransaction(dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Transacción ${_selectedType == 'INCOME' ? 'de ingreso' : 'de gasto'} actualizada exitosamente'),
              ],
            ),
            backgroundColor: context.incomeColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error al actualizar transacción: $e')),
              ],
            ),
            backgroundColor: context.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    if (value.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    if (value.trim().length > 50) {
      return 'El nombre no puede exceder 50 caracteres';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El monto es requerido';
    }
    
    final cleanValue = value.replaceAll(',', '');
    final number = int.tryParse(cleanValue);
    
    if (number == null) {
      return 'Ingrese un número válido';
    }
    if (number <= 0) {
      return 'El monto debe ser mayor a 0';
    }
    if (number > 999999999) {
      return 'El monto es demasiado alto';
    }
    return null;
  }

  void _formatAmount() {
    final text = _amountController.text.replaceAll(',', '');
    if (text.isNotEmpty) {
      final number = int.tryParse(text);
      if (number != null) {
        final formatted = NumberFormat('#,###').format(number);
        _amountController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _selectedType == 'INCOME' 
        ? context.incomeColor 
        : context.expenseColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Transacción'),
        elevation: 0,
        actions: [
          if (!_isLoading)
            TextButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('Actualizar', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppConstants.paddingLarge,
          children: [
            // Header con información original
            _buildOriginalInfoCard(),
            const SizedBox(height: 24),
            
            // Header con tipo de transacción
            _buildTypeSelector(typeColor),
            const SizedBox(height: 24),
            
            // Campos del formulario
            _buildNameField(),
            const SizedBox(height: 20),
            
            _buildAmountField(typeColor),
            const SizedBox(height: 20),
            
            _buildDateField(),
            const SizedBox(height: 32),
            
            // Botón de actualizar
            _buildUpdateButton(typeColor),
            
            const SizedBox(height: 16),
            
            // Información adicional
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildOriginalInfoCard() {
    final original = widget.original;
    final isIncome = original.description.type.toUpperCase() == 'INCOME';
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Transacción Original',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      original.description.name,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeLarge,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(original.description.registrationDate),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: AppConstants.fontSizeSmall,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'}\$${NumberFormat('#,###').format(original.amount)}',
                    style: TextStyle(
                      color: isIncome ? context.incomeColor : context.expenseColor,
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isIncome ? context.incomeColor : context.expenseColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: Text(
                      isIncome ? 'Ingreso' : 'Gasto',
                      style: TextStyle(
                        color: isIncome ? context.incomeColor : context.expenseColor,
                        fontSize: AppConstants.fontSizeSmall,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(Color typeColor) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo de Transacción',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTypeOption(
                  'INCOME',
                  'Ingreso',
                  Icons.trending_up,
                  context.incomeColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTypeOption(
                  'EXPENSE',
                  'Gasto',
                  Icons.trending_down,
                  context.expenseColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(String value, String label, IconData icon, Color color) {
    final isSelected = _selectedType == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: Container(
        padding: AppConstants.paddingMedium,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: AppConstants.iconSizeLarge,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Descripción',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            validator: _validateName,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Nombre de la transacción',
              hintText: 'Ej: Compra de supermercado, Salario, etc.',
              prefixIcon: const Icon(Icons.edit),
              counterText: '${_nameController.text.length}/50',
            ),
            onChanged: (value) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField(Color typeColor) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: typeColor),
              const SizedBox(width: 8),
              const Text(
                'Monto',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            validator: _validateAmount,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              Future.delayed(const Duration(milliseconds: 100), _formatAmount);
            },
            decoration: InputDecoration(
              labelText: 'Monto en pesos',
              hintText: '0',
              prefixIcon: Icon(Icons.attach_money, color: typeColor),
              prefixText: '\$ ',
              suffixText: 'COP',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    final formattedDate = DateFormat('EEEE, d MMMM yyyy').format(_selectedDate);
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Fecha de la Transacción',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            child: Container(
              padding: AppConstants.paddingMedium,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: AppConstants.fontSizeLarge,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Toca para cambiar',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeSmall,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton(Color typeColor) {
    return LoadingButton(
      text: 'Actualizar Transacción',
      isLoading: _isLoading,
      onPressed: _submit,
      backgroundColor: typeColor,
      icon: Icons.save,
    );
  }

  Widget _buildInfoCard() {
    return CustomCard(
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppConstants.fontSizeMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Los cambios se guardarán inmediatamente. Puedes modificar cualquier campo según tus necesidades.',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
