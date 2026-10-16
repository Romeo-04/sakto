/// Shared glassmorphism widgets. Every screen builds cards, buttons and
/// badges from these instead of one-off styling.
library;

import 'dart:ui' show ImageFilter;

import 'package:baon/ui/glass_backdrop.dart';
import 'package:baon/ui/mascot.dart';
import 'package:baon/ui/tokens.dart';
import 'package:flutter/material.dart';

export 'package:baon/ui/glass_backdrop.dart' show GlassBackdrop;

/// A frosted pane: blurs whatever sits behind it inside a rounded clip, with
/// a light rim and a soft shadow.
class GlassPane extends StatelessWidget {
  const GlassPane({
    super.key,
    required this.child,
    this.color = BaonColors.surface,
    this.borderRadius = const BorderRadius.all(Radius.circular(Corner.card)),
    this.borderColor = BaonColors.border,
    this.shadowColor = BaonColors.ink,
    this.padding,
  });

  final Widget child;
  final Color color;
  final BorderRadius borderRadius;
  final Color borderColor;
  final Color shadowColor;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: SoftShadow.of(shadowColor),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: Glass.blur, sigmaY: Glass.blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(color: borderColor, width: BorderWeight.bold),
              color: color,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A frosted glass card. The base building block of every screen.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.color = BaonColors.surface,
    this.padding = const EdgeInsets.all(Space.lg),
    this.shadowColor = BaonColors.ink,
    this.onTap,
    this.borderColor = BaonColors.border,
  });

  final Widget child;
  final Color color;
  final EdgeInsets padding;
  final Color shadowColor;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget card = GlassPane(
      color: color,
      padding: padding,
      borderColor: borderColor,
      shadowColor: shadowColor,
      child: child,
    );
    if (onTap == null) {
      return card;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Corner.card),
        focusColor: BaonColors.accentSoft,
        child: card,
      ),
    );
  }
}

/// A rounded glass button with a soft glow that sinks slightly when tapped.
class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = BaonColors.ink,
    this.textColor = Colors.white,
    this.icon,
    this.expand = false,
  });

  const GlassButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
  }) : color = BaonColors.whiteGlass,
       textColor = BaonColors.ink;

  const GlassButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
  }) : color = BaonColors.risky,
       textColor = Colors.white;

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final IconData? icon;
  final bool expand;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final radius = BorderRadius.circular(Corner.pill);
    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 90),
      transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: SoftShadow.of(BaonColors.ink, depth: _pressed ? 2 : 5),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: Glass.blur, sigmaY: Glass.blur),
          child: Material(
            color: disabled
                ? Color.alphaBlend(const Color(0x99FFFFFF), widget.color)
                : widget.color,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(
                color: _focused ? BaonColors.accent : Colors.white,
                width: BorderWeight.bold,
              ),
            ),
            child: InkWell(
              onTap: widget.onPressed,
              onHighlightChanged: (value) => setState(() => _pressed = value),
              onFocusChange: (value) => setState(() => _focused = value),
              borderRadius: radius,
              child: Container(
                width: widget.expand ? double.infinity : null,
                constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.xl,
                  vertical: Space.md,
                ),
                child: Row(
                  mainAxisSize: widget.expand
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 20,
                        color: disabled
                            ? BaonColors.textMuted
                            : widget.textColor,
                      ),
                      const SizedBox(width: Space.sm),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        style: BaonType.button.copyWith(
                          color: disabled
                              ? BaonColors.textMuted
                              : widget.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small pill tag, used for a risk state or an envelope shape.
class GlassBadge extends StatelessWidget {
  const GlassBadge({
    super.key,
    required this.label,
    required this.color,
    this.foreground = BaonColors.ink,
  });

  final String label;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: BaonColors.border,
          width: BorderWeight.hairline,
        ),
        borderRadius: BorderRadius.circular(Corner.pill),
      ),
      child: Text(
        label,
        style: BaonType.label.copyWith(color: foreground, fontSize: 11),
      ),
    );
  }
}

/// A risk badge coloured and labelled from a probability. Used identically on
/// the dashboard, forecast and affordability screens.
class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.probability});

  final double probability;

  @override
  Widget build(BuildContext context) {
    return GlassBadge(
      label: riskLabelFor(probability),
      color: riskSoftColorFor(probability),
      foreground: BaonColors.ink,
    );
  }
}

/// A section heading with an optional action, never an eyebrow.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(title, style: BaonType.h2)),
        ?trailing,
      ],
    );
  }
}

/// A full-bleed banner used for warnings that need a next action, per
/// BUILD_PLAN.md Section 13: never show a red screen without a next action.
class WarningBanner extends StatelessWidget {
  const WarningBanner({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.color = BaonColors.riskySoft,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      color: color,
      padding: const EdgeInsets.all(Space.md),
      child: Row(
        children: <Widget>[
          const Icon(Icons.warning_rounded, color: BaonColors.risky),
          const SizedBox(width: Space.sm),
          Expanded(child: Text(message, style: BaonType.body)),
          const SizedBox(width: Space.sm),
          GlassButton(
            label: actionLabel,
            onPressed: onAction,
            color: BaonColors.ink,
          ),
        ],
      ),
    );
  }
}

/// A blank-slate message, used instead of an empty void.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Mascot(seed: title, mood: MascotMood.sleepy, size: 88),
            const SizedBox(height: Space.lg),
            Text(title, style: BaonType.h2, textAlign: TextAlign.center),
            const SizedBox(height: Space.sm),
            Text(
              message,
              style: BaonType.bodyMuted,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: Space.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A labelled amount input on a glass pane, built on a plain TextField.
class GlassAmountField extends StatelessWidget {
  const GlassAmountField({
    super.key,
    required this.label,
    required this.controller,
    this.autofocus = false,
    this.onSubmitted,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: BaonType.label),
        const SizedBox(height: Space.xs),
        GlassPane(
          borderRadius: const BorderRadius.all(Radius.circular(Corner.soft)),
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: BaonType.numberMd,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              prefixText: 'PHP  ',
              prefixStyle: BaonType.numberMd.copyWith(
                color: BaonColors.textMuted,
                fontSize: 20,
              ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Space.lg,
                vertical: Space.md,
              ),
            ),
          ),
        ),
        if (errorText != null) ...<Widget>[
          const SizedBox(height: Space.xs),
          Text(
            errorText!,
            style: BaonType.bodyMuted.copyWith(color: BaonColors.risky),
          ),
        ],
      ],
    );
  }
}

/// A single big number with its descriptive label below. The primary number
/// per screen that BUILD_PLAN.md Section 13 calls for.
class PrimaryNumber extends StatelessWidget {
  const PrimaryNumber({
    super.key,
    required this.label,
    required this.value,
    this.color = BaonColors.ink,
    this.large = true,
  });

  final String label;
  final String value;
  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: (large ? BaonType.numberLg : BaonType.numberMd).copyWith(
              color: color,
            ),
          ),
        ),
        const SizedBox(height: Space.xs),
        Text(label, style: BaonType.label),
      ],
    );
  }
}

/// A name plate takes the exact same seed as its envelope's mascot.
class NamePlate extends StatelessWidget {
  const NamePlate({super.key, required this.label, required this.seed});
  final String label;
  final String seed;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: Space.lg,
      vertical: Space.sm,
    ),
    decoration: BoxDecoration(
      color: MascotPalette.forSeed(seed).plate,
      borderRadius: BorderRadius.circular(Corner.pill),
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Text(label, style: BaonType.h2, textAlign: TextAlign.center),
  );
}

class RefillPill extends StatelessWidget {
  const RefillPill({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) =>
      GlassBadge(label: label, color: BaonColors.refill);
}

class RibbonTab extends StatelessWidget {
  const RibbonTab({super.key, required this.seed, this.label});
  final String seed;
  final String? label;
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _RibbonPainter(MascotPalette.forSeed(seed).ribbon, label == null),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 58),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Space.sm,
          Space.sm,
          Space.sm,
          Space.lg,
        ),
        child: label == null
            ? const SizedBox(width: 28, height: 30)
            : Text(
                label!,
                textAlign: TextAlign.center,
                style: BaonType.numberMd.copyWith(color: Colors.white),
              ),
      ),
    ),
  );
}

class _RibbonPainter extends CustomPainter {
  const _RibbonPainter(this.color, this.heart);
  final Color color;
  final bool heart;
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height - 10)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(path, Paint()..color = color);
    if (heart) {
      canvas.save();
      canvas.translate(size.width / 2, 23);
      canvas.scale(1.4);
      canvas.drawPath(heartPath(), Paint()..color = Colors.white);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_RibbonPainter old) =>
      color != old.color || heart != old.heart;
}

/// Material chip behavior, shared focus and selection styling, and a 48dp target.
class GlassChoice extends StatelessWidget {
  const GlassChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.avatar,
    this.expand = false,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? avatar;
  final bool expand;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 48),
    child: ChoiceChip(
      label: Text(label),
      avatar: avatar,
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      labelPadding: EdgeInsets.symmetric(
        horizontal: expand ? Space.lg : Space.sm,
      ),
    ),
  );
}

/// A compact identity used wherever one envelope is presented away from the roster.
class EnvelopeIdentity extends StatelessWidget {
  const EnvelopeIdentity({
    super.key,
    required this.label,
    this.mood = MascotMood.happy,
  });
  final String label;
  final MascotMood mood;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Mascot(seed: label, mood: mood, size: 48),
      const SizedBox(width: Space.sm),
      Flexible(
        child: NamePlate(label: label, seed: label),
      ),
    ],
  );
}
