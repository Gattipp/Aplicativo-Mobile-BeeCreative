import 'package:flutter/material.dart';
import '../models/drawing_point.dart';

/// Pintor customizado
class DrawingPainter extends CustomPainter {
  final List<DrawingElement> elements;

  DrawingPainter({required this.elements});

  @override
  void paint(Canvas canvas, Size size) {
    for (var element in elements) {
      if (element.points.isEmpty) continue;

      if (element.toolType == ToolType.brush || element.toolType == ToolType.eraser || element.toolType == ToolType.spray) {
        for (int i = 0; i < element.points.length - 1; i++) {
          canvas.drawLine(element.points[i], element.points[i + 1], element.paint);
        }
      } else if (element.toolType == ToolType.line && element.points.length >= 2) {
        canvas.drawLine(element.points.first, element.points.last, element.paint);
      } else if (element.toolType == ToolType.rectangle && element.points.length >= 2) {
        Rect rect = Rect.fromPoints(element.points.first, element.points.last);
        canvas.drawRect(rect, element.paint);
      } else if (element.toolType == ToolType.circle && element.points.length >= 2) {
        Offset center = element.points.first;
        double radius = (element.points.last - center).distance;
        canvas.drawCircle(center, radius, element.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    // Retorna true para atualizar a tela sempre que a lista de elementos mudar
    return oldDelegate.elements != elements;
  }
  
}