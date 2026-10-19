import 'package:flutter/material.dart';

import '../../theme/tokens/app_colors_semantic.dart';

/// Formas suaves de fundo presentes em todos os prototipos do redesign.
///
/// Puramente ornamental: nao carrega informacao e e removido da arvore de
/// semantica para nao poluir leitores de tela.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: IgnorePointer(
        child: SizedBox.expand(
          child: CustomPaint(painter: _BackdropPainter()),
        ),
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final soft = Paint()..color = AppSemanticColors.backdropBlobSoft;
    final strong = Paint()..color = AppSemanticColors.backdropBlob;

    // Massa superior direita: borda esquerda levemente ondulada, descendo.
    final topRight = Path()
      ..moveTo(w * 0.52, 0)
      ..cubicTo(w * 0.62, h * 0.10, w * 0.58, h * 0.18, w * 0.74, h * 0.26)
      ..cubicTo(w * 0.88, h * 0.33, w * 0.97, h * 0.30, w, h * 0.34)
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(topRight, strong);

    // Reforco circular no canto, para dar profundidade.
    canvas.drawCircle(Offset(w * 1.02, h * 0.02), w * 0.34, soft);

    // Massa inferior esquerda.
    final bottomLeft = Path()
      ..moveTo(0, h * 0.82)
      ..cubicTo(w * 0.14, h * 0.78, w * 0.22, h * 0.88, w * 0.34, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(bottomLeft, strong);

    canvas.drawCircle(Offset(w * -0.06, h * 1.0), w * 0.24, soft);
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) => false;
}
