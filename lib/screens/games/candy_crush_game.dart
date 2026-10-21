import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/township_state.dart';
import '../../theme/app_colors.dart';

class EcoItem {
  EcoItem({required this.type, required this.id});
  int type; // 0: Leaf, 1: Bottle, 2: Battery, 3: Can, 4: Glass
  final int id;
}

class CandyCrushGame extends StatefulWidget {
  const CandyCrushGame({super.key});

  @override
  State<CandyCrushGame> createState() => _CandyCrushGameState();
}

class _CandyCrushGameState extends State<CandyCrushGame> {
  static const int rows = 6;
  static const int cols = 6;

  late List<List<EcoItem>> _grid;
  int _score = 0;
  int _movesLeft = 20;
  int? _selectedRow;
  int? _selectedCol;
  bool _isProcessing = false;
  bool _isGameOver = false;
  int _comboCount = 0;
  String _message = 'Swap adjacent recyclables to create lines of 3 or more!';

  final math.Random _random = math.Random();
  int _nextId = 0;

  static const List<Map<String, dynamic>> _itemDefs = [
    {'icon': '🍏', 'label': 'Organics', 'color': Color(0xFF43A047)},
    {'icon': '🧴', 'label': 'Plastics', 'color': Color(0xFF1E88E5)},
    {'icon': '🔋', 'label': 'E-Battery', 'color': Color(0xFFFFA000)},
    {'icon': '🥫', 'label': 'Aluminium', 'color': Color(0xFF78909C)},
    {'icon': '🫙', 'label': 'Glass', 'color': Color(0xFF8E24AA)},
  ];

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _score = 0;
    _movesLeft = 20;
    _selectedRow = null;
    _selectedCol = null;
    _isProcessing = false;
    _isGameOver = false;
    _comboCount = 0;
    _message = 'Swap adjacent recyclables to match 3 or more!';

    _initBoardWithoutMatches();
    setState(() {});
  }

  void _initBoardWithoutMatches() {
    final board = List.generate(rows, (_) => List.generate(cols, (_) => EcoItem(type: 0, id: 0)));
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        int t;
        do {
          t = _random.nextInt(_itemDefs.length);
        } while ((c >= 2 && board[r][c - 1].type == t && board[r][c - 2].type == t) ||
            (r >= 2 && board[r - 1][c].type == t && board[r - 2][c].type == t));
        board[r][c] = EcoItem(type: t, id: _nextId++);
      }
    }
    _grid = board;
  }

  void _onTileTap(int r, int c) async {
    if (_isProcessing || _isGameOver) return;

    if (_selectedRow == null) {
      setState(() {
        _selectedRow = r;
        _selectedCol = c;
      });
      return;
    }

    final prevR = _selectedRow!;
    final prevC = _selectedCol!;

    // Check adjacency
    final isAdjacent = (r == prevR && (c - prevC).abs() == 1) || (c == prevC && (r - prevR).abs() == 1);

    if (!isAdjacent) {
      setState(() {
        _selectedRow = r;
        _selectedCol = c;
      });
      return;
    }

    // Try swap
    setState(() {
      _selectedRow = null;
      _selectedCol = null;
      _isProcessing = true;
    });

    _swap(prevR, prevC, r, c);
    final hasMatches = _findMatches().isNotEmpty;

    if (!hasMatches) {
      // Revert swap
      await Future<void>.delayed(const Duration(milliseconds: 250));
      _swap(prevR, prevC, r, c);
      setState(() {
        _message = 'No match! Swapped back.';
        _isProcessing = false;
      });
      return;
    }

    _movesLeft--;
    _comboCount = 0;

    await _processBoardCascades();

    if (_movesLeft <= 0) {
      _finishGame();
    } else {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _swap(int r1, int c1, int r2, int c2) {
    final temp = _grid[r1][c1];
    _grid[r1][c1] = _grid[r2][c2];
    _grid[r2][c2] = temp;
  }

  Set<Point<int>> _findMatches() {
    final matched = <Point<int>>{};

    // Horizontal check
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols - 2; c++) {
        final t = _grid[r][c].type;
        if (t != -1 && t == _grid[r][c + 1].type && t == _grid[r][c + 2].type) {
          matched.add(Point(r, c));
          matched.add(Point(r, c + 1));
          matched.add(Point(r, c + 2));
        }
      }
    }

    // Vertical check
    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows - 2; r++) {
        final t = _grid[r][c].type;
        if (t != -1 && t == _grid[r + 1][c].type && t == _grid[r + 2][c].type) {
          matched.add(Point(r, c));
          matched.add(Point(r + 1, c));
          matched.add(Point(r + 2, c));
        }
      }
    }

    return matched;
  }

  Future<void> _processBoardCascades() async {
    while (true) {
      final matches = _findMatches();
      if (matches.isEmpty) break;

      _comboCount++;
      final earned = matches.length * 30 * _comboCount;
      _score += earned;

      setState(() {
        _message = _comboCount > 1 ? '✨ COMBO x$_comboCount! +$earned pts' : 'Crushed ${matches.length} recyclables! +$earned pts';
        for (final p in matches) {
          _grid[p.x][p.y].type = -1; // Mark removed
        }
      });

      await Future<void>.delayed(const Duration(milliseconds: 280));

      // Cascade down
      for (int c = 0; c < cols; c++) {
        int emptySpot = rows - 1;
        for (int r = rows - 1; r >= 0; r--) {
          if (_grid[r][c].type != -1) {
            if (emptySpot != r) {
              _grid[emptySpot][c] = _grid[r][c];
              _grid[r][c] = EcoItem(type: -1, id: _nextId++);
            }
            emptySpot--;
          }
        }
        // Fill top with new items
        for (int r = emptySpot; r >= 0; r--) {
          _grid[r][c] = EcoItem(type: _random.nextInt(_itemDefs.length), id: _nextId++);
        }
      }

      setState(() {});
      await Future<void>.delayed(const Duration(milliseconds: 260));
    }
  }

  void _finishGame() {
    setState(() {
      _isGameOver = true;
      _isProcessing = false;
    });
    TownshipState.instance.recordGameScore('candycrush', _score);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text('Candy Crush • Recyclables Match-3'),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Restart Game',
            onPressed: _startNewGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CrushStat(label: 'SCORE', value: '$_score', color: const Color(0xFF7B1FA2), icon: Icons.stars_rounded),
                  _CrushStat(
                    label: 'MOVES',
                    value: '$_movesLeft',
                    color: _movesLeft <= 5 ? Colors.red : Colors.blue.shade900,
                    icon: Icons.touch_app_rounded,
                  ),
                  _CrushStat(
                    label: 'TARGET',
                    value: '800',
                    color: _score >= 800 ? Colors.green : Colors.grey.shade700,
                    icon: Icons.flag_rounded,
                  ),
                ],
              ),
            ),

            // Message banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: const Color(0xFFEDE7F6),
              child: Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF4A148C)),
              ),
            ),
            const SizedBox(height: 12),

            // 6x6 Eco Game Board
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade900.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: rows * cols,
                      itemBuilder: (context, index) {
                        final r = index ~/ cols;
                        final c = index % cols;
                        final item = _grid[r][c];
                        final isSelected = (_selectedRow == r && _selectedCol == c);

                        if (item.type == -1) {
                          return const SizedBox.shrink();
                        }

                        final def = _itemDefs[item.type];
                        return GestureDetector(
                          onTap: () => _onTileTap(r, c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.amber.shade300 : (def['color'] as Color).withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.white24,
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected ? Colors.amber : Colors.black26,
                                  blurRadius: isSelected ? 8 : 2,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                def['icon'] as String,
                                style: TextStyle(fontSize: isSelected ? 30 : 26),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Game Over Modal Overlay
            if (_isGameOver)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('♻️ ECO-CRUSH COMPLETE!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF7B1FA2))),
                    const SizedBox(height: 6),
                    Text(
                      _score >= 800 ? 'Awesome! Target achieved for your township!' : 'Good effort! Keep recycling to master the combos!',
                      style: const TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ResultPill(label: 'Score', value: '$_score', color: Colors.purple),
                        _ResultPill(label: 'Green Pts', value: '+${(_score ~/ 10).clamp(10, 150)}', color: Colors.blue),
                        _ResultPill(label: 'War Power', value: '+${(_score ~/ 5).clamp(20, 300)}', color: Colors.amber.shade900),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Back to GameHub'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B1FA2), foregroundColor: Colors.white),
                            onPressed: _startNewGame,
                            child: const Text('Play Again'),
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

class _CrushStat extends StatelessWidget {
  const _CrushStat({required this.label, required this.value, required this.color, required this.icon});
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
          ],
        ),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}

class Point<T extends num> {
  const Point(this.x, this.y);
  final T x;
  final T y;

  @override
  bool operator ==(Object other) => other is Point && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}
