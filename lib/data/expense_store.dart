import '../models/expense.dart';

abstract interface class ExpenseStore {
  Future<List<Expense>> getExpenses();

  Future<Expense> addExpense({required String title, required double amount});

  Future<void> deleteExpense(int id);
}
