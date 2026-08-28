import 'package:flutter/foundation.dart';

enum AppCurrency {
  jmd,
  usd,
  gbp,
  cad,
}

extension AppCurrencyExtension on AppCurrency {
  String get symbol {
    switch (this) {
      case AppCurrency.jmd: return 'J\$';
      case AppCurrency.usd: return 'US\$';
      case AppCurrency.gbp: return '£';
      case AppCurrency.cad: return 'CA\$';
    }
  }

  String get label {
    switch (this) {
      case AppCurrency.jmd: return 'Jamaican Dollar (J\$)';
      case AppCurrency.usd: return 'US Dollar (US\$)';
      case AppCurrency.gbp: return 'British Pound (£)';
      case AppCurrency.cad: return 'Canadian Dollar (CA\$)';
    }
  }

  String get code {
    switch (this) {
      case AppCurrency.jmd: return 'JMD';
      case AppCurrency.usd: return 'USD';
      case AppCurrency.gbp: return 'GBP';
      case AppCurrency.cad: return 'CAD';
    }
  }

  String format(double amount) => '$symbol${amount.toStringAsFixed(2)}';
  String formatNoDecimal(double amount) => '$symbol${amount.toStringAsFixed(0)}';
}

class CurrencyService {
  CurrencyService._();
  static final CurrencyService instance = CurrencyService._();

  final ValueNotifier<AppCurrency> currency = ValueNotifier(AppCurrency.jmd);

  void setCurrency(AppCurrency c) => currency.value = c;

  String format(double amount) => currency.value.format(amount);
  String formatNoDecimal(double amount) => currency.value.formatNoDecimal(amount);
  String get symbol => currency.value.symbol;
}
