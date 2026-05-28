import 'package:flutter/material.dart';

//Ferramentas enumeradas 
enum ToolType { brush, eraser, spray, rectangle, circle, line, eyedropper }

// Representa um elemento individual no desenho
class DrawingElement {
  final ToolType toolType; //Guarda ferramenta usada
  final Paint paint; //Guarda cor e espessura usada
  final List<Offset> points; //Coordenada x, y

  DrawingElement({
    required this.toolType,
    required this.paint,
    required this.points,
  });
}
