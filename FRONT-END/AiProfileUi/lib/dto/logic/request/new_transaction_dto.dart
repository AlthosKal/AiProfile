import '../extra/transaction_description.dart';

class NewTransactionDTO {
  final TransactionDescription description;
  final int amount;

  NewTransactionDTO({
    required this.description,
    required this.amount
  });

  Map<String, dynamic> toJson(){
    return {
      'description' : description,
      'amount' : amount,
    };
  }

  factory NewTransactionDTO.fromJson(Map<String, dynamic> json) {
    return NewTransactionDTO(
      description: TransactionDescription.fromJson(json['description']),
      amount: json['amount'],
    );
  }

  static List<Map<String, dynamic>> toListJson(List<NewTransactionDTO> dto){
    return dto.map((t) => t.toJson()).toList();
  }
}