import '../extra/transaction_description.dart';

class GetTransactionDTO {
  final TransactionDescription description;
  final int amount;

  GetTransactionDTO({required this.description, required this.amount});

  factory GetTransactionDTO.fromJson(Map<String, dynamic> json) {
    return GetTransactionDTO(
      description: TransactionDescription.fromJson(json['description']),
      amount: json['amount'],
    );
  }
}
