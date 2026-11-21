class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
  });

  final int id;
  final String title;
  final double amount;

  factory Expense.fromMap(Map<String, Object?> map) {
    return Expense(
      id: map['id']! as int,
      title: map['title']! as String,
      amount: (map['amount']! as num).toDouble(),
    );
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'title': title, 'amount': amount};
  }
}
