// Preservacao de comportamento do modulo de Perfil (ManageAccountScreen).
//
// A tela grava direto pelo ApiService (sem provider), entao os testes
// interceptam o pacote http com `runWithClient` + MockClient e provam que a UI
// redesenhada continua enviando os MESMOS PUTs (rota, chave, valor, token) e
// mostrando os mesmos feedbacks.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:miajudai/models/user_model.dart';
import 'package:miajudai/screens/manage_account_screen.dart';

import 'support/pump_screen.dart';
import 'support/test_fonts.dart';

UserModel _user({
  String? gender,
  String? birthDate,
  String? birthState,
  String? address,
  String? marital,
  String? c1Name,
  String? c1Phone,
  String? c2Name,
  String? c2Phone,
  String? c3Name,
  String? c3Phone,
}) =>
    UserModel(
      id: '1',
      email: 'diva@mail.com',
      fullName: 'Diva',
      gender: gender,
      birthDate: birthDate,
      birthState: birthState,
      birthCity: address,
      maritalStatus: marital,
      emergencyContact1Name: c1Name,
      emergencyContact1Phone: c1Phone,
      emergencyContact2Name: c2Name,
      emergencyContact2Phone: c2Phone,
      emergencyContact3Name: c3Name,
      emergencyContact3Phone: c3Phone,
      createdAt: DateTime(2024),
    );

/// Requisicoes que chegaram ao "backend" falso.
class _Api {
  _Api(UserModel user) : _user = user.toJson();

  final List<http.Request> requests = [];
  final Map<String, dynamic> _user;
  bool fail = false;

  Map<String, dynamic> get lastBody =>
      jsonDecode(requests.last.body) as Map<String, dynamic>;

  Future<http.Response> handle(http.Request r) async {
    requests.add(r);
    if (fail) return http.Response('boom', 500);
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    // Como o backend: devolve o usuario COMPLETO ja com a alteracao.
    _user.addAll(body);
    return http.Response(jsonEncode({'success': true, 'user': _user}), 200);
  }
}

/// Monta a tela EMPILHADA (para "voltar") e roda [body] com o http falso.
Future<void> _run(
  WidgetTester tester,
  UserModel user,
  Future<void> Function(_Api api) body,
) async {
  final api = _Api(user);
  await http.runWithClient(() async {
    await pumpScreen(
      tester,
      const ManageAccountScreen(),
      setup: (a) => a.currentUser = user,
      pushed: true,
    );
    await body(api);
  }, () => MockClient(api.handle));
}

Future<void> _open(WidgetTester tester, String card) async {
  await tester.tap(find.text(card));
  await tester.pumpAndSettle();
}

/// Toca numa linha (rotulo) e espera a sheet/dialogo abrir.
Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).first);
  await tester.tap(find.text(text).first);
  await tester.pumpAndSettle();
}

Future<void> _settleNetwork(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// Snackbars entram numa fila: espera o atual sair antes do proximo.
Future<void> _dismissSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

Future<void> _saveSheet(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.tap(find.text('Salvar'));
  await tester.pumpAndSettle();
  await _settleNetwork(tester);
}

void main() {
  setUpAll(() async {
    await loadRedesignFonts();
    dotenv.loadFromString(envString: 'API_BASE_URL=http://test.local/api');
  });

  group('hub', () {
    testWidgets('shows the two entries and the copy', (tester) async {
      await _run(tester, _user(), (api) async {
        expect(find.text('Gerenciar conta'), findsOneWidget);
        expect(
          find.text('Mantenha suas informações atualizadas'),
          findsOneWidget,
        );
        expect(find.text('Minha conta'), findsOneWidget);
        expect(find.text('Informações pessoais'), findsOneWidget);
        expect(find.text('Contatos de emergência'), findsOneWidget);
        // Estado civil agora e uma linha de "Sobre voce", nao um card do hub.
        expect(find.text('Estado civil'), findsNothing);
      });
    });

    testWidgets('cards open their pages and back returns', (tester) async {
      await _run(tester, _user(), (api) async {
        await _open(tester, 'Informações pessoais');
        expect(find.text('Sobre você'), findsOneWidget);
        await tester.tap(find.byTooltip('Voltar'));
        await tester.pumpAndSettle();
        expect(find.text('Gerenciar conta'), findsOneWidget);

        await _open(tester, 'Contatos de emergência');
        expect(find.textContaining('Primeiro contato', findRichText: true),
            findsOneWidget);
        await tester.tap(find.byTooltip('Voltar'));
        await tester.pumpAndSettle();
        expect(find.text('Gerenciar conta'), findsOneWidget);

        await tester.tap(find.byTooltip('Voltar'));
        await tester.pumpAndSettle();
        expect(find.text(kOriginScreenText), findsOneWidget);
      });
    });
  });

  group('personal info', () {
    testWidgets('shows the stored values and "Não informado"', (tester) async {
      await _run(
        tester,
        _user(gender: 'Feminino', birthState: 'SP', address: 'Rua A, 1'),
        (api) async {
          await _open(tester, 'Informações pessoais');
          for (final t in [
            'Sobre você',
            'Nascimento',
            'Endereço',
            'Diva',
            'Feminino',
            'Brasil',
            'SP',
            'Rua A, 1',
          ]) {
            expect(find.text(t), findsWidgets, reason: t);
          }
          // estado civil e data de nascimento nao informados
          expect(find.text('Não informado'), findsNWidgets(2));
        },
      );
    });

    testWidgets('country of birth is read-only', (tester) async {
      await _run(tester, _user(), (api) async {
        await _open(tester, 'Informações pessoais');
        await tester.tap(find.text('Brasil'));
        await tester.pumpAndSettle();
        expect(find.text('Salvar'), findsNothing);
        expect(find.byType(Dialog), findsNothing);
        expect(api.requests, isEmpty);
      });
    });

    testWidgets('name sheet saves full_name with token and shows success', (
      tester,
    ) async {
      await _run(tester, _user(), (api) async {
        await _open(tester, 'Informações pessoais');
        await _tap(tester, 'Nome completo');
        await _saveSheet(tester, 'Diva Nova');

        expect(api.requests, hasLength(1));
        expect(api.requests.single.method, 'PUT');
        expect(api.requests.single.url.path, '/api/auth/profile');
        expect(
          api.requests.single.headers['Authorization'],
          'Bearer test-token',
        );
        expect(api.lastBody, {'full_name': 'Diva Nova'});
        expect(find.text('Dados salvos com sucesso!'), findsOneWidget);
        expect(find.text('Diva Nova'), findsOneWidget);
      });
    });

    testWidgets('cancel closes the sheet without saving', (tester) async {
      await _run(tester, _user(), (api) async {
        await _open(tester, 'Informações pessoais');
        await _tap(tester, 'Nome completo');
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        expect(find.text('Salvar'), findsNothing);
        expect(api.requests, isEmpty);
      });
    });

    testWidgets('address writes birth_city and empty text becomes null', (
      tester,
    ) async {
      await _run(tester, _user(address: 'Rua A'), (api) async {
        await _open(tester, 'Informações pessoais');
        await tester.tap(find.text('Rua A'));
        await tester.pumpAndSettle();
        await _saveSheet(tester, '');
        expect(api.lastBody, {'birth_city': null});
      });
    });

    testWidgets('gender, marital status and state save their keys', (
      tester,
    ) async {
      await _run(tester, _user(), (api) async {
        await _open(tester, 'Informações pessoais');

        await _tap(tester, 'Sexo');
        await _tap(tester, 'Outro');
        await _settleNetwork(tester);
        expect(api.lastBody, {'gender': 'Outro'});
        expect(find.text('Dados salvos com sucesso!'), findsOneWidget);
        await _dismissSnackBar(tester);

        await _tap(tester, 'Estado civil');
        await _tap(tester, 'União Estável');
        await _settleNetwork(tester);
        expect(api.lastBody, {'marital_status': 'União Estável'});
        expect(find.text('Estado civil atualizado!'), findsOneWidget);

        await _tap(tester, 'UF de nascimento');
        await tester.tap(find.text('AC'));
        await tester.pumpAndSettle();
        await _settleNetwork(tester);
        expect(api.lastBody, {'birth_state': 'AC'});
      });
    });

    testWidgets('birth date picker saves the picked date', (tester) async {
      await _run(tester, _user(birthDate: '1990-05-12'), (api) async {
        await _open(tester, 'Informações pessoais');
        await _tap(tester, 'Data de nascimento');
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        await _settleNetwork(tester);
        expect(api.lastBody, {'birth_date': '1990-05-12'});
      });
    });

    testWidgets('birth date under 18 is rejected without a request', (
      tester,
    ) async {
      final young = DateTime.now().subtract(const Duration(days: 365 * 10));
      final iso = young.toString().split(' ').first;
      await _run(tester, _user(birthDate: iso), (api) async {
        await _open(tester, 'Informações pessoais');
        await _tap(tester, 'Data de nascimento');
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        await _settleNetwork(tester);
        expect(find.text('Você deve ter pelo menos 18 anos'), findsOneWidget);
        expect(api.requests, isEmpty);
      });
    });

    testWidgets('a failing save shows the error and keeps the value', (
      tester,
    ) async {
      await _run(tester, _user(), (api) async {
        api.fail = true;
        await _open(tester, 'Informações pessoais');
        await _tap(tester, 'Nome completo');
        await _saveSheet(tester, 'Outro Nome');
        expect(find.textContaining('Erro ao salvar:'), findsOneWidget);
        expect(find.text('Diva'), findsOneWidget);
      });
    });
  });

  group('emergency contacts', () {
    testWidgets('shows two groups, the add button and the info card', (
      tester,
    ) async {
      await _run(tester, _user(c1Name: 'Maria', c1Phone: '111'), (api) async {
        await _open(tester, 'Contatos de emergência');
        expect(find.textContaining('Primeiro contato', findRichText: true),
            findsOneWidget);
        expect(find.textContaining('Segundo contato', findRichText: true),
            findsOneWidget);
        expect(find.textContaining('Terceiro contato', findRichText: true),
            findsNothing);
        expect(find.text('Maria'), findsOneWidget);
        expect(find.text('Você pode adicionar até 3 contatos'), findsOneWidget);

        await tester.ensureVisible(find.text('Adicionar terceiro contato'));
        await tester.tap(find.text('Adicionar terceiro contato'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Terceiro contato', findRichText: true),
            findsOneWidget);
        expect(find.text('Adicionar terceiro contato'), findsNothing);
      });
    });

    testWidgets('an existing third contact is shown directly', (tester) async {
      await _run(tester, _user(c3Name: 'Ana', c3Phone: '333'), (api) async {
        await _open(tester, 'Contatos de emergência');
        expect(find.textContaining('Terceiro contato', findRichText: true),
            findsOneWidget);
        expect(find.text('Adicionar terceiro contato'), findsNothing);
      });
    });

    testWidgets('contact sheet saves the right key; phone uses phone keyboard',
        (tester) async {
      await _run(tester, _user(c1Name: 'Maria', c1Phone: '111'), (api) async {
        await _open(tester, 'Contatos de emergência');

        await tester.tap(find.text('111'));
        await tester.pumpAndSettle();
        expect(find.text('Contato 1 — Telefone'), findsOneWidget);
        expect(
          tester.widget<TextField>(find.byType(TextField)).keyboardType,
          TextInputType.phone,
        );
        await _saveSheet(tester, '(11) 90000-0000');
        expect(api.lastBody, {'emergency_contact_1_phone': '(11) 90000-0000'});
        expect(find.text('Contato de emergência atualizado!'), findsOneWidget);
        await _dismissSnackBar(tester);

        await tester.tap(find.text('Maria'));
        await tester.pumpAndSettle();
        expect(find.text('Contato 1 — Nome'), findsOneWidget);
        await _saveSheet(tester, 'Maria B');
        expect(api.lastBody, {'emergency_contact_1_name': 'Maria B'});
      });
    });

    testWidgets('"Não tenho" clears name and phone and disables editing', (
      tester,
    ) async {
      await _run(tester, _user(c1Name: 'Maria', c1Phone: '111'), (api) async {
        await _open(tester, 'Contatos de emergência');
        await tester.tap(find.text('Não tenho').first);
        await tester.pumpAndSettle();
        await _settleNetwork(tester);

        final bodies = api.requests
            .map((r) => jsonDecode(r.body) as Map<String, dynamic>)
            .toList();
        expect(bodies, [
          {'emergency_contact_1_name': null},
          {'emergency_contact_1_phone': null},
        ]);

        // Sem contato: as linhas do primeiro grupo nao abrem mais a sheet.
        api.requests.clear();
        await tester.tap(find.text('Nome').first);
        await tester.pumpAndSettle();
        expect(find.text('Salvar'), findsNothing);
        expect(api.requests, isEmpty);
      });
    });
  });
}
