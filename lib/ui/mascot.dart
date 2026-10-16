import 'package:baon/ui/tokens.dart';
import 'package:flutter/material.dart';

enum MascotMood { happy, worried, crying, sleepy }

MascotMood moodFor(double probability) => switch (riskLabelFor(probability)) {
  'SAFE' => MascotMood.happy,
  'TIGHT' => MascotMood.worried,
  _ => MascotMood.crying,
};

/// Stable across platforms and launches; never uses runtime String.hashCode.
int mascotSeed(String seed) {
  var hash = 0;
  for (final unit in seed.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash;
}

class MascotPalette {
  const MascotPalette(this.tint, this.plate, this.ribbon);
  final Color tint;
  final Color plate;
  final Color ribbon;
  Color get pane => tint.withValues(alpha: 0.64);
  static const families = <MascotPalette>[
    MascotPalette(Color(0xFFE6DEFF), Color(0xFFCFC2FF), Color(0xFF9C8CF0)),
    MascotPalette(Color(0xFFFFDDE8), Color(0xFFFFC2D6), Color(0xFFF2789F)),
    MascotPalette(Color(0xFFFFF0BF), Color(0xFFFFE08A), Color(0xFFF5B83D)),
    MascotPalette(Color(0xFFD6F3E4), Color(0xFFB5E8CD), Color(0xFF5CC08E)),
    MascotPalette(Color(0xFFD8EBFF), Color(0xFFB9DAFF), Color(0xFF5FA8F0)),
    MascotPalette(Color(0xFFFFE3CF), Color(0xFFFFCBA6), Color(0xFFF2789F)),
  ];
  static MascotPalette forSeed(String seed) =>
      families[mascotSeed(seed) % families.length];
}

/// One short, finite bounce when risk changes; no ambient animation.
class Mascot extends StatefulWidget {
  const Mascot({
    super.key,
    required this.seed,
    this.mood = MascotMood.happy,
    this.size = 88,
  });
  final String seed;
  final MascotMood mood;
  final double size;
  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
    value: 1,
  );
  @override
  void didUpdateWidget(Mascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood &&
        !MediaQuery.disableAnimationsOf(context)) {
      _bounce.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AnimatedBuilder(
      animation: _bounce,
      builder: (context, child) => Transform.scale(
        scale: MediaQuery.disableAnimationsOf(context)
            ? 1
            : 0.88 + 0.12 * Curves.easeOutBack.transform(_bounce.value),
        child: child,
      ),
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _MascotPainter(widget.seed, widget.mood),
        ),
      ),
    ),
  );
}

/// Rounded silhouettes are united before outlining so the keyline is continuous.
class _MascotPainter extends CustomPainter {
  const _MascotPainter(this.seed, this.mood);
  final String seed;
  final MascotMood mood;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    final palette = MascotPalette.forSeed(seed);
    final kind = (mascotSeed(seed) ~/ 7) % 6;
    Path body = Path();
    void oval(double x, double y, double w, double h) {
      final piece = Path()..addOval(Rect.fromLTWH(x, y, w, h));
      body = Path.combine(PathOperation.union, body, piece);
    }

    switch (kind) {
      case 0: // bunny bun
        oval(25, 8, 19, 48);
        oval(55, 5, 19, 49);
        oval(14, 34, 72, 58);
      case 1: // dino bean
        body = Path()
          ..moveTo(28, 33)
          ..cubicTo(19, 60, 13, 85, 42, 91)
          ..cubicTo(80, 100, 91, 72, 79, 47)
          ..cubicTo(72, 27, 41, 18, 28, 33)
          ..close();
        for (final point in const [
          Offset(68, 30),
          Offset(80, 43),
          Offset(84, 59),
        ]) {
          final spike = Path()
            ..moveTo(point.dx - 5, point.dy - 8)
            ..quadraticBezierTo(
              point.dx + 16,
              point.dy - 8,
              point.dx + 9,
              point.dy + 6,
            )
            ..lineTo(point.dx - 4, point.dy + 9)
            ..close();
          body = Path.combine(PathOperation.union, body, spike);
        }
      case 2: // chick
        oval(17, 28, 67, 64);
        oval(43, 14, 12, 28);
        oval(51, 18, 14, 22);
        oval(9, 52, 21, 21);
      case 3: // butter pat
        body.addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(16, 27, 69, 62),
            const Radius.circular(20),
          ),
        );
      case 4: // cloud
        oval(12, 44, 40, 38);
        oval(24, 25, 37, 43);
        oval(48, 30, 35, 42);
        oval(57, 47, 32, 33);
        oval(24, 51, 52, 37);
      case 5: // bear
        oval(15, 17, 26, 29);
        oval(60, 17, 26, 29);
        oval(14, 30, 72, 61);
    }
    canvas.drawPath(
      body,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(body, Paint()..color = palette.plate);
    if (kind == 0) {
      canvas.drawOval(
        const Rect.fromLTWH(31, 17, 6, 23),
        Paint()..color = palette.tint,
      );
      canvas.drawOval(
        const Rect.fromLTWH(61, 14, 6, 23),
        Paint()..color = palette.tint,
      );
    }
    if (kind == 5) {
      canvas.drawCircle(const Offset(28, 31), 7, Paint()..color = palette.tint);
      canvas.drawCircle(const Offset(73, 31), 7, Paint()..color = palette.tint);
    }
    final ink = Paint()
      ..color = BaonColors.ink
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final blush = Paint()..color = const Color(0xFFFFACC7);
    canvas.drawOval(const Rect.fromLTWH(24, 65, 13, 8), blush);
    canvas.drawOval(const Rect.fromLTWH(64, 65, 13, 8), blush);
    if (mood == MascotMood.sleepy) {
      canvas.drawPath(
        Path()
          ..moveTo(34, 59)
          ..quadraticBezierTo(39, 65, 44, 59),
        ink,
      );
      canvas.drawPath(
        Path()
          ..moveTo(57, 59)
          ..quadraticBezierTo(62, 65, 67, 59),
        ink,
      );
      canvas.drawPath(
        Path()
          ..moveTo(80, 17)
          ..lineTo(89, 17)
          ..lineTo(81, 25)
          ..lineTo(90, 25),
        ink,
      );
    } else {
      canvas.drawCircle(
        const Offset(39, 60),
        2.6,
        Paint()..color = BaonColors.ink,
      );
      canvas.drawCircle(
        const Offset(62, 60),
        2.6,
        Paint()..color = BaonColors.ink,
      );
    }
    final mouth = Path()..moveTo(45, 71);
    switch (mood) {
      case MascotMood.happy:
        mouth.quadraticBezierTo(51, 79, 57, 71);
      case MascotMood.worried:
        mouth.cubicTo(48, 67, 52, 75, 57, 71);
      case MascotMood.crying:
        mouth.quadraticBezierTo(51, 65, 57, 71);
      case MascotMood.sleepy:
        mouth.quadraticBezierTo(51, 74, 57, 71);
    }
    canvas.drawPath(mouth, ink);
    if (mood == MascotMood.worried || mood == MascotMood.crying) {
      canvas.drawLine(const Offset(34, 52), const Offset(43, 49), ink);
      canvas.drawLine(const Offset(58, 49), const Offset(67, 52), ink);
      final tear = Path()
        ..moveTo(0, -6)
        ..cubicTo(-8, 3, -4, 9, 0, 9)
        ..cubicTo(6, 9, 7, 3, 0, -6)
        ..close();
      canvas.save();
      canvas.translate(
        mood == MascotMood.worried ? 78 : 63,
        mood == MascotMood.worried ? 43 : 72,
      );
      canvas.drawPath(tear, Paint()..color = const Color(0xFF80BAEE));
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MascotPainter old) =>
      seed != old.seed || mood != old.mood;
}
