import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../data/expense_store.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.store});

  final ExpenseStore store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _expenses = [];
  bool _isLoading = true;
  String? _loadError;

  double get _totalExpenses =>
      _expenses.fold(0, (total, expense) => total + expense.amount);

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final expenses = await widget.store.getExpenses();
      if (!mounted) return;
      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      developer.log(
        'Could not load expenses',
        error: error,
        stackTrace: stackTrace,
        name: 'ExpenseTracker',
      );
      if (!mounted) return;
      setState(() {
        _loadError = 'Could not load expenses. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _openAddExpense() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(store: widget.store),
      ),
    );
    if (saved == true && mounted) await _loadExpenses();
  }

  Future<void> _deleteExpense(Expense expense) async {
    try {
      await widget.store.deleteExpense(expense.id);
      if (!mounted) return;
      setState(() {
        _expenses.removeWhere((item) => item.id == expense.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${expense.title} deleted')),
      );
    } catch (error, stackTrace) {
      developer.log(
        'Could not delete expense ${expense.id}',
        error: error,
        stackTrace: stackTrace,
        name: 'ExpenseTracker',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete expense. Please try again.'),
        ),
      );
    }
  }

  String _formatAmount(double amount) => '৳ ${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Tracker',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Card(
                color: theme.colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL EXPENSES',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimary.withValues(
                            alpha: 0.8,
                          ),
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatAmount(_totalExpenses),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Your expenses',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildExpenseList(theme)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExpense,
        tooltip: 'Add expense',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExpenseList(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loadExpenses,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }
    if (_expenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 52,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'No expenses yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text('Tap + to add your first expense.'),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
      itemCount: _expenses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 16, right: 4),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: const Icon(Icons.receipt_long_outlined),
            ),
            title: Text(
              expense.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(_formatAmount(expense.amount)),
            trailing: IconButton(
              tooltip: 'Delete expense',
              onPressed: () => _deleteExpense(expense),
              icon: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
            ),
          ),
        );
      },
    );
  }
}
