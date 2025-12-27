import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/db_helper.dart';
import 'Models/Transaction.dart';
import 'dart:math';

void main() async {
  // Flutter binding'lerini başlat (Asenkron işlemler için şart)
  WidgetsFlutterBinding.ensureInitialized();

  // Veritabanını hazırla ve içine örnek veri ekle
  // await seedData();

  runApp(const FinanceApp());
}

// Test amaçlı sahte veri ekleme fonksiyonu
Future<void> seedData() async {
  final dbHelper = DbHelper.instance;
  
  // Önce veritabanında veri var mı kontrol edelim (Her açılışta eklemesin)
  final summary = await dbHelper.getWeeklySummary();
  
  if (summary.isEmpty) {
    print("Veritabanı boş, örnek veriler ekleniyor...");
    
    // Son 5 gün için rastgele harcamalar oluştur
    for (int i = 0; i < 5; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final randomAmount = (Random().nextInt(1000) + 50).toDouble(); // 50 - 1050 TL arası
      
      await dbHelper.insertTransaction(
        Transaction(
          id: 'test_$i',
          title: 'Harcama $i',
          amount: randomAmount,
          date: date,
        ),
      );
    }
  }
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modüler Finans Uygulaması',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: HomeScreen(), // Ana ekranımızı burada çağırıyoruz
    );
  }
}