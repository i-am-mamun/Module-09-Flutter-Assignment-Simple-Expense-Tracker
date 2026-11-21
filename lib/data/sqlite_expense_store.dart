import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/expense.dart';
import 'expense_store.dart';

class SqliteExpenseStore implements ExpenseStore {
  SqliteExpenseStore._();

  static final instance = SqliteExpenseStore._();

  Future<Database>? _database;

  Future<Database> get _db => _database ??= _openDatabase();

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final databasePath = join(databasesPath, 'expenses.db');

    return openDatabase(
      databasePath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<List<Expense>> getExpenses() async {
    final database = await _db;
    final rows = await database.query('expenses', orderBy: 'id DESC');
    return rows.map(Expense.fromMap).toList();
  }

  @override
  Future<Expense> addExpense({
    required String title,
    required double amount,
  }) async {
    final database = await _db;
    final id = await database.insert('expenses', {
      'title': title,
      'amount': amount,
    });

    return Expense(id: id, title: title, amount: amount);
  }

  @override
  Future<void> deleteExpense(int id) async {
    final database = await _db;
    await database.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
