import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import '../models/transaction.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static sql.Database? _database;
  DbHelper._init();

  Future<sql.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finance.db');
    return _database!;
  }

  Future<sql.Database> _initDB(String filePath) async {
    final dbPath = await sql.getDatabasesPath();
    final path = join(dbPath, filePath);
    return await sql.openDatabase(
      path, 
      version: 2, 
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE transactions ADD COLUMN color INTEGER DEFAULT 4279543167');
        }
      },
    );
  }

  Future _createDB(sql.Database db, int version) async {
    await db.execute('CREATE TABLE transactions (id TEXT PRIMARY KEY, title TEXT, amount REAL, date TEXT, color INTEGER DEFAULT 4279543167)');
  }

  Future<void> insertTransaction(Transaction t) async {
    final db = await instance.database;
    await db.insert('transactions', t.toMap());
  }

  // Mevcut haftanın tüm günlerini (Pzt-Paz) getirir
  Future<List<Map<String, dynamic>>> getWeeklySummary() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query('transactions');

    // İşlemleri grupla
    Map<String, List<Transaction>> grouped = {};
    for (var row in result) {
      String date = row['date'];
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(Transaction.fromMap(row));
    }

    // Mevcut haftanın Pazartesi gününü bul
    DateTime now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));

    List<Map<String, dynamic>> summary = [];
    for (int i = 0; i < 7; i++) {
      DateTime date = monday.add(Duration(days: i));
      String dateStr = date.toIso8601String().split('T')[0];
      
      List<Transaction> items = grouped[dateStr] ?? [];
      double total = items.fold(0, (sum, item) => sum + item.amount);
      
      summary.add({
        'date': dateStr,
        'total': total,
        'items': items,
      });
    }

    return summary;
  }

  // Belirli bir ayın tüm harcamalarını getirir (Heatmap için)
  Future<Map<int, double>> getMonthlySummary(int year, int month) async {
    final db = await instance.database;
    String monthStr = month < 10 ? '0$month' : '$month';
    String start = '$year-$monthStr-01';
    String end = '$year-$monthStr-31';

    final List<Map<String, dynamic>> result = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start, end],
    );

    Map<int, double> dayTotals = {};
    for (var row in result) {
      DateTime date = DateTime.parse(row['date']);
      int day = date.day;
      double amount = (row['amount'] as num).toDouble();
      dayTotals[day] = (dayTotals[day] ?? 0) + amount;
    }
    return dayTotals;
  }

  // Tıklanan günün harcamalarını getiren fonksiyon
  Future<List<Transaction>> getTransactionsByDate(String dateStr) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', where: 'date = ?', whereArgs: [dateStr]);
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<int> updateTransaction(Transaction t) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  Future<int> deleteTransaction(String id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}