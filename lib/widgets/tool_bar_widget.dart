import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/drawing_point.dart';

class ToolBarWidget extends StatelessWidget {
  // Parâmetros recebidos da tela principal (drawing_canvas.dart)
  final ToolType activeTool;
  final double strokeWidth;
  final Color selectedColor;
  final Function(ToolType) onToolChanged;
  final Function(double) onStrokeWidthChanged;
  final Function(Color) onColorChanged;
  final VoidCallback onShowColorPicker;

  const ToolBarWidget({
    super.key,
    required this.activeTool,
    required this.strokeWidth,
    required this.selectedColor,
    required this.onToolChanged,
    required this.onStrokeWidthChanged,
    required this.onColorChanged,
    required this.onShowColorPicker,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: const ui.Color.fromARGB(255, 255, 229, 157).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
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
                _buildToolButton(icon: Icons.brush, tool: ToolType.brush),
                _buildToolButton(icon: Icons.blur_on, tool: ToolType.spray),
                _buildToolButton(icon: Icons.cleaning_services_outlined, tool: ToolType.eraser), // Borracha
                Container(width: 1, height: 30, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),
                _buildToolButton(icon: Icons.crop_square, tool: ToolType.rectangle),
                _buildToolButton(icon: Icons.circle_outlined, tool: ToolType.circle),
                _buildToolButton(icon: Icons.horizontal_rule, tool: ToolType.line),
                Container(width: 1, height: 30, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),
                _buildToolButton(icon: Icons.colorize, tool: ToolType.eyedropper),
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
                  onTap: onShowColorPicker,
                  child: Container(
                    height: 40,
                    width: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [Colors.red, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.red],
                      ),
                    ),
                    child: const Icon(Icons.palette, color: Colors.white, size: 20),
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),
                _buildColorWidget(Colors.black),
                _buildColorWidget(Colors.red),
                _buildColorWidget(Colors.blue),
                _buildColorWidget(Colors.green),
                _buildColorWidget(Colors.amber),
                _buildColorWidget(Colors.purple),
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
                  value: strokeWidth,
                  min: 1.0,
                  max: 40.0,
                  activeColor: activeTool == ToolType.eraser ? Colors.grey : selectedColor,
                  inactiveColor: Colors.grey[300],
                  onChanged: onStrokeWidthChanged,
                ),
              ),
              const SizedBox(width: 10),
              Text('${strokeWidth.round()}px', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  // Widget dos botões de ferramenta interno
  Widget _buildToolButton({required IconData icon, required ToolType tool}) {
    bool isActive = activeTool == tool;
    return GestureDetector(
      onTap: () => onToolChanged(tool),
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

  // Widget de seleção de cores rápidas interno
  Widget _buildColorWidget(Color color) {
    bool isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () => onColorChanged(color),
      child: Container(
        height: 35,
        width: 35,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}