import 'package:flutter/material.dart';

enum ToolType { brush, eraser, spray, rectangle, circle, line, eyedropper }

/// Representa um elemento individual no desenho
class DrawingElement {
  final ToolType toolType;
  final Paint paint;
  final List<Offset> points;

  DrawingElement({
    required this.toolType,
    required this.paint,
    required this.points,
  });

  Map<String, dynamic> toJson() {
    return {
      'toolType': toolType.toString(),
      'color': paint.color.value,
      'strokeWidth': paint.strokeWidth,
      'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
    };
  }
}