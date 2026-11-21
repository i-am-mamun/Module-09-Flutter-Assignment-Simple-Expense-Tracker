import 'package:expense_tracker/data/expense_store.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryExpenseStore implements ExpenseStore {
  final List<Expense> _expenses = [];
  int _nextId = 1;

  @override
  Future<Expense> addExpense({
    required String title,
    required double amount,
  }) async {
    final expense = Expense(id: _nextId++, title: title, amount: amount);
    _expenses.add(expense);
    return expense;
  }

  @override
  Future<void> deleteExpense(int id) async {
    _expenses.removeWhere((expense) => expense.id == id);
  }

  @override
  Future<List<Expense>> getExpenses() async => List.of(_expenses);
}

void main() {
  testWidgets('validates, saves, lists, totals, and deletes expenses', (
    tester,
  ) async {
    final store = _MemoryExpenseStore();
    await tester.pumpWidget(ExpenseTrackerApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.text('৳ 0.00'), findsOneWidget);
    expect(find.text('No expenses yet'), findsOneWidget);

    await tester.tap(find.byTooltip('Add expense'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Expense'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter an expense title'), findsOneWidget);
    expect(find.text('Please enter an amount'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Groceries');
    await tester.enterText(find.byType(TextFormField).at(1), '0');
    await tester.tap(find.text('Save Expense'));
    await tester.pumpAndSettle();
    expect(find.text('Amount must be greater than zero'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(1), '125.50');
    await tester.tap(find.text('Save Expense'));
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('৳ 125.50'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Delete expense'));
    await tester.pumpAndSettle();
    expect(find.text('Groceries'), findsNothing);
    expect(find.text('৳ 0.00'), findsOneWidget);
  });
}
