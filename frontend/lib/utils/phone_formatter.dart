import 'package:flutter/services.dart';

/// Formata número de telefone brasileiro no padrão `(XX) XXXXX-XXXX` durante
/// a digitação. Aceita até 11 dígitos (DDD + 9 dígitos mobile).
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final formatted = _applyMask(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _applyMask(String digits) {
    if (digits.isEmpty) return '';
    final d = digits.length > 11 ? digits.substring(0, 11) : digits;
    final buf = StringBuffer();
    buf.write('(');
    for (var i = 0; i < d.length; i++) {
      buf.write(d[i]);
      if (i == 1 && d.length > 2) buf.write(') ');
      if (i == 6 && d.length > 7) buf.write('-');
    }
    return buf.toString();
  }

  /// Formata dígitos brutos para exibição. Retorna [fallback] se vazio.
  static String formatDisplay(String? raw,
      {String fallback = 'Não informado'}) {
    if (raw == null || raw.isEmpty) return fallback;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return raw;
    return _applyMask(digits);
  }

  /// Remove toda formatação e retorna só os dígitos.
  static String digitsOnly(String formatted) =>
      formatted.replaceAll(RegExp(r'\D'), '');
}
