/// THESIS: Envelopes are a ranked cast of characters; a student reads their
///   week as who is fine and who is in trouble. Refuses the grey bank-card
///   dashboard with one pooled total.
/// OWN-WORLD: Cream wrapping-paper ground under frosted pastel sticker-sleeve
///   panes, thick white keylines, ribbon number tabs, pastel name plates,
///   Fredoka navy display, Nunito body.
/// STORY: Open the app, see each envelope's mascot and mood, read money left
///   and days left, act on any worried or crying one.
/// FIRST VIEWPORT: Dashboard roster; each card = ribbon tab (days left),
///   mascot, name plate, refill pill, money left large, risk badge.
/// FORM: Mascot Roster Glass (character goods catalog), seed b9678d81.
/// FINISH: unreviewed and undocumented is unfinished; this build ends with
///   the finish review, the verdict, and DESIGN.md
library;

import 'package:flutter/material.dart';

/// The 4px spacing scale. Every padding, margin and gap comes from this list.
abstract final class Space {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;
}

/// White sticker keylines.
abstract final class BorderWeight {
  static const double hairline = 1;
  static const double bold = 3;
}

/// Sticker sleeves use 24dp corners; controls are 16dp or pills.
abstract final class Corner {
  static const double sharp = 0;
  static const double soft = 16;
  static const double card = 24;
  static const double pill = 999;
  static const double sheet = 28;
}

/// Frosted-glass recipe: how much the backdrop blurs behind a pane.
abstract final class Glass {
  static const double blur = 12;
}

/// Soft, diffuse shadows. A pane floats above the backdrop rather than
/// sitting on it.
abstract final class SoftShadow {
  static List<BoxShadow> of(Color color, {double depth = 6}) => <BoxShadow>[
    BoxShadow(
      color: color.withValues(alpha: 0.14),
      offset: Offset(0, depth),
      blurRadius: depth * 3,
      spreadRadius: -depth / 3,
    ),
  ];

  static List<BoxShadow> small(Color color) => of(color, depth: 5);
  static List<BoxShadow> large(Color color) => of(color, depth: 16);
}

/// Deep navy ink, pastel sleeves, bubblegum focus, and independent risk hues.
abstract final class BaonColors {
  // Neutrals.
  static const Color ink = Color(0xFF26245A);

  /// Page background. Transparent, so the app backdrop shows through.
  static const Color paper = Colors.transparent;

  /// Frosted pane fill.
  static const Color surface = Color(0xA6E6DEFF);
  static const Color surfaceMuted = Color(0xADFFFFFF);

  /// Near-opaque frost for dialogs and sheets, which float over busy content.
  static const Color sheet = Color(0xF2FFFAF5);

  /// The light rim on a glass edge.
  static const Color border = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF5E5A82);

  // One accent, used for the primary action and focus only.
  static const Color accent = Color(0xFFF25C94);
  static const Color accentSoft = Color(0xFFFFD3E3);

  // Semantic. Colour is the only thing that may shift with risk state.
  static const Color safe = Color(0xFF1E8C5A);
  static const Color safeSoft = Color(0xFFD3F4E2);
  static const Color tight = Color(0xFFA8650A);
  static const Color tightSoft = Color(0xFFFFEDC2);
  static const Color risky = Color(0xFFD63B2F);
  static const Color riskySoft = Color(0xFFFFDAD5);

  // Envelope-shape accents, used sparingly for card tags only.
  static const Color steady = Color(0xFF1E88E5);
  static const Color episodic = Color(0xFFEC407A);
  static const Color reserve = Color(0xFF6D4C41);

  static const Color cream = Color(0xFFFFF7F0);
  static const Color refill = Color(0xFFD9F5E6);
  static const Color whiteGlass = Color(0xADFFFFFF);
}

/// Rounded display and friendly body typography; explicit variable weights.
abstract final class BaonType {
  static const TextStyle display = TextStyle(
    fontFamily: 'Fredoka',
    fontVariations: [FontVariation('wght', 700)],
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.05,
    letterSpacing: -0.5,
    color: BaonColors.ink,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: 'Fredoka',
    fontVariations: [FontVariation('wght', 700)],
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: BaonColors.ink,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'Fredoka',
    fontVariations: [FontVariation('wght', 700)],
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: BaonColors.ink,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'Nunito',
    fontVariations: [FontVariation('wght', 700)],
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0.15,
    color: BaonColors.textMuted,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Nunito',
    fontVariations: [FontVariation('wght', 500)],
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: BaonColors.ink,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: 'Nunito',
    fontVariations: [FontVariation('wght', 500)],
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: BaonColors.textMuted,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Fredoka',
    fontVariations: [FontVariation('wght', 700)],
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.2,
  );

  static const TextStyle numberLg = TextStyle(
    fontFeatures: [FontFeature.tabularFigures()],
    fontFamily: 'Fredoka',
    fontVariations: [FontVariation('wght', 700)],
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -1,
    color: BaonColors.ink,
  );

  static const TextStyle numberMd = TextStyle(
    fontFeatures: [FontFeature.tabularFigures()],
    fontFamily: 'Fredoka',
    fontVariations: [FontVariation('wght', 700)],
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -0.4,
    color: BaonColors.ink,
  );
}

/// Colour for a risk state, from a probability. Used consistently across the
/// dashboard, forecast and affordability screens so a risk always looks the
/// same everywhere it appears.
Color riskColorFor(double probability) {
  if (probability < 0.10) {
    return BaonColors.safe;
  }
  if (probability < 0.35) {
    return BaonColors.tight;
  }
  return BaonColors.risky;
}

Color riskSoftColorFor(double probability) {
  if (probability < 0.10) {
    return BaonColors.safeSoft;
  }
  if (probability < 0.35) {
    return BaonColors.tightSoft;
  }
  return BaonColors.riskySoft;
}

String riskLabelFor(double probability) {
  if (probability < 0.10) {
    return 'SAFE';
  }
  if (probability < 0.35) {
    return 'TIGHT';
  }
  return 'RISKY';
}
