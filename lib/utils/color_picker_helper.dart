import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Função utilitária para capturar a cor de um pixel na tela usando uma GlobalKey
Future<Color?> pickColor({
  required Offset position,
  required GlobalKey canvasKey,
  required BuildContext context,
}) async {
  try {
    // Encontra o RenderObject do Canvas para ler os pixels
    final RenderRepaintBoundary? boundary = 
        canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    
    if (boundary == null) return null;

    // Converte a renderização em uma imagem de pixels
    ui.Image image = await boundary.toImage();
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    
    if (byteData == null) return null;

    // Ajusta as coordenadas com base na densidade de pixels do dispositivo
    double dpr = MediaQuery.of(context).devicePixelRatio;
    int x = (position.dx * dpr).toInt();
    int y = (position.dy * dpr).toInt();

    // Garante que o clique está dentro dos limites da imagem gerada
    if (x < 0 || x >= image.width || y < 0 || y >= image.height) return null;

    // Calcula a posição do byte exato (RGBA = 4 bytes por pixel)
    int byteOffset = (y * image.width + x) * 4;
    Uint8List bytes = byteData.buffer.asUint8List();

    if (byteOffset >= 0 && byteOffset < bytes.length) {
      int r = bytes[byteOffset];
      int g = bytes[byteOffset + 1];
      int b = bytes[byteOffset + 2];
      // Retorna a cor exata encontrada naquele pixel
      return Color.fromARGB(255, r, g, b);
    }
  } catch (e) {
    debugPrint("Erro ao capturar cor: $e");
  }
  return null;
}