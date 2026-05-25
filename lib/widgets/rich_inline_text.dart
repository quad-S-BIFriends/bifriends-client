import 'package:flutter/material.dart';
import '../models/learning_model.dart' show RichSpan, PlainSpan, FractionSpan;
import '../theme/app_colors.dart';

/// fraction randering widget, designed to be used within [RichInlineText].
class FractionWidget extends StatelessWidget {
  final int numerator;
  final int denominator;
  final double fontSize;
  final Color color;

  const FractionWidget({
    super.key,
    required this.numerator,
    required this.denominator,
    this.fontSize = 16,
    this.color = AppColors.textMain,
  });

  @override
  Widget build(BuildContext context) {
    final numSize = fontSize * 0.82;
    final barWidth = numSize * 1.5;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$numerator',
            style: TextStyle(
              fontSize: numSize,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.1,
            ),
          ),
          Container(
            height: 1.8,
            width: barWidth,
            color: color,
            margin: const EdgeInsets.symmetric(vertical: 1),
          ),
          Text(
            '$denominator',
            style: TextStyle(
              fontSize: numSize,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders a [List<RichSpan>] as inline text, with [FractionWidget]s embedded
/// via [WidgetSpan] for fraction segments.
class RichInlineText extends StatelessWidget {
  final List<RichSpan> spans;
  final TextStyle? style;
  final TextAlign textAlign;

  const RichInlineText({
    super.key,
    required this.spans,
    this.style,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final base = style ??
        const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textMain,
          height: 1.5,
        );
    final color = base.color ?? AppColors.textMain;

    return Text.rich(
      TextSpan(
        children: spans.map<InlineSpan>((span) {
          if (span is PlainSpan) {
            return TextSpan(text: span.value, style: base);
          }
          final f = span as FractionSpan;
          return WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: FractionWidget(
              numerator: f.numerator,
              denominator: f.denominator,
              fontSize: base.fontSize ?? 18,
              color: color,
            ),
          );
        }).toList(),
      ),
      textAlign: textAlign,
    );
  }
}
