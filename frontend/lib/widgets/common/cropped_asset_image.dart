import 'package:flutter/material.dart';

/// Ilustracao decorativa de um asset, recortada por layout.
///
/// Os assets oficiais dos agentes tem margens generosas em volta da arte (e o
/// grupo de agentes e um JPEG de fundo branco). Em vez de editar o arquivo,
/// este widget mostra apenas a regiao util:
///
///  - [widthFactor]/[heightFactor] sao a fracao do arquivo que contem a arte;
///  - [anchor] diz onde essa regiao fica dentro do arquivo (`Alignment` do
///    recorte: -1 = colada na borda inicial, 1 = colada na final);
///  - [blendInto], quando informado, dissolve o fundo BRANCO do arquivo nessa
///    cor com `BlendMode.multiply` (branco x cor = cor). Use a cor de fundo de
///    onde a ilustracao esta.
///
/// O widget tem a proporcao da regiao recortada, entao ocupa a largura que o
/// pai der e calcula a propria altura. E puramente decorativo: fica fora da
/// arvore de semantica.
class CroppedAssetImage extends StatelessWidget {
  const CroppedAssetImage({
    super.key,
    required this.asset,
    required this.assetSize,
    this.widthFactor = 1,
    this.heightFactor = 1,
    this.anchor = Alignment.center,
    this.blendInto,
  });

  final String asset;

  /// Dimensoes em pixels do arquivo, usadas so para calcular a proporcao.
  final Size assetSize;

  final double widthFactor;
  final double heightFactor;
  final Alignment anchor;
  final Color? blendInto;

  @override
  Widget build(BuildContext context) {
    final blendInto = this.blendInto;

    return ExcludeSemantics(
      child: AspectRatio(
        aspectRatio:
            (widthFactor * assetSize.width) / (heightFactor * assetSize.height),
        child: ClipRect(
          child: FractionallySizedBox(
            widthFactor: 1 / widthFactor,
            heightFactor: 1 / heightFactor,
            alignment: anchor,
            child: Image.asset(
              asset,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.medium,
              color: blendInto,
              colorBlendMode: blendInto == null ? null : BlendMode.multiply,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    );
  }
}
