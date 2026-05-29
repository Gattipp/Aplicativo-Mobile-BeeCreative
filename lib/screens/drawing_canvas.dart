// import 'dart:ui' as ui;
// import 'dart:typed_data';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/drawing_point.dart';
import '../widgets/drawing_painter.dart';
import '../widgets/tool_bar_widget.dart';
import '../utils/color_picker_helper.dart';
import '../utils/image_saver_helper.dart';

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

  bool _isDarkMode = false;

  void _onPanStart(DragStartDetails details) async {
    if (_activeTool == ToolType.eyedropper) { 
      // 🛠️ Nova chamada do helper modificado:
      final Color? detectedColor = await pickColor(
        position: details.localPosition,
        canvasKey: _canvasKey,
        context: context,
      );

      if (detectedColor != null) {
        setState(() {
          _selectedColor = detectedColor;
          _activeTool = ToolType.brush; 
        });
      }
      return;
    }

    _undoHistory.add(List.from(_elements));
    _redoHistory.clear();

    final paint = Paint()
      ..color = _activeTool == ToolType.eraser ? _canvasColor : _selectedColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke //mantem o traço em forma de linha/retângulo/circulo sem preencher
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
    print("Arrastando o dedo na posição: ${details.localPosition}");
    if (_activeTool == ToolType.eyedropper || _currentElement == null) return;

    setState(() {
      if (_activeTool == ToolType.brush || _activeTool == ToolType.eraser || _activeTool == ToolType.spray) {
        _currentElement!.points.add(details.localPosition);
      } else {
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

  // Cores dinâmicas para o layout
  Color get _backgroundColor => _isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[100]!;
  Color get _canvasColor => _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  Color get _appBarColor => _isDarkMode ? const Color(0xFF121212) : const Color(0xFFFFF3B0);
  Color get _appBarTextColor => _isDarkMode ? Colors.orange : Colors.orange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor, // 🎨 Cor de fundo dinâmica
      appBar: AppBar(
        title: const Text('BeeCreative', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _appBarColor, // 🎨 Cor da AppBar dinâmica
        foregroundColor: _appBarTextColor,
        elevation: 0,
        actions: [
          IconButton(
            //modo escuro
            icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            tooltip: _isDarkMode ? 'Modo Claro' : 'Modo Escuro',
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
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
            icon: const Icon(Icons.save_alt, color: Colors.blue),
            tooltip: 'Salvar Desenho',
            onPressed: () async {
              await saveCanvasToDevice(
                canvasKey: _canvasKey,
                context: context,
              );
            },
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
                  color: _canvasColor, // 🎨 Cor dinâmica da borda/fundo externa
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    onTapDown: (details) async {
                      if (_activeTool == ToolType.eyedropper) {
                        final Color? detectedColor = await pickColor(
                          position: details.localPosition,
                          canvasKey: _canvasKey,
                          context: context,
                        );
                        if (detectedColor != null) {
                          setState(() {
                            _selectedColor = detectedColor;
                            _activeTool = ToolType.brush;
                          });
                        }
                      }
                    },
                    child: RepaintBoundary(
                      key: _canvasKey,
                      child: Container(
                        color: _canvasColor, // 🎨 Cor da folha de desenho dinâmica!
                        child: CustomPaint(
                          painter: DrawingPainter(elements: List.from(_elements)),
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
          ToolBarWidget(
            activeTool: _activeTool,
            strokeWidth: _strokeWidth,
            selectedColor: _selectedColor,
            onToolChanged: (tool) => setState(() => _activeTool = tool),
            onStrokeWidthChanged: (val) => setState(() => _strokeWidth = val),
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
                if (_activeTool == ToolType.eraser || _activeTool == ToolType.eyedropper) {
                  _activeTool = ToolType.brush;
                }
              });
            },
            onShowColorPicker: _showColorPicker, 
          ),
        ],
      ),
    );
  }
}

