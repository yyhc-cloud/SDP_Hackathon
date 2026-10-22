import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/township_state.dart';
import '../models/landed_models.dart';
import '../models/pokemon_model.dart';
import '../theme/app_colors.dart';
import '../widgets/cube_pet_image.dart';

class ShowQrScreen extends StatefulWidget {
  const ShowQrScreen({super.key});

  @override
  State<ShowQrScreen> createState() => _ShowQrScreenState();
}

class _ShowQrScreenState extends State<ShowQrScreen> {
  int _secondsRemaining = 30;
  Timer? _countdownTimer;
  late bool _isWalkedSelfDrop;
  int _tokenSuffix = 8842;

  // Recyclables options for deposit
  static const List<_WasteOption> _wasteOptions = [
    _WasteOption(
      name: 'Clean PET Plastic Bottle',
      ecoType: EcoMaterialType.water,
      points: 15,
      weightKg: 0.25,
      petAsset: 'assets/kenny_cube/Previews/animal-fish.png',
      chuteName: 'Blue Chute (Plastics)',
    ),
    _WasteOption(
      name: 'Aluminium Drink Can',
      ecoType: EcoMaterialType.steel,
      points: 20,
      weightKg: 0.20,
      petAsset: 'assets/kenny_cube/Previews/animal-elephant.png',
      chuteName: 'Orange Chute (Metals)',
    ),
    _WasteOption(
      name: 'Fruit Peel & Food Waste',
      ecoType: EcoMaterialType.grass,
      points: 15,
      weightKg: 0.45,
      petAsset: 'assets/kenny_cube/Previews/animal-bunny.png',
      chuteName: 'Brown Chute (Bio-Organics)',
    ),
    _WasteOption(
      name: 'Household AA Battery / E-Waste',
      ecoType: EcoMaterialType.electric,
      points: 30,
      weightKg: 0.30,
      petAsset: 'assets/kenny_cube/Previews/animal-bee.png',
      chuteName: 'Red Chute (Hazardous E-Waste)',
    ),
  ];

  late _WasteOption _selectedWaste;

  @override
  void initState() {
    super.initState();
    _isWalkedSelfDrop = TownshipState.instance.isWalkingMultiplierActive;
    _selectedWaste = _wasteOptions.first;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining <= 1) {
          _secondsRemaining = 30;
          _tokenSuffix = 1000 + math.Random().nextInt(9000);
        } else {
          _secondsRemaining--;
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _simulateDeposit() {
    final state = TownshipState.instance;
    state.processWasteRecycled(
      wasteName: _selectedWaste.name,
      materialType: _selectedWaste.ecoType,
      points: _selectedWaste.points,
      weightKg: _selectedWaste.weightKg,
      binName: 'Smart Bin #01 (Central Park)',
      isWalkedSelfDrop: _isWalkedSelfDrop,
    );

    final pointsEarned = _isWalkedSelfDrop ? (_selectedWaste.points * 2) : _selectedWaste.points;

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text('Deposit Verified!', overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_selectedWaste.name} accepted at ${_selectedWaste.chuteName}.',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selectedWaste.ecoType.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CubePetImage(imagePath: _selectedWaste.petAsset, width: 40, height: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isWalkedSelfDrop ? '+$pointsEarned Green Points (2x Mobility!)' : '+$pointsEarned Green Points',
                          style: TextStyle(fontWeight: FontWeight.w900, color: _selectedWaste.ecoType.color, fontSize: 13),
                        ),
                        Text(
                          _isWalkedSelfDrop ? '+6 ${_selectedWaste.ecoType.label} Berries & +350m Egg Hatch' : '+3 Berries',
                          style: const TextStyle(fontSize: 11, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Pollution Sludge-Hog Boss damaged by drop weight! Guild War Power added to Makmur Eco-Guardians.',
              style: TextStyle(fontSize: 11, color: AppColors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F9),
      appBar: AppBar(
        title: const Text('Resident Eco-QR'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          // Mobility Mode Selection (Walked 2x vs Buggy Pickup)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _isWalkedSelfDrop ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isWalkedSelfDrop ? const Color(0xFF81C784) : const Color(0xFFFFB74D),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isWalkedSelfDrop ? Icons.directions_walk_rounded : Icons.local_shipping_rounded,
                  color: _isWalkedSelfDrop ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                  size: 26,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isWalkedSelfDrop ? '2x Active Mobility Multiplier Active' : 'Collector Buggy Mode (Standard 1x)',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: _isWalkedSelfDrop ? const Color(0xFF1B5E20) : const Color(0xFFBF360C),
                        ),
                      ),
                      Text(
                        _isWalkedSelfDrop ? 'Verified walking to smart bin • Double Points & Berries' : 'Doorstep gate pickup requested',
                        style: TextStyle(
                          fontSize: 10,
                          color: _isWalkedSelfDrop ? Colors.green.shade800 : Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isWalkedSelfDrop,
                  activeThumbColor: const Color(0xFF1B5E20),
                  onChanged: (val) {
                    setState(() {
                      _isWalkedSelfDrop = val;
                      TownshipState.instance.setDisposalChoice(
                        val ? DisposalChoice.selfDropWalk : DisposalChoice.collectorBuggy,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main QR Code Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                // Header inside Card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sime Darby Property', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1B5E20))),
                        Text('Township Resident Eco-Pass', style: TextStyle(fontSize: 11, color: AppColors.grey)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.sync_rounded, size: 12, color: Colors.green),
                          const SizedBox(width: 4),
                          Text('${_secondsRemaining}s', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.green)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stylized High-Contrast QR Code Display
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12, width: 2),
                        ),
                        child: CustomPaint(
                          painter: _QrMatrixPainter(),
                        ),
                      ),
                      // Central Badge
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                          border: Border.all(color: const Color(0xFF1B5E20), width: 2),
                        ),
                        child: const CubePetImage(
                          imagePath: 'assets/kenny_cube/Previews/animal-bunny.png',
                          width: 38,
                          height: 38,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Token & Member Info
                Text(
                  'TOKEN: SDP-BBR-$_tokenSuffix • ENCRYPTED',
                  style: const TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.w800, fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Resident', style: TextStyle(fontSize: 10, color: AppColors.grey)),
                        Text('Aisyah Binti Zulkifli', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        Text('No. 14, Jalan Makmur 3/14', style: TextStyle(fontSize: 11, color: AppColors.grey)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Alliance', style: TextStyle(fontSize: 10, color: AppColors.grey)),
                        const Text('Makmur Guardians', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0D47A1))),
                        Text('${TownshipState.instance.greenPoints} Green Pts', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Instructions Card (follows the Walked / Collector Buggy switch above)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: _isWalkedSelfDrop
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How to Use at Smart Bins', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      SizedBox(height: 6),
                      Text('1. Hold this QR code 10cm from the Smart Bin optical lens.', style: TextStyle(fontSize: 11, color: Colors.black87)),
                      SizedBox(height: 3),
                      Text('2. Smart Bin recognizes your household and unlocks the designated chute.', style: TextStyle(fontSize: 11, color: Colors.black87)),
                      SizedBox(height: 3),
                      Text('3. Drop your waste. Scale verifies weight and credits 2x points instantly!', style: TextStyle(fontSize: 11, color: Colors.black87)),
                    ],
                  )
                : const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How to Use for Collector Buggy', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      SizedBox(height: 6),
                      Text('1. Summon the buggy from the Pickup page, then leave your sorted, bagged recyclables at your gate.', style: TextStyle(fontSize: 11, color: Colors.black87)),
                      SizedBox(height: 3),
                      Text('2. When the buggy arrives, show this QR code to the Collector Buggy operator.', style: TextStyle(fontSize: 11, color: Colors.black87)),
                      SizedBox(height: 3),
                      Text('3. The operator scans your QR and the AI Scanner checks that your bag is sorted correctly.', style: TextStyle(fontSize: 11, color: Colors.black87)),
                      SizedBox(height: 3),
                      Text('4. Your bag is weighed on the buggy scale and points are credited to you at the standard 1x rate.', style: TextStyle(fontSize: 11, color: Colors.black87)),
                      SizedBox(height: 6),
                      Text('Tip: walk to a Smart Bin instead to earn 2x points!', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFE65100))),
                    ],
                  ),
          ),
          const SizedBox(height: 16),

          // Demo / Quick Deposit Simulator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF81C784)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.touch_app_rounded, color: Color(0xFF1B5E20), size: 18),
                    SizedBox(width: 8),
                    Text('Select Recyclable to Deposit', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _wasteOptions.map((opt) {
                      final isSel = _selectedWaste.name == opt.name;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: CubePetImage(imagePath: opt.petAsset, width: 20, height: 20),
                          label: Text(opt.name.split(' ').take(2).join(' ')),
                          selected: isSel,
                          selectedColor: opt.ecoType.color.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                            color: isSel ? opt.ecoType.color : Colors.black87,
                            fontSize: 11,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedWaste = opt);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                    label: const Text('Scan & Deposit at Smart Bin', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    onPressed: _simulateDeposit,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WasteOption {
  const _WasteOption({
    required this.name,
    required this.ecoType,
    required this.points,
    required this.weightKg,
    required this.petAsset,
    required this.chuteName,
  });

  final String name;
  final EcoMaterialType ecoType;
  final int points;
  final double weightKg;
  final String petAsset;
  final String chuteName;
}

class _QrMatrixPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A237E)
      ..style = PaintingStyle.fill;

    const int matrixSize = 21;
    final cellW = size.width / matrixSize;
    final cellH = size.height / matrixSize;

    // Fixed QR finder patterns (top-left, top-right, bottom-left)
    void drawFinder(int startX, int startY) {
      for (int x = 0; x < 7; x++) {
        for (int y = 0; y < 7; y++) {
          final isBorder = (x == 0 || x == 6 || y == 0 || y == 6);
          final isCenter = (x >= 2 && x <= 4 && y >= 2 && y <= 4);
          if (isBorder || isCenter) {
            canvas.drawRect(
              Rect.fromLTWH((startX + x) * cellW, (startY + y) * cellH, cellW, cellH),
              paint,
            );
          }
        }
      }
    }

    drawFinder(0, 0);
    drawFinder(matrixSize - 7, 0);
    drawFinder(0, matrixSize - 7);

    // Pseudorandom internal pattern avoiding finder areas and center avatar
    final rand = math.Random(1337);
    for (int x = 0; x < matrixSize; x++) {
      for (int y = 0; y < matrixSize; y++) {
        // Skip finders
        final inTopLeft = (x < 8 && y < 8);
        final inTopRight = (x >= matrixSize - 8 && y < 8);
        final inBottomLeft = (x < 8 && y >= matrixSize - 8);
        final inCenter = (x >= 7 && x <= 13 && y >= 7 && y <= 13);

        if (!inTopLeft && !inTopRight && !inBottomLeft && !inCenter) {
          if (rand.nextBool()) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(x * cellW + 0.5, y * cellH + 0.5, cellW - 1, cellH - 1),
                const Radius.circular(1.5),
              ),
              paint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
