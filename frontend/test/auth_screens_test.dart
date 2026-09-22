// Preservacao de comportamento das telas de autenticacao redesenhadas.
//
// Nao ha um teste visual aqui. Cada caso prova que a UI nova continua
// acionando o mesmo provider, com os mesmos argumentos, e navegando para os
// mesmos destinos, do mesmo jeito (push vs replacement) que antes do redesign.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miajudai/screens/auth/login_screen.dart';
import 'package:miajudai/screens/auth/signup_screen.dart';

import 'support/pump_screen.dart';
import 'support/test_fonts.dart';

Finder _field(int index) => find.byType(TextFormField).at(index);

bool _isObscured(WidgetTester tester, int index) => tester
    .widget<TextField>(
      find.descendant(of: _field(index), matching: find.byType(TextField)),
    )
    .obscureText;

Future<void> _tapPrimary(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(FilledButton));
  await tester.tap(find.byType(FilledButton));
  await tester.pump();
}

void main() {
  setUpAll(loadRedesignFonts);

  group('LoginScreen', () {
    testWidgets('empty submit shows validation messages and skips login', (
      tester,
    ) async {
      final env = await pumpScreen(tester, const LoginScreen());

      await _tapPrimary(tester);

      expect(find.text('Informe seu email'), findsOneWidget);
      expect(find.text('Informe sua senha'), findsOneWidget);
      expect(env.auth.loginCalls, isEmpty);
    });

    testWidgets('invalid email and short password keep their messages', (
      tester,
    ) async {
      final env = await pumpScreen(tester, const LoginScreen());

      await tester.enterText(_field(0), 'abc');
      await tester.enterText(_field(1), '123');
      await _tapPrimary(tester);

      expect(find.text('Email inválido'), findsOneWidget);
      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
      expect(env.auth.loginCalls, isEmpty);
    });

    testWidgets('valid submit calls login with the trimmed email', (
      tester,
    ) async {
      final env = await pumpScreen(tester, const LoginScreen());

      await tester.enterText(_field(0), '  user@mail.com  ');
      await tester.enterText(_field(1), 'secret1');
      await _tapPrimary(tester);
      await tester.pumpAndSettle();

      expect(env.auth.loginCalls, hasLength(1));
      expect(env.auth.loginCalls.single.email, 'user@mail.com');
      expect(env.auth.loginCalls.single.password, 'secret1');
      expect(env.log.events, isEmpty, reason: 'sem sucesso, nao navega');
    });

    testWidgets('authenticated login replaces the route with /welcome', (
      tester,
    ) async {
      final env = await pumpScreen(tester, const LoginScreen());
      env.auth.authenticated = true;

      await tester.enterText(_field(0), 'user@mail.com');
      await tester.enterText(_field(1), 'secret1');
      await _tapPrimary(tester);
      await tester.pumpAndSettle();

      expect(env.log.events, ['replace /welcome']);
    });

    testWidgets('failed login shows the same error message', (tester) async {
      final env = await pumpScreen(tester, const LoginScreen());
      env.auth.errorMessage = 'qualquer erro do provider';

      await tester.enterText(_field(0), 'user@mail.com');
      await tester.enterText(_field(1), 'secret1');
      await _tapPrimary(tester);
      await tester.pump(const Duration(milliseconds: 750));

      expect(
        find.text('Email ou senha incorretos. Tente novamente.'),
        findsOneWidget,
      );
    });

    testWidgets('"Criar conta gratuita" PUSHES /signup', (tester) async {
      final env = await pumpScreen(tester, const LoginScreen());

      await tester.tap(find.text('Criar conta gratuita'));
      await tester.pumpAndSettle();

      expect(env.log.events, ['push /signup']);
    });

    testWidgets('back arrow REPLACES the route with /', (tester) async {
      final env = await pumpScreen(tester, const LoginScreen());

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();

      expect(env.log.events, ['replace /']);
    });

    testWidgets('password visibility toggle still flips obscureText', (
      tester,
    ) async {
      await pumpScreen(tester, const LoginScreen());

      expect(_isObscured(tester, 1), isTrue);
      await tester.tap(find.byTooltip('Mostrar senha'));
      await tester.pump();
      expect(_isObscured(tester, 1), isFalse);
      expect(find.byTooltip('Ocultar senha'), findsOneWidget);
    });

    testWidgets('loading disables the button and blocks a second submit', (
      tester,
    ) async {
      final env = await pumpScreen(tester, const LoginScreen());

      await tester.enterText(_field(0), 'user@mail.com');
      await tester.enterText(_field(1), 'secret1');
      env.auth.setLoading(true);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull);

      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.pump();
      expect(env.auth.loginCalls, isEmpty);
    });

    testWidgets('forgot-password link is present', (tester) async {
      await pumpScreen(tester, const LoginScreen());
      expect(find.widgetWithText(TextButton, 'Esqueci minha senha'),
          findsOneWidget);
    });
  });

  group('SignupScreen', () {
    testWidgets('empty submit shows all four required messages', (
      tester,
    ) async {
      final env = await pumpScreen(tester, const SignupScreen());

      await _tapPrimary(tester);

      expect(find.text('Informe seu nome'), findsOneWidget);
      expect(find.text('Informe seu email'), findsOneWidget);
      expect(find.text('Crie uma senha'), findsOneWidget);
      expect(find.text('Confirme sua senha'), findsOneWidget);
      expect(env.auth.signupCalls, isEmpty);
    });

    testWidgets('mismatched confirmation keeps its message', (tester) async {
      final env = await pumpScreen(tester, const SignupScreen());

      await tester.enterText(_field(0), 'Ana');
      await tester.enterText(_field(1), 'ana@mail.com');
      await tester.enterText(_field(2), 'secret1');
      await tester.enterText(_field(3), 'secret2');
      await _tapPrimary(tester);

      expect(find.text('As senhas não coincidem'), findsOneWidget);
      expect(env.auth.signupCalls, isEmpty);
    });

    testWidgets('strength indicator appears, updates and disappears', (
      tester,
    ) async {
      await pumpScreen(tester, const SignupScreen());

      expect(find.text('Muito fraca'), findsNothing);

      await tester.enterText(_field(2), 'abcdef');
      await tester.pump();
      expect(find.text('Muito fraca'), findsOneWidget);

      await tester.enterText(_field(2), 'Abcdef1234');
      await tester.pump();
      expect(find.text('Forte'), findsOneWidget);
      expect(find.text('Muito fraca'), findsNothing);

      await tester.enterText(_field(2), '');
      await tester.pump();
      expect(find.text('Forte'), findsNothing);
    });

    testWidgets('valid submit calls signup with the trimmed values', (
      tester,
    ) async {
      final env = await pumpScreen(tester, const SignupScreen());

      await tester.enterText(_field(0), '  Ana Silva ');
      await tester.enterText(_field(1), ' ana@mail.com ');
      await tester.enterText(_field(2), 'Abcdef1234');
      await tester.enterText(_field(3), 'Abcdef1234');
      await _tapPrimary(tester);
      await tester.pumpAndSettle();

      expect(env.auth.signupCalls, hasLength(1));
      final call = env.auth.signupCalls.single;
      expect(call.email, 'ana@mail.com');
      expect(call.password, 'Abcdef1234');
      expect(call.fullName, 'Ana Silva');
    });

    testWidgets('authenticated signup replaces the route with /welcome', (
      tester,
    ) async {
      final env = await pumpScreen(tester, const SignupScreen());
      env.auth.authenticated = true;

      await tester.enterText(_field(0), 'Ana');
      await tester.enterText(_field(1), 'ana@mail.com');
      await tester.enterText(_field(2), 'Abcdef1234');
      await tester.enterText(_field(3), 'Abcdef1234');
      await _tapPrimary(tester);
      await tester.pumpAndSettle();

      expect(env.log.events, ['replace /welcome']);
    });

    testWidgets('failed signup shows the provider error message', (
      tester,
    ) async {
      final env = await pumpScreen(tester, const SignupScreen());
      env.auth.errorMessage = 'Email já cadastrado';

      await tester.enterText(_field(0), 'Ana');
      await tester.enterText(_field(1), 'ana@mail.com');
      await tester.enterText(_field(2), 'Abcdef1234');
      await tester.enterText(_field(3), 'Abcdef1234');
      await _tapPrimary(tester);
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.text('Email já cadastrado'), findsOneWidget);
    });

    testWidgets('"Entrar" link replaces with /login when it cannot pop', (
      tester,
    ) async {
      final env = await pumpScreen(tester, const SignupScreen());

      await tester.ensureVisible(find.text('Entrar'));
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(env.log.events, ['replace /login']);
    });

    testWidgets('back arrow REPLACES the route with /', (tester) async {
      final env = await pumpScreen(tester, const SignupScreen());

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();

      expect(env.log.events, ['replace /']);
    });
  });
}
