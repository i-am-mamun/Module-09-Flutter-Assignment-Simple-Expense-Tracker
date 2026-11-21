import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'
    show databaseFactoryFfiWeb;

import 'data/expense_store.dart';
import 'data/sqlite_expense_store.dart';
import 'screens/home_screen.dart';

void main() {
  if (kIsWeb) databaseFactory = databaseFactoryFfiWeb;
  runApp(ExpenseTrackerApp(store: SqliteExpenseStore.instance));
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key, required this.store});

  final ExpenseStore store;

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF167D65);

    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          surface: const Color(0xFFF7F9F8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F9F8),
          foregroundColor: Color(0xFF182A25),
          centerTitle: false,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(store: store),
    );
  }
}
