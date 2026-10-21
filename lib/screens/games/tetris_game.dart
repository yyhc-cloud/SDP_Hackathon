import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/township_state.dart';

class TetrisGame extends StatefulWidget {
  const TetrisGame({super.key});

  @override
  State<TetrisGame> createState() => _TetrisGameState();
}

enum Tetromino { i, o, t, s, z, j, l }

class _TetrisGameState extends State<TetrisGame> {
  static const int cols = 10;
  static const int rows = 16;

  late List<List<Color?>> _board;
  Timer? _timer;
  int _score = 0;
  int _linesCleared = 0;
  bool _isGameOver = false;
  bool _isPaused = false;

  // Current falling piece state
  Tetromino _currentPiece = Tetromino.i;
  List<Point> _currentBlocks = [];
  int _currentX = 0;
  int _currentY = 0;

  final math.Random _random = math.Random();

  static const Map<Tetromino, Color> _colors = {
    Tetromino.i: Color(0xFF00ACC1), // Cyan - Plastic Bales
    Tetromino.o: Color(0xFFFFB300), // Amber - Solar Modules
    Tetromino.t: Color(0xFF8E24AA), // Purple - E-Waste
    Tetromino.s: Color(0xFF43A047), // Green - Organic Bales
    Tetromino.z: Color(0xFFE53935), // Red - Hazardous Packs
    Tetromino.j: Color(0xFF1E88E5), // Blue - Glass Bales
    Tetromino.l: Color(0xFFFB8C00), // Orange - Aluminium Bales
  };

  static const Map<Tetromino, List<Point>> _shapes = {
    Tetromino.i: [Point(0, 1), Point(1, 1), Point(2, 1), Point(3, 1)],
    Tetromino.o: [Point(1, 0), Point(2, 0), Point(1, 1), Point(2, 1)],
    Tetromino.t: [Point(1, 0), Point(0, 1), Point(1, 1), Point(2, 1)],
    Tetromino.s: [Point(1, 0), Point(2, 0), Point(0, 1), Point(1, 1)],
    Tetromino.z: [Point(0, 0), Point(1, 0), Point(1, 1), Point(2, 1)],
    Tetromino.j: [Point(0, 0), Point(0, 1), Point(1, 1), Point(2, 1)],
    Tetromino.l: [Point(2, 0), Point(0, 1), Point(1, 1), Point(2, 1)],
  };

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _board = List.generate(rows, (_) => List.generate(cols, (_) => null));
    _score = 0;
    _linesCleared = 0;
    _isGameOver = false;
    _isPaused = false;
    _timer?.cancel();

    _spawnNewPiece();

    _timer = Timer.periodic(const Duration(milliseconds: 550), (timer) {
      if (!mounted || _isGameOver || _isPaused) return;
      _moveDown();
    });
  }

  void _spawnNewPiece() {
    final values = Tetromino.values;
    _currentPiece = values[_random.nextInt(values.length)];
    final shape = _shapes[_currentPiece]!;
    _currentBlocks = shape.map((p) => Point(p.x, p.y)).toList();
    _currentX = (cols ~/ 2) - 2;
    _currentY = 0;

    // Check collision on spawn (Game Over)
    for (final p in _currentBlocks) {
      final bx = _currentX + p.x;
      final by = _currentY + p.y;
      if (by >= 0 && by < rows && bx >= 0 && bx < cols && _board[by][bx] != null) {
        _finishGame();
        return;
      }
    }

    setState(() {});
  }

  bool _canMove(int targetX, int targetY, List<Point> blocks) {
    for (final p in blocks) {
      final x = targetX + p.x;
      final y = targetY + p.y;
      if (x < 0 || x >= cols || y >= rows) return false;
      if (y >= 0 && _board[y][x] != null) return false;
    }
    return true;
  }

  void _moveDown() {
    if (_canMove(_currentX, _currentY + 1, _currentBlocks)) {
      setState(() {
        _currentY++;
      });
    } else {
      _lockPiece();
    }
  }

  void _moveLeft() {
    if (_isGameOver || _isPaused) return;
    if (_canMove(_currentX - 1, _currentY, _currentBlocks)) {
      setState(() {
        _currentX--;
      });
    }
  }

  void _moveRight() {
    if (_isGameOver || _isPaused) return;
    if (_canMove(_currentX + 1, _currentY, _currentBlocks)) {
      setState(() {
        _currentX++;
      });
    }
  }

  void _rotate() {
    if (_isGameOver || _isPaused || _currentPiece == Tetromino.o) return;

    // 90 degree clockwise rotation around center
    final rotated = _currentBlocks.map((p) => Point(3 - p.y, p.x)).toList();
    if (_canMove(_currentX, _currentY, rotated)) {
      setState(() {
        _currentBlocks = rotated;
      });
    } else if (_canMove(_currentX - 1, _currentY, rotated)) {
      // Wall kick left
      setState(() {
        _currentX--;
        _currentBlocks = rotated;
      });
    } else if (_canMove(_currentX + 1, _currentY, rotated)) {
      // Wall kick right
      setState(() {
        _currentX++;
        _currentBlocks = rotated;
      });
    }
  }

  void _hardDrop() {
    if (_isGameOver || _isPaused) return;
    int dropDistance = 0;
    while (_canMove(_currentX, _currentY + dropDistance + 1, _currentBlocks)) {
      dropDistance++;
    }
    _currentY += dropDistance;
    _score += dropDistance * 2;
    _lockPiece();
  }

  void _lockPiece() {
    for (final p in _currentBlocks) {
      final x = _currentX + p.x;
      final y = _currentY + p.y;
      if (y >= 0 && y < rows && x >= 0 && x < cols) {
        _board[y][x] = _colors[_currentPiece];
      }
    }

    _score += 15;
    _clearLines();
    _spawnNewPiece();
  }

  void _clearLines() {
    int lines = 0;
    for (int r = rows - 1; r >= 0; r--) {
      if (_board[r].every((c) => c != null)) {
        lines++;
        _board.removeAt(r);
        _board.insert(0, List.generate(cols, (_) => null));
        r++; // Recheck same row index after shift
      }
    }

    if (lines > 0) {
      _linesCleared += lines;
      if (lines == 1) _score += 100;
      if (lines == 2) _score += 250;
      if (lines == 3) _score += 450;
      if (lines >= 4) _score += 800; // Tetris 4-line bale crush!
    }
  }

  void _finishGame() {
    setState(() {
      _isGameOver = true;
    });
    _timer?.cancel();
    TownshipState.instance.recordGameScore('tetris', _score);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232A),
      appBar: AppBar(
        title: const Text('Eco-Bale Tetris • Compactor'),
        backgroundColor: const Color(0xFF15181E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
            onPressed: () {
              setState(() {
                _isPaused = !_isPaused;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _startNewGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Dashboard
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: const Color(0xFF282E37),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TetrisStat(label: 'SCORE', value: '$_score', color: Colors.cyanAccent),
                  _TetrisStat(label: 'BALES COMPACTED', value: '$_linesCleared lines', color: Colors.amberAccent),
                  _TetrisStat(
                    label: 'STATUS',
                    value: _isGameOver ? 'COMPACTED' : (_isPaused ? 'PAUSED' : 'CRUSHING'),
                    color: _isGameOver ? Colors.redAccent : Colors.greenAccent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Compactor 10x16 Grid
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: cols / rows,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101317),
                      border: Border.all(color: Colors.cyan.shade800, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [BoxShadow(color: Colors.cyan, blurRadius: 4, spreadRadius: -2)],
                    ),
                    child: CustomPaint(
                      painter: _TetrisBoardPainter(
                        board: _board,
                        currentPiece: _currentPiece,
                        currentBlocks: _currentBlocks,
                        currentX: _currentX,
                        currentY: _currentY,
                        colors: _colors,
                        rows: rows,
                        cols: cols,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Controls Dock
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF15181E),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlButton(icon: Icons.arrow_back_rounded, label: 'Left', onTap: _moveLeft),
                  _ControlButton(icon: Icons.arrow_downward_rounded, label: 'Soft', onTap: _moveDown),
                  _ControlButton(icon: Icons.rotate_right_rounded, label: 'Rotate', onTap: _rotate, highlight: true),
                  _ControlButton(icon: Icons.arrow_forward_rounded, label: 'Right', onTap: _moveRight),
                  _ControlButton(icon: Icons.keyboard_double_arrow_down_rounded, label: 'Drop', onTap: _hardDrop, color: Colors.amber),
                ],
              ),
            ),

            // Game Over Modal Overlay
            if (_isGameOver)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF282E37),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.cyanAccent),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📦 BALE COMPACTOR FULL!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.cyanAccent)),
                    const SizedBox(height: 4),
                    Text('You compacted $_linesCleared complete bales of township waste!', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ResultPill(label: 'Score', value: '$_score', color: Colors.cyanAccent),
                        _ResultPill(label: 'Green Pts', value: '+${(_score ~/ 10).clamp(10, 150)}', color: Colors.greenAccent),
                        _ResultPill(label: 'War Power', value: '+${(_score ~/ 5).clamp(20, 300)}', color: Colors.amberAccent),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.white70),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('GameHub'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
                            onPressed: _startNewGame,
                            child: const Text('Play Again', style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TetrisStat extends StatelessWidget {
  const _TetrisStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white60)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlight = false,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? (highlight ? Colors.cyanAccent : Colors.white);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: highlight ? Colors.cyan.shade900.withValues(alpha: 0.6) : Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: highlight ? Colors.cyanAccent : Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: effectiveColor, size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: effectiveColor, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _ResultPill extends StatelessWidget {
  const _ResultPill({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}

class _TetrisBoardPainter extends CustomPainter {
  _TetrisBoardPainter({
    required this.board,
    required this.currentPiece,
    required this.currentBlocks,
    required this.currentX,
    required this.currentY,
    required this.colors,
    required this.rows,
    required this.cols,
  });

  final List<List<Color?>> board;
  final Tetromino currentPiece;
  final List<Point> currentBlocks;
  final int currentX;
  final int currentY;
  final Map<Tetromino, Color> colors;
  final int rows;
  final int cols;

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke;

    // Draw grid lines
    for (int r = 0; r <= rows; r++) {
      canvas.drawLine(Offset(0, r * cellH), Offset(size.width, r * cellH), gridPaint);
    }
    for (int c = 0; c <= cols; c++) {
      canvas.drawLine(Offset(c * cellW, 0), Offset(c * cellW, size.height), gridPaint);
    }

    // Draw locked cells
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final color = board[r][c];
        if (color != null) {
          _drawBlock(canvas, c * cellW, r * cellH, cellW, cellH, color);
        }
      }
    }

    // Draw falling piece
    final currentColor = colors[currentPiece]!;
    for (final p in currentBlocks) {
      final x = currentX + p.x;
      final y = currentY + p.y;
      if (y >= 0 && y < rows && x >= 0 && x < cols) {
        _drawBlock(canvas, x * cellW, y * cellH, cellW, cellH, currentColor);
      }
    }
  }

  void _drawBlock(Canvas canvas, double x, double y, double w, double h, Color color) {
    final rect = Rect.fromLTWH(x + 1, y + 1, w - 2, h - 2);
    final paint = Paint()..color = color;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), paint);

    // Subtle highlight rim
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _TetrisBoardPainter oldDelegate) => true;
}

class Point {
  const Point(this.x, this.y);
  final int x;
  final int y;
}
