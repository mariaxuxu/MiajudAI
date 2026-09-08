import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/manage_account_screen.dart';
import '../screens/home_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/accounts_screen.dart';
import '../screens/income_screen.dart';
import '../screens/expenses_screen.dart';
import '../screens/chat/financial_chat_screen.dart';
import '../screens/invoice_dashboard_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String welcome = '/welcome';
  static const String manageAccount = '/manage-account';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String calendar = '/calendar';
  static const String accounts = '/accounts';
  static const String income = '/income';
  static const String expenses = '/expenses';
  static const String finance = '/finance';
  static const String chat = '/chat';
  static const String invoiceDashboard = '/invoice-dashboard';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    welcome: (context) => const WelcomeScreen(),
    manageAccount: (context) => const ManageAccountScreen(),
    onboarding: (context) => const OnboardingScreen(),
    home: (context) => const HomeScreen(),
    calendar: (context) => const CalendarScreen(),
    accounts: (context) => const AccountsScreen(),
    income: (context) => const IncomeScreen(),
    expenses: (context) => const ExpensesScreen(),
    chat: (context) => const FinancialChatScreen(),
    invoiceDashboard: (context) => const InvoiceDashboardScreen(),
  };
}
