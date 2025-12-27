import 'package:flutter/material.dart';
import '../Widgets/bar_chart_widget.dart';
import '../Services/db_helper.dart';
import '../Models/Transaction.dart';
import '../Widgets/add_transaction_widget.dart';
import '../Widgets/main_drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _summary = [];
  List<Transaction> _selectedDayItems = [];
  String? _selectedDateLabel;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() async {
    final data = await DbHelper.instance.getWeeklySummary();
    setState(() {
      _summary = data;
      _selectedDayItems = [];
      _selectedDateLabel = null;
    });
  }

  void _loadDailyDetails(String dateStr) async {
    final items = await DbHelper.instance.getTransactionsByDate(dateStr);
    setState(() {
      _selectedDayItems = items;
      _selectedDateLabel = dateStr;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Finansım", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      drawer: const MainDrawer(currentRoute: 'home'),
      body: Column(
        children: [
          RepaintBoundary(
            child: WeeklyBarChart(summaryData: _summary, onBarTap: _loadDailyDetails),
          ),
          const Divider(height: 1),
          if (_selectedDateLabel != null)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: _selectedDayItems.length,
                itemBuilder: (ctx, i) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(_selectedDayItems[i].color),
                    radius: 10,
                  ),
                  title: Text(_selectedDayItems[i].title),
                  subtitle: Text(_selectedDayItems[i].date.toIso8601String().split('T')[0]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${_selectedDayItems[i].amount.toInt()} ₺", 
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => AddTransactionWidget(
                            transaction: _selectedDayItems[i],
                            onAdded: () {
                              _refreshData();
                              _loadDailyDetails(_selectedDateLabel!);
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Sil"),
                              content: const Text("Bu harcamayı silmek istediğinize emin misiniz?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("İptal")),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Sil", style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await DbHelper.instance.deleteTransaction(_selectedDayItems[i].id);
                            _refreshData();
                            _loadDailyDetails(_selectedDateLabel!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("Sütunlara tıklayarak detay gör", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black54,
          elevation: 0,
          builder: (ctx) => AddTransactionWidget(onAdded: _refreshData),
        ),
        label: const Text("Yeni Ekle"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }
}