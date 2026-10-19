import 'dart:io';

import 'package:flutter/services.dart';

/// Raiz do SDK, para achar a fonte de icones do Material.
String get _flutterRoot =>
    Platform.environment['FLUTTER_ROOT'] ??
    r'C:\Users\PedroKelvin\AppData\Local\flutter-sdk';

/// Carrega Inter e MaterialIcons.
///
/// `flutter test` nao carrega fonte nenhuma por padrao: sem isto os textos
/// medem como blocos da fonte de teste (largura errada, overflow falso) e os
/// icones saem como retangulos vazios.
Future<void> loadRedesignFonts() async {
  final inter = FontLoader('Inter');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final bytes = File('assets/fonts/Inter-$w.ttf').readAsBytesSync();
    inter.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await inter.load();

  final iconsFile = File(
    '$_flutterRoot/bin/cache/artifacts/material_fonts/'
    'materialicons-regular.otf',
  );
  if (iconsFile.existsSync()) {
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        Future.value(ByteData.view(iconsFile.readAsBytesSync().buffer)),
      );
    await icons.load();
  }
}
