import 'package:flutter/material.dart';

import '../../theme/tokens/app_colors_semantic.dart';
import '../common/cropped_asset_image.dart';

/// Ilustracao do dia livre: a Luna sentada ao lado da mala, sobre um circulo
/// suave.
///
/// Ornamental: quem a usa (`EmptyStateCard`) ja a tira da semantica.
class CalendarEmptyArt extends StatelessWidget {
  const CalendarEmptyArt({super.key});

  static const double _circle = 128;
  static const double _cat = 124;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _circle + 24,
      height: _circle + 4,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: _circle,
            height: _circle,
            decoration: const BoxDecoration(
              color: AppSemanticColors.actionPrimarySubtle,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(
            height: _cat,
            // luna.png (2048x2048): o gato e a mala ocupam x 0,159-0,804 e
            // y 0,074-0,958. Recorte de 70% x 92% com folga em volta da arte
            // (o mesmo da introducao do chat da Luna).
            child: const CroppedAssetImage(
              asset: 'assets/images/luna.png',
              assetSize: Size(2048, 2048),
              widthFactor: 0.70,
              heightFactor: 0.92,
              anchor: Alignment(-0.1, 0.25),
            ),
          ),
        ],
      ),
    );
  }
}
