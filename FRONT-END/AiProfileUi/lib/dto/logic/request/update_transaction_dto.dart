import 'dart:ffi';

import '../extra/transaction_description.dart';

class UpdateTransactionDTO {
  final Long id;
  final TransactionDescription description;
  final int amount;

  UpdateTransactionDTO({
    required this.id,
    required this.description,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'description': description, 'amount': amount};
  }
}
