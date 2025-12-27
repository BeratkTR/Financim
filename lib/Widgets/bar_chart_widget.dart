import 'package:flutter/material.dart';
import '../Utils/color_utils.dart';
import '../Models/Transaction.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> summaryData;
  final Function(String) onBarTap;

  const WeeklyBarChart({super.key, required this.summaryData, required this.onBarTap});

  // Tarihi gün ismine çeviren yardımcı fonksiyon
  String _getDayName(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    List<String> days = [
      "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"
    ];
    // weekday 1 (Pazartesi) ile 7 (Pazar) arası döner
    return days[date.weekday - 1];
  }

  int _getWeekday(String dateStr) {
    return DateTime.parse(dateStr).weekday;
  }

  @override
  Widget build(BuildContext context) {
    if (summaryData.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text("Harcama verisi yok")));
    }

    double maxAmount = summaryData.map((e) => e['total'] as double).reduce((a, b) => a > b ? a : b);
    if (maxAmount == 0) maxAmount = 1;

    return Container(
      height: 300, 
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(summaryData.length, (index) {
          final data = summaryData[index];
          double total = data['total'];
          String dateStr = data['date'];
          List<Transaction> items = data['items'] ?? [];
          int weekday = _getWeekday(dateStr);
          
          double totalBarHeight = (total / maxAmount) * 180 + 5;

          return GestureDetector(
            onTap: () => onBarTap(dateStr),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "${total.toInt()}₺", 
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)
                ),
                const SizedBox(height: 5),
                // STACKED BAR:
                Container(
                  width: 35,
                  height: totalBarHeight,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ]
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: items.map((item) {
                        double itemHeight = (item.amount / maxAmount) * 180;
                        return Container(
                          width: double.infinity,
                          height: itemHeight,
                          decoration: BoxDecoration(
                            color: Color(item.color),
                            border: Border(
                              top: BorderSide(color: Colors.white.withOpacity(0.3), width: 0.5),
                            ),
                          ),
                          child: itemHeight > 15 
                            ? Center(
                                child: Text(
                                  "${item.amount.toInt()}", 
                                  style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)
                                )
                              ) 
                            : null,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // GÜN İSMİ BURADA:
                Transform.rotate(
                  angle: -0.3, // Daha az eğim
                  child: Text(
                    _getDayName(dateStr),
                    style: const TextStyle(
                      fontSize: 10, 
                      color: Colors.black87, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}