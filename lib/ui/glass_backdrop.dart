import 'package:baon/ui/mascot.dart';
import 'package:baon/ui/tokens.dart';
import 'package:flutter/material.dart';

class GlassBackdrop extends StatelessWidget {
  const GlassBackdrop({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      const Positioned.fill(
        child: RepaintBoundary(child: CustomPaint(painter: _WrappingPaper())),
      ),
      child,
    ],
  );
}

/// A fixed lattice, painted once: no per-frame randomness or gradient glows.
class _WrappingPaper extends CustomPainter {
  const _WrappingPaper();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(BaonColors.cream, BlendMode.src);
    for (var row = 0; row * 72 < size.height; row++) {
      for (var col = 0; col * 76 < size.width; col++) {
        final index = row * 7 + col;
        final paint = Paint()
          ..color = MascotPalette.families[index % 5].plate.withValues(
            alpha: 0.42,
          );
        canvas.save();
        canvas.translate(col * 76 + (row.isEven ? 19 : 47), row * 72 + 22);
        switch (index % 3) {
          case 0:
            canvas.drawCircle(Offset.zero, 3, paint);
          case 1:
            canvas.drawPath(
              Path()
                ..moveTo(0, -6)
                ..quadraticBezierTo(1, -1, 6, 0)
                ..quadraticBezierTo(1, 1, 0, 6)
                ..quadraticBezierTo(-1, 1, -6, 0)
                ..quadraticBezierTo(-1, -1, 0, -6)
                ..close(),
              paint,
            );
          case 2:
            canvas.drawPath(heartPath(), paint);
        }
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_WrappingPaper old) => false;
}

Path heartPath() => Path()
  ..moveTo(0, 5)
  ..cubicTo(-13, -3, -3, -9, 0, -3)
  ..cubicTo(3, -9, 13, -3, 0, 5)
  ..close();
