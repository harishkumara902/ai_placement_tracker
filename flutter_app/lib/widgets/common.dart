import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class DotGridBackground extends StatefulWidget {
  const DotGridBackground({required this.child, super.key});
  final Widget child;

  @override
  State<DotGridBackground> createState() => _DotGridBackgroundState();
}

class _DotGridBackgroundState extends State<DotGridBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) =>
          CustomPaint(painter: _DotPainter(controller.value), child: child),
      child: widget.child,
    );
  }
}

class _DotPainter extends CustomPainter {
  _DotPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.background);
    final paint = Paint()..color = AppColors.indigo.withValues(alpha: 0.13);
    const spacing = 36.0;
    final offset = progress * spacing;
    for (double x = -spacing + offset; x < size.width; x += spacing) {
      for (double y = -spacing + offset; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.15, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.onTap,
    super.key,
  });
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.panel,
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ),
    );
    return onTap == null
        ? body
        : InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: body,
          );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {this.subtitle, super.key});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 5),
            Text(subtitle!, style: const TextStyle(color: AppColors.muted)),
          ],
        ],
      ),
    );
  }
}

class LoadingButton extends StatelessWidget {
  const LoadingButton({
    required this.label,
    required this.loading,
    required this.onPressed,
    this.icon,
    super.key,
  });
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon ?? Icons.auto_awesome_rounded, size: 18),
      label: Text(loading ? 'Working...' : label),
    );
  }
}

class SkillBadge extends StatelessWidget {
  const SkillBadge(
    this.text, {
    this.color = AppColors.indigo,
    this.selected = true,
    this.onTap,
    super.key,
  });
  final String text;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: selected ? color.withValues(alpha: 0.16) : Colors.transparent,
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.6) : AppColors.border,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: selected ? color : AppColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class AnimatedScoreRing extends StatelessWidget {
  const AnimatedScoreRing({required this.score, this.size = 148, super.key});
  final double score;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(value / 100),
          child: Center(
            child: Text(
              '${value.round()}%',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawArc(
      rect.deflate(9),
      -math.pi / 2,
      math.pi * 2,
      false,
      Paint()
        ..color = AppColors.indigo.withValues(alpha: 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9,
    );
    canvas.drawArc(
      rect.deflate(9),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.indigo, AppColors.amber],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 9,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class Gauge extends StatelessWidget {
  const Gauge(this.value, {super.key});
  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      width: 240,
      child: CustomPaint(
        painter: _GaugePainter(value / 100),
        child: Align(
          alignment: const Alignment(0, .45),
          child: Text(
            '${value.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(12, 10, size.width - 24, (size.width - 24));
    final background = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..color = Colors.white10;
    final active = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [AppColors.amber, AppColors.success],
      ).createShader(rect);
    canvas.drawArc(rect, math.pi, math.pi, false, background);
    canvas.drawArc(rect, math.pi, math.pi * progress, false, active);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

void showMessage(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            error ? Icons.error_outline : Icons.check_circle_outline,
            color: error ? AppColors.danger : AppColors.success,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}
