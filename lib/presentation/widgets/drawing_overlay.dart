import 'package:flutter/material.dart';

class DrawingOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const DrawingOverlay({super.key, required this.onClose});

  @override
  State<DrawingOverlay> createState() => _DrawingOverlayState();
}

class _DrawingOverlayState extends State<DrawingOverlay> {
  List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  Color _currentColor = Colors.red;
  double _strokeWidth = 4.0;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _currentStroke = [details.localPosition];
                  _strokes.add(List.from(_currentStroke));
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _currentStroke.add(details.localPosition);
                  _strokes.last = List.from(_currentStroke);
                });
              },
              onPanEnd: (details) {
                _currentStroke = [];
              },
              child: CustomPaint(
                painter: _DrawingPainter(strokes: _strokes, color: _currentColor, strokeWidth: _strokeWidth),
                size: Size.infinite,
              ),
            ),
            Positioned(
              left: 16,
              bottom: 100,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildColorBtn(Colors.red),
                    _buildColorBtn(Colors.blue),
                    _buildColorBtn(Colors.green),
                    _buildColorBtn(Colors.yellow),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.undo, color: Colors.white),
                      onPressed: () {
                        if (_strokes.isNotEmpty) {
                          setState(() => _strokes.removeLast());
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: () => setState(() => _strokes.clear()),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorBtn(Color color) {
    return GestureDetector(
      onTap: () => setState(() => _currentColor = color),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _currentColor == color ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color color;
  final double strokeWidth;

  _DrawingPainter({required this.strokes, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    return oldDelegate.strokes != strokes || oldDelegate.color != color;
  }
}
