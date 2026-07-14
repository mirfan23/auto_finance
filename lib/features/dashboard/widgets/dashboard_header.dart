import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;

    String greeting;

    if (hour < 11) {
      greeting = "Selamat Pagi";
    } else if (hour < 15) {
      greeting = "Selamat Siang";
    } else if (hour < 18) {
      greeting = "Selamat Sore";
    } else {
      greeting = "Selamat Malam";
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text("Auto Finance", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
