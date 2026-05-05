class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.length < 3) {
      return 'Nome deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
      return 'Telefone inválido (10 ou 11 dígitos)';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Endereço é obrigatório';
    }
    if (value.length < 10) {
      return 'Endereço deve ser mais completo';
    }
    return null;
  }

  static String? validateBirthDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Data de nascimento é obrigatória';
    }
    try {
      final date = DateTime.parse(value);
      final today = DateTime.now();
      final age = today.year - date.year - (today.month < date.month || (today.month == date.month && today.day < date.day) ? 1 : 0);
      if (age < 18) {
        return 'Você deve ter pelo menos 18 anos';
      }
    } catch (e) {
      return 'Data inválida';
    }
    return null;
  }

  static String? validateCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }

    final cleanValue = value.replaceAll(RegExp(r'\D'), '');

    if (cleanValue.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    if (RegExp(r'^(\d)\1{10}$').hasMatch(cleanValue)) {
      return 'CPF inválido';
    }

    // Validar primeiro dígito
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cleanValue[i]) * (10 - i);
    }
    int remainder = sum % 11;
    int firstDigit = remainder < 2 ? 0 : 11 - remainder;

    if (int.parse(cleanValue[9]) != firstDigit) {
      return 'CPF inválido';
    }

    // Validar segundo dígito
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cleanValue[i]) * (11 - i);
    }
    remainder = sum % 11;
    int secondDigit = remainder < 2 ? 0 : 11 - remainder;

    if (int.parse(cleanValue[10]) != secondDigit) {
      return 'CPF inválido';
    }

    return null;
  }

  static String? validateOptionalPhone(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
      return 'Telefone inválido (10 ou 11 dígitos)';
    }
    return null;
  }
}
