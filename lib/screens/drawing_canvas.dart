import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/drawing_point.dart';

class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({super.key});

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final GlobalKey _canvasKey = GlobalKey(); // Capturar a imagem e extrair a cor (Conta-gotas)
  
  // Estado atual dos desenhos
  List<DrawingElement> _elements = []; //Já foi desenhado
  DrawingElement? _currentElement; //Sendo desenhado "agora"
  
  // Histórico para Undo e Redo
  final List<List<DrawingElement>> _undoHistory = []; //Função desfazer
  final List<List<DrawingElement>> _redoHistory = []; //Função refazer
  
  Color _selectedColor = Colors.black; //Cor padrão 
  double _strokeWidth = 5.0; //Espessura padrão
  
  ToolType _activeTool = ToolType.brush; //Ferramenta padrão

  void _onPanStart(DragStartDetails details) {
    if (_activeTool == ToolType.eyedropper) { //Para de "rabistar" para o conta-gotas ler o pixel selecionado
      _pickColor(details.localPosition);
      return;
    }

    _undoHistory.add(List.from(_elements));
    _redoHistory.clear();

    final paint = Paint()
      ..color = _activeTool == ToolType.eraser ? Colors.white : _selectedColor
      ..strokeCap = StrokeCap.round
      ..style = (_activeTool == ToolType.rectangle || _activeTool == ToolType.circle) 
          ? PaintingStyle.stroke 
          : PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    if (_activeTool == ToolType.spray) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, _strokeWidth);
    }

    setState(() {
      _currentElement = DrawingElement(
        toolType: _activeTool,
        paint: paint,
        points: [details.localPosition],
      );
      _elements.add(_currentElement!);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_activeTool == ToolType.eyedropper || _currentElement == null) return;

    setState(() {
      if (_activeTool == ToolType.brush || _activeTool == ToolType.eraser || _activeTool == ToolType.spray) {
        // Traço contínuo
        _currentElement!.points.add(details.localPosition);
      } else {
        // Formas geométricas: atualiza apenas o ponto final
        if (_currentElement!.points.length == 1) {
          _currentElement!.points.add(details.localPosition);
        } else {
          _currentElement!.points[1] = details.localPosition;
        }
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _currentElement = null;
  }
  //Conta-Gotas
  Future<void> _pickColor(Offset position) async {
    try {
      RenderRepaintBoundary boundary = _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return;

      double dpr = MediaQuery.of(context).devicePixelRatio;
      int x = (position.dx * dpr).toInt();
      int y = (position.dy * dpr).toInt();

      int byteOffset = (y * image.width + x) * 4;
      Uint8List bytes = byteData.buffer.asUint8List();

      if (byteOffset >= 0 && byteOffset < bytes.length) {
        int r = bytes[byteOffset];
        int g = bytes[byteOffset + 1];
        int b = bytes[byteOffset + 2];
        int a = bytes[byteOffset + 3];
        
        setState(() {
          _selectedColor = Color.fromARGB(a, r, g, b);
          _activeTool = ToolType.brush;
        });
      }
    } catch (e) {
      debugPrint("Erro ao capturar cor: $e");
    }
  }

  void _undo() {
    if (_undoHistory.isNotEmpty) {
      setState(() {
        _redoHistory.add(List.from(_elements));
        _elements = _undoHistory.removeLast();
      });
    }
  }

  void _redo() {
    if (_redoHistory.isNotEmpty) {
      setState(() {
        _undoHistory.add(List.from(_elements));
        _elements = _redoHistory.removeLast();
      });
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Círculo Cromático'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
                if (_activeTool == ToolType.eraser || _activeTool == ToolType.eyedropper) {
                  _activeTool = ToolType.brush;
                }
              });
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Confirmar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('BeeCreative', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFFF3B0),
        foregroundColor: Colors.orange,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Desfazer',
            onPressed: _undoHistory.isNotEmpty ? _undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Refazer',
            onPressed: _redoHistory.isNotEmpty ? _redo : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Limpar Tela',
            onPressed: () {
              setState(() {
                _undoHistory.add(List.from(_elements));
                _redoHistory.clear();
                _elements.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Área de Desenho
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    onTapDown: (details) {
                      // O toque rápido na tela também pega a cor se o conta-gotas estiver ativo!
                      if (_activeTool == ToolType.eyedropper) {
                        _pickColor(details.localPosition);
                      }
                    },
                    child: RepaintBoundary(
                      key: _canvasKey,
                      child: Container(
                        color: Colors.white,
                        child: CustomPaint(
                          painter: DrawingPainter(elements: _elements),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Barra de Ferramentas
          _buildToolBar(),
        ],
      ),
    );
  }

  Widget _buildToolBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: const ui.Color.fromARGB(255, 255, 229, 157).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ferramentas de pintura e formas
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _toolButton(icon: Icons.brush, tool: ToolType.brush),
                _toolButton(icon: Icons.blur_on, tool: ToolType.spray),
                _toolButton(icon: Icons.cleaning_services_outlined, tool: ToolType.eraser), // Borracha
                Container(width: 1, height: 30, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),
                _toolButton(icon: Icons.crop_square, tool: ToolType.rectangle),
                _toolButton(icon: Icons.circle_outlined, tool: ToolType.circle),
                _toolButton(icon: Icons.horizontal_rule, tool: ToolType.line),
                Container(width: 1, height: 30, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),
                _toolButton(icon: Icons.colorize, tool: ToolType.eyedropper),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Círculo Cromático + Cores Rápidas
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showColorPicker,
                  child: Container(
                    height: 40, width: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [Colors.red, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.red],
                      ),
                    ),
                    child: const Icon(Icons.palette, color: Colors.white, size: 20), // Botão de abrir o Color Picker
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),
                _colorWidget(Colors.black),
                _colorWidget(Colors.red),
                _colorWidget(Colors.blue),
                _colorWidget(Colors.green),
                _colorWidget(Colors.amber),
                _colorWidget(Colors.purple),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Ajuste de Espessura do Pincel
          Row(
            children: [
              const Icon(Icons.line_weight, size: 20, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: Slider(
                  value: _strokeWidth,
                  min: 1.0,
                  max: 40.0,
                  activeColor: _activeTool == ToolType.eraser ? Colors.grey : _selectedColor,
                  inactiveColor: Colors.grey[300],
                  onChanged: (val) {
                    setState(() {
                      _strokeWidth = val;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Text('${_strokeWidth.round()}px', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toolButton({required IconData icon, required ToolType tool}) {
    bool isActive = _activeTool == tool;
    return GestureDetector(
      onTap: () => setState(() => _activeTool = tool),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? Colors.orange.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? Colors.orange : Colors.transparent, width: 2),
        ),
        child: Icon(icon, color: isActive ? Colors.orange : Colors.grey[600]),
      ),
    );
  }

  Widget _colorWidget(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
          if (_activeTool == ToolType.eraser || _activeTool == ToolType.eyedropper) {
            _activeTool = ToolType.brush; 
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        height: 40, width: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: (_activeTool != ToolType.eraser && _selectedColor == color) ? Colors.black : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3)),
          ],
        ),
      ),
    );
  }
}

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
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}
