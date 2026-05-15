import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ====================================
// Colors
// ====================================
class AppColors {
  // Primary Colors (from MiAjudAI logo)
  static const Color primary = Color(0xFF1B4965);
  static const Color primaryDark = Color(0xFF0F2A3D);
  static const Color accent = Color(0xFFFF8C00);

  // Secondary Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Background & Surface
  static const Color background = Color(0xFFF5F5F7);
  static const Color surface = Colors.white;
  static const Color divider = Color(0xFFE8E8E8);

  // Text Colors
  static const Color textPrimary = Color(0xFF1B4965);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textHint = Color(0xFFCCCCCC);
}

// ====================================
// Dimensions & Spacing
// ====================================
class AppDimens {
  // Padding & Margin
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingDefault = 16.0;
  static const double paddingMedium = 24.0;
  static const double paddingLarge = 32.0;
  static const double paddingXLarge = 48.0;

  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusDefault = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconDefault = 24.0;
  static const double iconMedium = 32.0;
  static const double iconLarge = 48.0;

  // Button Heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightDefault = 48.0;
  static const double buttonHeightLarge = 56.0;

  // App Bar
  static const double appBarHeight = 56.0;

  // Card & Container
  static const double cardElevation = 2.0;
}

// ====================================
// Text Styles
// ====================================
class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}

// ====================================
// String Constants
// ====================================
class AppStrings {
  // App
  static const String appName = 'MiAjudAI';
  static const String appVersion = '1.0.0';

  // Generic
  static const String loading = 'Carregando...';
  static const String error = 'Erro';
  static const String success = 'Sucesso';
  static const String warning = 'Aviso';
  static const String back = 'Voltar';
  static const String next = 'Próximo';
  static const String skip = 'Pular';
  static const String cancel = 'Cancelar';
  static const String save = 'Salvar';
  static const String delete = 'Deletar';
  static const String edit = 'Editar';
  static const String create = 'Criar';
  static const String update = 'Atualizar';
  static const String confirm = 'Confirmar';

  // Auth
  static const String login = 'Entrar';
  static const String signup = 'Criar Conta';
  static const String logout = 'Sair';
  static const String forgotPassword = 'Esqueci minha senha';
  static const String email = 'Email';
  static const String password = 'Senha';
  static const String confirmPassword = 'Confirmar Senha';
  static const String signInWithApple = 'Entrar com Apple';
  static const String noAccount = 'Não tem conta?';
  static const String haveAccount = 'Já tem conta?';

  // Validation
  static const String requiredField = 'Campo obrigatório';
  static const String invalidEmail = 'Email inválido';
  static const String passwordTooShort = 'Senha muito curta (mín. 6 caracteres)';
  static const String passwordMismatch = 'As senhas não correspondem';

  // Errors
  static const String connectionError = 'Erro de conexão';
  static const String serverError = 'Erro do servidor';
  static const String unauthorizedError = 'Não autorizado';
}

// ====================================
// API Configuration
// ====================================
class ApiConfig {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000/api';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}

// ====================================
// Firebase Settings
// ====================================
class FirebaseSettings {
  static const String projectId = 'miajudai';
  static const String apiKey = 'AIzaSyB2FC6YHy22Id3tdTseSzrYCU1oMS7mhZg';
  static const String authDomain = 'miajudai.firebaseapp.com';
  static const String databaseUrl = 'https://miajudai.firebaseio.com';
  static const String storageBucket = 'miajudai.firebasestorage.app';
  static const String messagingSenderId = '920940740455';
  static const String appId = '1:920940740455:web:1e9cd26a3cad0cf818f9c2';
}
