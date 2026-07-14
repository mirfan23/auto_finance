import 'package:flutter/material.dart';

class EmptyTransaction extends StatelessWidget {
  const EmptyTransaction({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 70, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text("Belum ada transaksi", style: TextStyle(fontSize: 17, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
