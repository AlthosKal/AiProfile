import 'package:ai_profile_ui/core/constant/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constant/app_constant.dart';
import '../dto/logic/rest/get_transaction_dto.dart';
import 'custom_card.dart';

class TransactionTile extends StatelessWidget {
  final GetTransactionDTO transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const TransactionTile({
    Key? key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final desc = transaction.description;
    final isIncome = desc.type.toUpperCase() == 'INCOME';
    final amountColor = isIncome ? context.incomeColor : context.expenseColor;

    return CustomCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          // Icono de transacción
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(
              isIncome ? Icons.trending_up : Icons.trending_down,
              color: amountColor,
              size: AppConstants.iconSizeLarge,
            ),
          ),

          const SizedBox(width: 12),

          // Información de la transacción
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  desc.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: AppConstants.iconSizeSmall,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(desc.registrationDate),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: amountColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusSmall,
                        ),
                      ),
                      child: Text(
                        isIncome ? 'Ingreso' : 'Gasto',
                        style: TextStyle(
                          color: amountColor,
                          fontSize: AppConstants.fontSizeSmall,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Monto
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}\$${NumberFormat('#,###').format(transaction.amount)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Botones de acción
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    _ActionButton(
                      icon: Icons.edit,
                      onPressed: onEdit!,
                      color: Colors.blue,
                      tooltip: 'Editar',
                    ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 4),
                    _ActionButton(
                      icon: Icons.delete,
                      onPressed: onDelete!,
                      color: Colors.red,
                      tooltip: 'Eliminar',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: AppConstants.iconSizeSmall, color: color),
          ),
        ),
      ),
    );
  }
}
