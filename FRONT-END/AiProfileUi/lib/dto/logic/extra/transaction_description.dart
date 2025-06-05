class TransactionDescription {
  final String name;
  final DateTime registrationDate;
  final String type;

  TransactionDescription({
    required this.name,
    required this.registrationDate,
    required this.type,
  });

  factory TransactionDescription.fromJson(Map<String, dynamic> json) {
    return TransactionDescription(
      name: json['name'],
      registrationDate: DateTime.parse(json['registrationDate']),
      type: json['type'],
    );
  }
}
