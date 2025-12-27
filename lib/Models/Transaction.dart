class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final int color; // Renk bilgisini int olarak saklıyoruz

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.color = 0xFF2196F3,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
      'color': color,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    // Renk verisi bazen String olarak dönebilir (SQLite default value hatası vb.)
    int parsedColor = 0xFF2196F3;
    if (map['color'] != null) {
      if (map['color'] is int) {
        parsedColor = map['color'];
      } else if (map['color'] is String) {
        // Eğer 0x ile başlıyorsa hex olarak parse et, yoksa normal parse et
        String colorStr = map['color'].toString();
        if (colorStr.startsWith('0x')) {
          parsedColor = int.parse(colorStr.substring(2), radix: 16);
        } else {
          parsedColor = int.tryParse(colorStr) ?? 0xFF2196F3;
        }
      }
    }

    return Transaction(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Başlıksız',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      color: parsedColor,
    );
  }
}