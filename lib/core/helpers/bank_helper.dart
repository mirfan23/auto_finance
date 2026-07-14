import 'package:flutter/material.dart';

class BankHelper {
  static String title(String bank) {
    switch (bank.toLowerCase()) {
      case "bca":
        return "BCA";

      case "jago":
        return "Bank Jago";

      case "gopay":
        return "GoPay";

      case "shopeepay":
        return "ShopeePay";

      case "ovo":
        return "OVO";

      case "dana":
        return "DANA";

      case "seabank":
        return "SeaBank";

      case "mandiri":
        return "Mandiri";

      case "bni":
        return "BNI";

      case "bri":
        return "BRI";

      default:
        return bank;
    }
  }

  static Color color(String bank) {
    switch (bank.toLowerCase()) {
      case "bca":
        return const Color(0xff005AAA);

      case "jago":
        return const Color(0xffFF6B00);

      case "gopay":
        return const Color(0xff00AED6);

      case "shopeepay":
        return const Color(0xffEE4D2D);

      case "ovo":
        return const Color(0xff4C2A86);

      case "dana":
        return const Color(0xff008CEB);

      case "seabank":
        return const Color(0xffF7A600);

      case "mandiri":
        return const Color(0xff003D79);

      case "bni":
        return const Color(0xffF37021);

      case "bri":
        return const Color(0xff00529C);

      default:
        return Colors.grey;
    }
  }

  static IconData icon(String bank) {
    switch (bank.toLowerCase()) {
      case "gopay":
      case "shopeepay":
      case "ovo":
      case "dana":
        return Icons.account_balance_wallet_rounded;

      default:
        return Icons.account_balance_rounded;
    }
  }
}
