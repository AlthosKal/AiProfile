import '../extra/transaction_description.dart';

class GetTransactionDTO {
  final int id;
  final TransactionDescription description;
  final int amount;

  GetTransactionDTO({
    required this.id,
    required this.description,
    required this.amount,
  });

  factory GetTransactionDTO.fromJson(Map<String, dynamic> json) {
    return GetTransactionDTO(
      id: json['id'],
      description: TransactionDescription.fromJson(json['description']),
      amount: json['amount'],
    );
  }
}
