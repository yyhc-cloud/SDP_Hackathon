import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/township_state.dart';
import '../theme/app_colors.dart';

/// General township reporting screen for all residential and community issues.
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedCategory = 'Waste & Smart Bins';
  String _selectedIssue = 'Overflowing Smart Bin';
  String _priority = 'Normal';
  bool _hasPhoto = false;

  final TextEditingController _locationController = TextEditingController(text: 'Jalan Makmur 3/14, Precinct 3');
  final TextEditingController _descriptionController = TextEditingController();

  static const Map<String, List<String>> _categoryIssues = {
    'Waste & Smart Bins': [
      'Overflowing Smart Bin',
      'Illegal Trash Dumping / Fly Tipping',
      'Smart Bin Chute Faulty or Jammed',
      'Missed Household Waste Collection',
      'Bulk Waste / Garden Debris Awaiting Pickup',
      'E-Waste Chute Full',
    ],
    'Township Infrastructure': [
      'Pothole or Cracked Asphalt on Road',
      'Broken Curb or Damaged Walkway',
      'Streetlight / Solar Lamp Outage',
      'Clogged Stormwater Drain / Flash Flood Risk',
      'Damaged Road Sign or Traffic Convex Mirror',
      'Burst Water Pipe / Water Leak',
    ],
    'Parks & Biodiversity': [
      'Fallen Tree Branch / Overgrown Foliage',
      'Damaged Park Bench or Playground Equipment',
      'Wetland Lake Murkiness / Floating Debris',
      'Smart Irrigation Leak or Sprinkler Fault',
      'Bicycle Trail Obstruction',
    ],
    'Community Safety': [
      'Stray Animal Alert',
      'Damaged Residential Boom Gate or RFID Sensor',
      'Noise or Neighborhood Nuisance Complaint',
      'Suspicious Activity / Security Patrol Request',
      'Illegal Parking Blocking Residential Gate',
    ],
    'General Feedback': [
      'Township Community Garden Proposal',
      'Recycling Smart Bin Placement Request',
      'Township Management Commendation & Compliment',
      'General Community Inquiry',
    ],
  };

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final ticketNum = 'SDP-${DateTime.now().year}-${1000 + math.Random().nextInt(9000)}';
    
    // Reward civic points
    TownshipState.instance.addPoints(20, 'Report in General: $ticketNum ($_selectedIssue)');

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Report Submitted'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reference ID: $ticketNum', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1B5E20))),
            const SizedBox(height: 8),
            Text('Category: $_selectedCategory\nIssue: $_selectedIssue\nPriority: $_priority'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.stars_rounded, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '+20 Green Points awarded for helping keep our township safe & clean!',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1B5E20)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
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
    final issuesForCategory = _categoryIssues[_selectedCategory] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        title: const Text('Report in General'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Informative banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.campaign_rounded, color: Color(0xFF1B5E20), size: 26),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Submit general maintenance alerts, civic feedback, or facility requests directly to Sime Darby Property management.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF1B5E20), fontWeight: FontWeight.w600, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Category Selector Chips
          const Text('Category', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categoryIssues.keys.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color(0xFF1B5E20),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    checkmarkColor: Colors.white,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedCategory = cat;
                          _selectedIssue = _categoryIssues[cat]!.first;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // Issue Selector Radio List
          Text('Select Issue ($_selectedCategory)', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 8),
          RadioGroup<String>(
            groupValue: _selectedIssue,
            onChanged: (v) => setState(() => _selectedIssue = v ?? _selectedIssue),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    for (final issue in issuesForCategory)
                      RadioListTile<String>(
                        value: issue,
                        title: Text(issue, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        activeColor: const Color(0xFF1B5E20),
                        dense: true,
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Priority Level
          const Text('Priority Level', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: ['Normal', 'Urgent', 'Safety Hazard'].map((p) {
              final isSelected = _priority == p;
              Color chipColor = Colors.green;
              if (p == 'Urgent') chipColor = Colors.orange;
              if (p == 'Safety Hazard') chipColor = Colors.red;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(p),
                  selected: isSelected,
                  selectedColor: chipColor.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? chipColor : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  side: BorderSide(color: isSelected ? chipColor : Colors.grey.shade300, width: isSelected ? 2 : 1),
                  onSelected: (val) {
                    if (val) setState(() => _priority = p);
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Photo Attachment
          const Text('Photo Evidence', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              setState(() {
                _hasPhoto = !_hasPhoto;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: _hasPhoto ? Colors.green.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _hasPhoto ? Colors.green : Colors.grey.shade300,
                  style: _hasPhoto ? BorderStyle.solid : BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _hasPhoto ? Icons.check_circle_rounded : Icons.add_a_photo_rounded,
                      color: _hasPhoto ? Colors.green : const Color(0xFF1B5E20),
                      size: 32,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _hasPhoto ? 'Photo Attached (Tap to remove)' : 'Tap to attach photo or take snapshot',
                      style: TextStyle(
                        color: _hasPhoto ? Colors.green.shade800 : AppColors.dark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Location
          const Text('Location', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.place_rounded, color: Color(0xFF1B5E20)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.my_location_rounded, color: Color(0xFF1B5E20)),
                tooltip: 'Use GPS',
                onPressed: () {
                  setState(() {
                    _locationController.text = 'Jalan Makmur 3/14 (Verified GPS)';
                  });
                },
              ),
              hintText: 'Enter street name or landmark',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
          const SizedBox(height: 18),

          // Detailed Description
          const Text('Description (Optional)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Provide additional details or landmarks to assist the maintenance team...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.send_rounded, size: 20),
              label: const Text('Submit General Report', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}
