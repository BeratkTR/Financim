import 'package:flutter/material.dart';
import '../Models/Transaction.dart';
import '../Services/db_helper.dart';
import '../Utils/color_utils.dart';

class AddTransactionWidget extends StatefulWidget {
  final VoidCallback onAdded;
  final Transaction? transaction;

  const AddTransactionWidget({super.key, required this.onAdded, this.transaction});

  @override
  State<AddTransactionWidget> createState() => _AddTransactionWidgetState();
}

class _AddTransactionWidgetState extends State<AddTransactionWidget> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction?.title);
    _amountController = TextEditingController(text: widget.transaction?.amount.toInt().toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        bottom: bottomInset + 20, 
        top: 20, 
        left: 20, 
        right: 20
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20), // DÜZELTİLDİ: .bottom -> .only(bottom: 20)
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            widget.transaction == null ? "Yeni Harcama" : "Harcamayı Düzenle",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Başlık',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Miktar',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.attach_money),
              suffixText: '₺',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // DÜZELTİLDİ: RoundedRectangleBorder eklendi
                elevation: 0,
              ),
              onPressed: () async {
                final title = _titleController.text.trim();
                final amount = double.tryParse(_amountController.text);
                
                if (title.isEmpty || amount == null) return;
                
                if (widget.transaction == null) {
                  final randomColor = ColorUtils.getRandomColor().value;
                  await DbHelper.instance.insertTransaction(Transaction(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: title,
                    amount: amount,
                    date: DateTime.now(),
                    color: randomColor,
                  ));
                } else {
                  await DbHelper.instance.updateTransaction(Transaction(
                    id: widget.transaction!.id,
                    title: title,
                    amount: amount,
                    date: widget.transaction!.date,
                    color: widget.transaction!.color,
                  ));
                }
                
                widget.onAdded();
                if (mounted) Navigator.pop(context);
              },
              child: Text(
                widget.transaction == null ? "Ekle" : "Güncelle", 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ],
      ),
    );
  }
}