import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/township_state.dart';
import '../../theme/app_colors.dart';

class PlantPlot {
  PlantPlot({required this.id, required this.moisture, this.isBloomed = false, this.plantType = 0});
  final int id;
  double moisture; // 0.0 to 1.0
  bool isBloomed;
  int plantType; // 0: Sunflower, 1: Lotus, 2: Orchid, 3: Hibiscus
}

class WaterPlantGame extends StatefulWidget {
  const WaterPlantGame({super.key});

  @override
  State<WaterPlantGame> createState() => _WaterPlantGameState();
}

class _WaterPlantGameState extends State<WaterPlantGame> {
  static const int gridSize = 4;
  late List<PlantPlot> _plots;
  int _score = 0;
  int _bloomsCount = 0;
  int _streak = 0;
  int _secondsLeft = 45;
  Timer? _gameTimer;
  Timer? _evaporationTimer;
  bool _isGameOver = false;
  final math.Random _random = math.Random();

  final List<String> _flowerIcons = ['🌻', '🪷', '🌺', '🌸', '🌼'];

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _score = 0;
    _bloomsCount = 0;
    _streak = 0;
    _secondsLeft = 45;
    _isGameOver = false;

    _plots = List.generate(gridSize * gridSize, (i) {
      return PlantPlot(
        id: i,
        moisture: _random.nextDouble() * 0.35,
        isBloomed: false,
        plantType: _random.nextInt(_flowerIcons.length),
      );
    });

    _gameTimer?.cancel();
    _evaporationTimer?.cancel();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        _evaporationTimer?.cancel();
        _finishGame();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });

    _evaporationTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (!mounted || _isGameOver) return;
      setState(() {
        for (final p in _plots) {
          if (!p.isBloomed) {
            p.moisture = (p.moisture - 0.04).clamp(0.0, 1.0);
          }
        }
      });
    });
  }

  void _waterPlot(int index) {
    if (_isGameOver) return;
    final target = _plots[index];
    if (target.isBloomed) return;

    setState(() {
      // Direct spray
      target.moisture += 0.40;
      if (target.moisture >= 1.0) {
        target.moisture = 1.0;
        target.isBloomed = true;
        _bloomsCount++;
        _streak++;
        _score += 50 + (_streak * 10);
      } else {
        _score += 5;
      }

      // Adjacent spray mist (row & column neighbors)
      final row = index ~/ gridSize;
      final col = index % gridSize;
      final neighbors = <int>[];
      if (row > 0) neighbors.add(index - gridSize);
      if (row < gridSize - 1) neighbors.add(index + gridSize);
      if (col > 0) neighbors.add(index - 1);
      if (col < gridSize - 1) neighbors.add(index + 1);

      for (final n in neighbors) {
        final p = _plots[n];
        if (!p.isBloomed) {
          p.moisture += 0.15;
          if (p.moisture >= 1.0) {
            p.moisture = 1.0;
            p.isBloomed = true;
            _bloomsCount++;
            _streak++;
            _score += 50 + (_streak * 10);
          }
        }
      }

      // Check if all plots bloomed - give large wave bonus and reset unbloomed
      if (_plots.every((p) => p.isBloomed)) {
        _score += 300;
        for (final p in _plots) {
          p.isBloomed = false;
          p.moisture = _random.nextDouble() * 0.2;
          p.plantType = _random.nextInt(_flowerIcons.length);
        }
      }
    });
  }

  void _finishGame() {
    setState(() {
      _isGameOver = true;
    });
    TownshipState.instance.recordGameScore('waterplant', _score);
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _evaporationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('WaterPlant • Wetland Nursery'),
        backgroundColor: const Color(0xFF2E7D32),
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
            // Status bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatItem(
                    label: 'SCORE',
                    value: '$_score',
                    color: const Color(0xFF2E7D32),
                    icon: Icons.stars_rounded,
                  ),
                  _StatItem(
                    label: 'TIME',
                    value: '${_secondsLeft}s',
                    color: _secondsLeft < 10 ? Colors.red : Colors.blue.shade800,
                    icon: Icons.timer_outlined,
                  ),
                  _StatItem(
                    label: 'BLOOMS',
                    value: '$_bloomsCount',
                    color: Colors.pink.shade600,
                    icon: Icons.local_florist_rounded,
                  ),
                  _StatItem(
                    label: 'STREAK',
                    value: 'x$_streak',
                    color: Colors.amber.shade800,
                    icon: Icons.bolt_rounded,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.water_drop_rounded, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap dry plots to spray recycled retention water! Surrounding beds receive mist.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 4x4 Flower Nursery Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: gridSize * gridSize,
                  itemBuilder: (context, index) {
                    final plot = _plots[index];
                    return GestureDetector(
                      onTap: () => _waterPlot(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: plot.isBloomed
                              ? Colors.pink.shade50
                              : Color.lerp(const Color(0xFFD7CCC8), const Color(0xFF81C784), plot.moisture),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: plot.isBloomed ? Colors.pink.shade300 : (plot.moisture > 0.6 ? Colors.green : Colors.brown.shade300),
                            width: plot.isBloomed ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (plot.isBloomed) ...[
                              Text(
                                _flowerIcons[plot.plantType],
                                style: const TextStyle(fontSize: 34),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: Colors.pink, shape: BoxShape.circle),
                                  child: const Icon(Icons.check, size: 10, color: Colors.white),
                                ),
                              ),
                            ] else ...[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    plot.moisture < 0.25
                                        ? Icons.grain_rounded
                                        : (plot.moisture < 0.7 ? Icons.eco_rounded : Icons.spa_rounded),
                                    size: 26,
                                    color: plot.moisture < 0.25 ? Colors.brown.shade400 : Colors.green.shade800,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(plot.moisture * 100).toInt()}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: plot.moisture < 0.25 ? Colors.brown.shade800 : Colors.green.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                                  child: LinearProgressIndicator(
                                    value: plot.moisture,
                                    minHeight: 5,
                                    backgroundColor: Colors.transparent,
                                    color: Colors.blue.shade400,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
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
                    const Text('🌿 NURSERY ROUND COMPLETE!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2E7D32))),
                    const SizedBox(height: 6),
                    Text('You bloomed $_bloomsCount township plants with clean recycled water!', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ResultPill(label: 'Score', value: '$_score', color: Colors.green),
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
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
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

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value, required this.color, required this.icon});
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
            const SizedBox(width: 3),
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
