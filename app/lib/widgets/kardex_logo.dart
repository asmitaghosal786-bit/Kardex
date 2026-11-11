import 'package:flutter/material.dart';

class KardexLogo extends StatelessWidget {
  final double size;
  final Color color;

  const KardexLogo({
    super.key,
    this.size = 32.0,
    this.color = const Color(0xFF1B4332),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _KardexLogoPainter(color: color),
      ),
    );
  }
}

class _KardexLogoPainter extends CustomPainter {
  final Color color;
  _KardexLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Vertical bar on the left
    final double barWidth = size.width * 0.22;
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, barWidth, size.height),
      Radius.circular(barWidth * 0.2),
    );
    canvas.drawRRect(barRect, fillPaint);

    // Chevron on the right
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = barWidth * 0.95
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    final path = Path();
    final double startX = barWidth * 1.3;
    final double endX = size.width;
    
    path.moveTo(endX, size.height * 0.05);
    path.lineTo(startX, size.height * 0.5);
    path.lineTo(endX, size.height * 0.95);

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _KardexLogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
