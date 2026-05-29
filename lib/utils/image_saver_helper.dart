import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';//Ajuda a achar pastas temporárias no celular

// Função pra capturar o canvas e salvar na galeria do dispositivo
Future<void> saveCanvasToDevice({
  required GlobalKey canvasKey,
  required BuildContext context,
}) async {
  try {
    // Mostra aviso de "Salvando..." pro usuário
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Salvando desenho na galeria...')),
    );

    // Encontra o RenderObject do Canvas através da GlobalKey
    final RenderRepaintBoundary? boundary = 
        canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    
    if (boundary == null) return;

    // Transforma o que está desenhado no RepaintBoundary em uma imagem
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData == null) return;

    // Converte os bytes em Uint8List
    final Uint8List pngBytes = byteData.buffer.asUint8List();

    // Pega o diretório temporário do sistema
    final directory = await getTemporaryDirectory();
    // Define um nome único usando o timestamp atual para não sobrepor arquivos
    final String filePath = '${directory.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png';
    final File file = File(filePath);
    
    // Grava os bytes brutos dentro do arquivo temporário criado
    await file.writeAsBytes(pngBytes);

    // Agora passamos a STRING do caminho ('filePath') que o Gal exige
    await Gal.putImage(filePath);

    // Avisa o usuário que deu certo
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Desenho salvo com sucesso na Galeria! 🎨📱'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    debugPrint("Erro ao salvar imagem: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar desenho: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}