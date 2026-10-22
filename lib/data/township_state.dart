import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/landed_models.dart';
import '../models/pokemon_model.dart';
import '../services/poke_api_service.dart';
import 'mock_data.dart';

class TownshipState extends ChangeNotifier {
  TownshipState._();
  static final TownshipState instance = TownshipState._();

  // User Profile
  UserProfile _user = MockData.user;
  UserProfile get user => _user;

  void addPoints(int points, String description) {
    _user = _user.copyWith(points: _user.points + points);
    _activity.insert(0, PointsActivity(description, 'Just now', points));
    notifyListeners();
  }

  // Real-World Sime Darby Property Townships (matching SDP portfolio)
  final List<TownshipSite> _townships = const [
    TownshipSite(
      id: 'bbr',
      name: 'Bandar Bukit Raja',
      tagline: 'Largest Township in Klang Valley • 4,333 Acres',
      state: 'Klang, Selangor',
      activeSmartBins: 12,
      activeBuggies: 4,
      prominentFeature: '125-Acre Central Park & Wetland Sanctuary',
    ),
    TownshipSite(
      id: 'elmina',
      name: 'City of Elmina',
      tagline: 'Wellness & Active Living Township • 5,000 Acres',
      state: 'Shah Alam, Selangor',
      activeSmartBins: 16,
      activeBuggies: 6,
      prominentFeature: '300-Acre Central Park & Iconic Rainbow Bridge',
    ),
    TownshipSite(
      id: 'ara',
      name: 'Ara Damansara',
      tagline: 'Transit-Oriented Mature Township • 734 Acres',
      state: 'Petaling Jaya, Selangor',
      activeSmartBins: 8,
      activeBuggies: 2,
      prominentFeature: 'Oasis Square & LRT Eco-Corridor',
    ),
    TownshipSite(
      id: 'jelutong',
      name: 'Bukit Jelutong',
      tagline: 'Prestigious Eco-Haven • 2,205 Acres',
      state: 'Shah Alam, Selangor',
      activeSmartBins: 10,
      activeBuggies: 3,
      prominentFeature: 'Bukit Jelutong Eco Community Farm',
    ),
    TownshipSite(
      id: 'sjcc',
      name: 'Subang Jaya City Centre (SJCC)',
      tagline: 'Urban Renewal Hub • Connected Living',
      state: 'Subang Jaya, Selangor',
      activeSmartBins: 7,
      activeBuggies: 2,
      prominentFeature: 'Subang Parade & Solar Rail Links',
    ),
    TownshipSite(
      id: 'putra',
      name: 'Putra Heights',
      tagline: 'Hillside Sanctuary & River Park • 1,796 Acres',
      state: 'Subang Jaya, Selangor',
      activeSmartBins: 9,
      activeBuggies: 3,
      prominentFeature: 'Bukit Cermin Forest Trail & Linear Lake',
    ),
  ];
  List<TownshipSite> get townships => List.unmodifiable(_townships);

  late TownshipSite _selectedTownship = _townships.first;
  TownshipSite get selectedTownship => _selectedTownship;

  void selectTownship(TownshipSite site) {
    _selectedTownship = site;
    notifyListeners();
  }

  // Active Mobility & Landed Disposal Choice
  DisposalChoice _disposalChoice = DisposalChoice.selfDropWalk;
  DisposalChoice get disposalChoice => _disposalChoice;
  bool get isWalkingMultiplierActive => _disposalChoice == DisposalChoice.selfDropWalk;

  void setDisposalChoice(DisposalChoice choice) {
    _disposalChoice = choice;
    notifyListeners();
  }

  // Live Collector Buggy Fleet (Grab-Style Tracking)
  final CollectorBuggy _buggy = CollectorBuggy(
    id: 'buggy_02',
    name: 'Eco-Cruiser #02',
    driverName: 'Pak Amin',
    plateNumber: 'BBR-BUGGY-02',
    currentStreet: 'Jalan Makmur 3/4',
    etaMinutes: 4,
    xRatio: 0.36,
    yRatio: 0.54,
    status: 'Cruising Precinct 3 Streets',
    batteryPercent: 92,
  );
  CollectorBuggy get buggy => _buggy;

  bool _isBuggySummoned = false;
  bool get isBuggySummoned => _isBuggySummoned;

  void summonBuggyToGate() {
    _isBuggySummoned = true;
    _disposalChoice = DisposalChoice.collectorBuggy;
    _buggy.status = 'En Route to Jalan Makmur 3/14 (Your Gate)';
    _buggy.etaMinutes = 4;
    notifyListeners();
  }

  void cancelBuggySummon() {
    _isBuggySummoned = false;
    _buggy.status = 'Cruising Precinct 3 Streets';
    notifyListeners();
  }

  // Territorial Street Rivalries (Splatoon / Pokémon Gym Style)
  final List<StreetTerritory> _streetRivalries = [
    const StreetTerritory(
      id: 'st_makmur',
      streetName: 'Jalan Makmur (Precinct 3)',
      precinct: 'Precinct 3 Landed',
      color: Color(0xFF1E88E5), // Blue dominant territory
      weeklyKg: 184.5,
      householdCount: 48,
      rank: 1,
      isLeader: true,
      topMaterial: 'Plastics & Metals',
      isUserStreet: true,
    ),
    const StreetTerritory(
      id: 'st_harmoni',
      streetName: 'Jalan Harmoni (Precinct 1)',
      precinct: 'Precinct 1 Landed',
      color: Color(0xFF43A047), // Green territory
      weeklyKg: 168.0,
      householdCount: 42,
      rank: 2,
      isLeader: false,
      topMaterial: 'Cardboard & Paper',
    ),
    const StreetTerritory(
      id: 'st_sejahtera',
      streetName: 'Jalan Sejahtera (Precinct 2)',
      precinct: 'Precinct 2 Landed',
      color: Color(0xFFFFA000), // Amber territory
      weeklyKg: 142.2,
      householdCount: 39,
      rank: 3,
      isLeader: false,
      topMaterial: 'Organic Food Waste',
    ),
    const StreetTerritory(
      id: 'st_aman',
      streetName: 'Jalan Aman (Precinct 4)',
      precinct: 'Precinct 4 Landed',
      color: Color(0xFF8E24AA), // Purple territory
      weeklyKg: 119.5,
      householdCount: 35,
      rank: 4,
      isLeader: false,
      topMaterial: 'Glass & Metals',
    ),
  ];
  List<StreetTerritory> get streetRivalries => List.unmodifiable(_streetRivalries);

  // Designated Township Green Park Trails
  final List<ParkTrail> _parkTrails = const [
    ParkTrail(
      id: 'trail_central',
      name: 'Central Park Biodiversity Loop',
      distanceKm: 3.2,
      stepsVerified: 3420,
      isGeofenced: true,
      tag: 'Township Green Space',
    ),
    ParkTrail(
      id: 'trail_wetlands',
      name: 'Lake Promenade Wetlands Trail',
      distanceKm: 1.8,
      stepsVerified: 2150,
      isGeofenced: true,
      tag: 'Wetlands Habitat',
    ),
  ];
  List<ParkTrail> get parkTrails => _parkTrails;

  // Circular Economy & Eco Currency
  int get greenPoints => _user.points;
  int _grassBerries = 14;
  int _waterBerries = 8;
  int _steelBerries = 9;
  int get grassBerries => _grassBerries;
  int get waterBerries => _waterBerries;
  int get steelBerries => _steelBerries;

  // Mobility / Step Walking
  double _todayWalkedKm = 1.35;
  double get todayWalkedKm => _todayWalkedKm;

  // Active Companion
  late PokemonData _activeCompanion = PokeApiService.instance.getCatalogPokemon('bunny');
  PokemonData get activeCompanion => _activeCompanion;

  // Unlocked & Full Biodiversity Pet Sanctuary
  final List<PokemonData> _unlockedPokemon = [
    PokeApiService.instance.getCatalogPokemon('bunny'),
    PokeApiService.instance.getCatalogPokemon('fish'),
    PokeApiService.instance.getCatalogPokemon('elephant'),
    PokeApiService.instance.getCatalogPokemon('fox', isShiny: true).copyWith(isLocked: false),
  ];
  List<PokemonData> get unlockedPokemon => List.unmodifiable(_unlockedPokemon);

  // Incubating Pet Eggs
  final List<PokemonEgg> _eggs = [
    PokemonEgg(
      id: 'egg_1',
      name: 'Grass & Compost Eco-Egg',
      eggType: EcoMaterialType.grass,
      targetKm: 2.0,
      walkedKm: 1.35,
      pokemonId: 43, // Sprout Chick
      pokemonName: 'Sprout Chick',
    ),
    PokemonEgg(
      id: 'egg_2',
      name: '✨ Golden Mystery Egg (Shiny Chance!)',
      eggType: EcoMaterialType.steel,
      targetKm: 3.0,
      walkedKm: 1.1,
      pokemonId: 81, // Cyber Bee
      pokemonName: 'Cyber Bee',
      isGoldenMystery: true,
    ),
  ];
  List<PokemonEgg> get eggs => List.unmodifiable(_eggs);

  // Community Boss Raid
  final CommunityBoss _boss = CommunityBoss(
    id: 'boss_grimer',
    name: 'Toxic Sludge-Hog (Waste Overlord)',
    pokemonId: 88,
    title: 'Pollution Sludge Boar Threatening Central Park Wetlands',
    locationName: 'Bandar Bukit Raja Central Park',
    currentKg: 348.5,
    targetKg: 500.0,
    daysRemaining: 3,
    rewardPokemonName: 'Forest Guardian Dog',
    rewardPokemonId: 251,
    participantsCount: 84,
    bossMaxHp: 1000,
    bossCurrentHp: 310,
    bossAsset: 'assets/kenny_cube/Previews/animal-hog.png',
  );
  CommunityBoss get boss => _boss;

  // Raid boss respawn cooldown after a defeat (shared by the raid arena and the home banner)
  static const Duration bossRespawnCooldown = Duration(minutes: 1);
  DateTime? _bossRespawnAt;
  Timer? _bossRespawnTimer;

  bool get isBossOnCooldown => _bossRespawnAt != null;

  /// Time left until the boss respawns, or [Duration.zero] when it is not on cooldown.
  Duration get bossRespawnRemaining {
    final at = _bossRespawnAt;
    if (at == null) return Duration.zero;
    final left = at.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  void _onBossDefeated() {
    unlockGuardianDog();
    if (_bossRespawnAt != null) return;
    _bossRespawnAt = DateTime.now().add(bossRespawnCooldown);
    _bossRespawnTimer?.cancel();
    _bossRespawnTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (bossRespawnRemaining == Duration.zero) _respawnBoss();
      notifyListeners();
    });
  }

  void _respawnBoss() {
    _bossRespawnTimer?.cancel();
    _bossRespawnTimer = null;
    _bossRespawnAt = null;
    _boss.bossCurrentHp = _boss.bossMaxHp;
    _boss.currentKg = 0;
  }

  // Guild Wars: Neighbourhood vs Neighbourhood Rivalries
  final List<NeighbourhoodGuild> _neighbourhoodGuilds = [
    const NeighbourhoodGuild(
      id: 'guild_makmur',
      name: 'Makmur Eco-Guardians',
      neighbourhood: 'Jalan Makmur (Precinct 3)',
      township: 'Bandar Bukit Raja',
      badgeColor: Color(0xFF1E88E5), // Blue
      memberCount: 52,
      weeklyWarPoints: 12450,
      rank: 1,
      isUserGuild: true,
      motto: 'Zero Landfill, 100% Circular Pride',
    ),
    const NeighbourhoodGuild(
      id: 'guild_elmina',
      name: 'Elmina Valley Protectors',
      neighbourhood: 'Elmina Valley Phase 2',
      township: 'City of Elmina',
      badgeColor: Color(0xFF43A047), // Green
      memberCount: 47,
      weeklyWarPoints: 11800,
      rank: 2,
      isUserGuild: false,
      motto: 'Lakeside Purity & Forest Harmony',
    ),
    const NeighbourhoodGuild(
      id: 'guild_ara',
      name: 'Ara Greens Bio-Squad',
      neighbourhood: 'Ara Damansara Greens',
      township: 'Ara Damansara',
      badgeColor: Color(0xFFFB8C00), // Orange
      memberCount: 38,
      weeklyWarPoints: 9620,
      rank: 3,
      isUserGuild: false,
      motto: 'Transit-Smart & Low Carbon',
    ),
    const NeighbourhoodGuild(
      id: 'guild_jelutong',
      name: 'Jelutong Bio-Knights',
      neighbourhood: 'Bukit Jelutong Eco-Villas',
      township: 'Bukit Jelutong',
      badgeColor: Color(0xFF8E24AA), // Purple
      memberCount: 34,
      weeklyWarPoints: 8900,
      rank: 4,
      isUserGuild: false,
      motto: 'Clean Canopy, Community First',
    ),
    const NeighbourhoodGuild(
      id: 'guild_putra',
      name: 'Putra Hillside Vanguard',
      neighbourhood: 'Putra Crest & Sanctuary',
      township: 'Putra Heights',
      badgeColor: Color(0xFF00ACC1), // Cyan
      memberCount: 29,
      weeklyWarPoints: 7350,
      rank: 5,
      isUserGuild: false,
      motto: 'Hilltop Freshness, Endless Recycling',
    ),
  ];
  List<NeighbourhoodGuild> get neighbourhoodGuilds => List.unmodifiable(_neighbourhoodGuilds);

  // Active Battlefronts in Neighbourhood Guild Wars
  final List<GuildBattlefront> _battlefronts = [
    GuildBattlefront(
      id: 'bf_wetlands',
      name: 'Central Wetlands Sanctuary',
      location: 'Bandar Bukit Raja Wetlands',
      controllingGuild: 'Makmur Eco-Guardians',
      challengerGuild: 'Elmina Valley Protectors',
      ourControlPercent: 0.62,
      totalWarPower: 18500,
      bonusPerk: '+15% Circular Shop Discount for Controlling Neighbourhood',
      frontlineIcon: Icons.water_drop_rounded,
    ),
    GuildBattlefront(
      id: 'bf_solar',
      name: 'Solar Plaza Microgrid',
      location: 'Commercial Town Centre',
      controllingGuild: 'Elmina Valley Protectors',
      challengerGuild: 'Makmur Eco-Guardians',
      ourControlPercent: 0.48,
      totalWarPower: 14200,
      bonusPerk: '2x Green Energy EV Charging speed for the week',
      frontlineIcon: Icons.solar_power_rounded,
    ),
    GuildBattlefront(
      id: 'bf_compost',
      name: 'Community Bio-Compost Hub',
      location: 'Precinct 2 Urban Farm',
      controllingGuild: 'Makmur Eco-Guardians',
      challengerGuild: 'Ara Greens Bio-Squad',
      ourControlPercent: 0.74,
      totalWarPower: 11800,
      bonusPerk: 'Free 10kg Bio-Compost Delivery to all residents',
      frontlineIcon: Icons.compost_rounded,
    ),
  ];
  List<GuildBattlefront> get battlefronts => List.unmodifiable(_battlefronts);

  // Guild War Live Activity Feed
  final List<GuildWarActivity> _guildWarActivities = [
    const GuildWarActivity(
      residentName: 'You',
      action: 'Completed Eco-Crush Match-3 Challenge',
      pointsAdded: 150,
      battlefrontName: 'Central Wetlands Sanctuary',
      timeAgo: 'Just now',
    ),
    const GuildWarActivity(
      residentName: 'Ahmad Faiz',
      action: 'Recycled 4.2 kg aluminium cans at Smart Bin #01',
      pointsAdded: 210,
      battlefrontName: 'Solar Plaza Microgrid',
      timeAgo: '12m ago',
    ),
    const GuildWarActivity(
      residentName: 'Siti Nurhaliza',
      action: 'WaterPlant Nursery Bloom Streak (x6)',
      pointsAdded: 180,
      battlefrontName: 'Central Wetlands Sanctuary',
      timeAgo: '28m ago',
    ),
    const GuildWarActivity(
      residentName: 'Jason Lee',
      action: 'Eco-Bale Tetris 4-Line Clear',
      pointsAdded: 240,
      battlefrontName: 'Community Bio-Compost Hub',
      timeAgo: '1h ago',
    ),
  ];
  List<GuildWarActivity> get guildWarActivities => List.unmodifiable(_guildWarActivities);

  // GameHub High Scores & Stats
  int _waterPlantHighScore = 480;
  int get waterPlantHighScore => _waterPlantHighScore;

  int _candyCrushHighScore = 950;
  int get candyCrushHighScore => _candyCrushHighScore;

  int _tetrisHighScore = 1420;
  int get tetrisHighScore => _tetrisHighScore;

  int _totalGamePointsToday = 620;
  int get totalGamePointsToday => _totalGamePointsToday;

  void contributeToBattlefront(String battlefrontId, int warPoints) {
    final idx = _battlefronts.indexWhere((b) => b.id == battlefrontId);
    if (idx != -1) {
      final bf = _battlefronts[idx];
      bf.totalWarPower += warPoints;
      bf.ourControlPercent = (bf.ourControlPercent + (warPoints / 2000.0)).clamp(0.05, 0.98);
      if (bf.ourControlPercent >= 0.50) {
        bf.controllingGuild = 'Makmur Eco-Guardians';
      }
    }

    _guildWarActivities.insert(
      0,
      GuildWarActivity(
        residentName: 'You',
        action: 'Reinforced front with $warPoints War Power',
        pointsAdded: warPoints,
        battlefrontName: idx != -1 ? _battlefronts[idx].name : 'Frontline',
        timeAgo: 'Just now',
      ),
    );

    _user = _user.copyWith(points: _user.points + (warPoints ~/ 5));
    notifyListeners();
  }

  void recordGameScore(String gameId, int score) {
    bool isNewHighScore = false;
    int pointsEarned = (score ~/ 10).clamp(10, 150);
    int warPower = (score ~/ 5).clamp(20, 300);

    if (gameId == 'waterplant') {
      if (score > _waterPlantHighScore) {
        _waterPlantHighScore = score;
        isNewHighScore = true;
      }
    } else if (gameId == 'candycrush') {
      if (score > _candyCrushHighScore) {
        _candyCrushHighScore = score;
        isNewHighScore = true;
      }
    } else if (gameId == 'tetris') {
      if (score > _tetrisHighScore) {
        _tetrisHighScore = score;
        isNewHighScore = true;
      }
    }

    _totalGamePointsToday += pointsEarned;
    _user = _user.copyWith(points: _user.points + pointsEarned);

    if (_battlefronts.isNotEmpty) {
      final targetBf = _battlefronts.first;
      targetBf.totalWarPower += warPower;
      targetBf.ourControlPercent = (targetBf.ourControlPercent + 0.015).clamp(0.1, 0.98);
    }

    _activity.insert(
      0,
      PointsActivity(
        'GameHub $gameId: Scored $score (${isNewHighScore ? 'New Record! ' : ''}+$warPower Guild War Power)',
        'Just now',
        pointsEarned,
      ),
    );

    _guildWarActivities.insert(
      0,
      GuildWarActivity(
        residentName: 'You',
        action: 'Played $gameId (Score: $score)',
        pointsAdded: warPower,
        battlefrontName: _battlefronts.first.name,
        timeAgo: 'Just now',
      ),
    );

    notifyListeners();
  }

  // Smart Bins across the Township (Including Golden Mystery Bin!)
  final List<SmartBinLocation> _bins = [
    const SmartBinLocation(
      id: 'bin_gold',
      name: '✨ Golden Smart Bin (Mystery Drop)',
      precinct: 'Central Park Solar Plaza',
      fillPercentage: 12,
      acceptedMaterials: ['All Recyclables', 'E-Waste', 'Organics'],
      distanceMeters: 80,
      xRatio: 0.46,
      yRatio: 0.32,
      isGoldenMysteryBin: true,
    ),
    const SmartBinLocation(
      id: 'bin_1',
      name: 'Smart Bin #01 — Central Park',
      precinct: 'Bandar Bukit Raja Central Park',
      fillPercentage: 32,
      acceptedMaterials: ['Plastics', 'Metals', 'Paper', 'Glass'],
      distanceMeters: 140,
      xRatio: 0.52,
      yRatio: 0.38,
    ),
    const SmartBinLocation(
      id: 'bin_2',
      name: 'Smart Bin #02 — Lake Promenade',
      precinct: 'Precinct 3 Wetlands',
      fillPercentage: 68,
      acceptedMaterials: ['Glass', 'Plastics', 'Organic Food Waste'],
      distanceMeters: 310,
      xRatio: 0.06,
      yRatio: 0.68,
    ),
    const SmartBinLocation(
      id: 'bin_3',
      name: 'Smart Bin #03 — Commercial Plaza',
      precinct: 'Town Centre Eco Hub',
      fillPercentage: 94, // RED ALERT (>90%)
      acceptedMaterials: ['Plastics', 'Metals', 'Paper', 'E-Waste'],
      distanceMeters: 620,
      xRatio: 0.76,
      yRatio: 0.22,
    ),
    const SmartBinLocation(
      id: 'bin_4',
      name: 'Smart Bin #04 — Sports Clubhouse',
      precinct: 'Precinct 2 Clubhouse',
      fillPercentage: 45,
      acceptedMaterials: ['Organic Food Waste', 'Plastics', 'Metals'],
      distanceMeters: 450,
      xRatio: 0.82,
      yRatio: 0.70,
    ),
    const SmartBinLocation(
      id: 'bin_5',
      name: 'Smart Bin #05 — Community Orchard',
      precinct: 'Precinct 1 Green Gate',
      fillPercentage: 18,
      acceptedMaterials: ['Organic Compost', 'Cardboard', 'Plastics'],
      distanceMeters: 780,
      xRatio: 0.18,
      yRatio: 0.25,
    ),
  ];
  List<SmartBinLocation> get bins => List.unmodifiable(_bins);

  // Social Eco-Gifting
  final List<EcoGift> _receivedGifts = [
    const EcoGift(
      id: 'g1',
      senderName: 'Daniel Tan',
      street: 'Jalan Makmur 3/8',
      itemType: 'Steel Berry',
      message: 'Thanks for lending the pruning shears! Here is a Steel Berry for your Steel Elephant.',
      timestamp: 'Today, 2:15 PM',
    ),
    const EcoGift(
      id: 'g2',
      senderName: 'Nur Aina',
      street: 'Jalan Makmur 3/12',
      itemType: 'Grass Berry',
      message: 'Keep Jalan Makmur in #1 place! Let’s win the street BBQ!',
      timestamp: 'Yesterday',
    ),
  ];
  List<EcoGift> get receivedGifts => List.unmodifiable(_receivedGifts);

  void sendEcoGift(String neighborName, String street, String berryType) {
    if (berryType.contains('Grass') && _grassBerries > 0) _grassBerries--;
    if (berryType.contains('Steel') && _steelBerries > 0) _steelBerries--;
    if (berryType.contains('Water') && _waterBerries > 0) _waterBerries--;

    _user = _user.copyWith(points: _user.points + 10); // Reward neighborly spirit
    _activity.insert(
      0,
      PointsActivity(
        'Eco-Gift sent to $neighborName ($berryType)',
        'Just now',
        10,
      ),
    );
    notifyListeners();
  }

  // Neighbor Trade Offers
  final List<TradeOffer> _tradeOffers = [
    TradeOffer(
      id: 't1',
      neighborName: 'Nur Aina',
      street: 'Jalan Makmur 3/10',
      offeredPokemon: PokeApiService.instance.getCatalogPokemon('beaver'),
      wantedType: 'Steel / Metal',
    ),
    TradeOffer(
      id: 't2',
      neighborName: 'Daniel Tan',
      street: 'Jalan Makmur 3/4',
      offeredPokemon: PokeApiService.instance.getCatalogPokemon('chick'),
      wantedType: 'Clean Plastic',
    ),
  ];
  List<TradeOffer> get tradeOffers => List.unmodifiable(_tradeOffers);

  void acceptTrade(TradeOffer offer, PokemonData given) {
    offer.isCompleted = true;
    _unlockedPokemon.removeWhere((p) => p.id == given.id);
    _unlockedPokemon.add(offer.offeredPokemon);

    _user = _user.copyWith(points: _user.points + 25);
    _activity.insert(
      0,
      PointsActivity(
        'Neighbor Trade: Received ${offer.offeredPokemon.displayName} from ${offer.neighborName}',
        'Just now',
        25,
      ),
    );
    notifyListeners();
  }

  // Township Achievement Badges
  final List<TownshipBadge> _badges = [
    const TownshipBadge(
      id: 'b_plastic',
      title: 'Plastics Master',
      description: 'Recycled 50 clean PET plastic bottles into smart bins',
      icon: Icons.local_drink_rounded,
      category: 'Recycling',
      isUnlocked: true,
      progress: 50,
      target: 50,
      unlockedDate: '18 Oct 2026',
    ),
    const TownshipBadge(
      id: 'b_mobility',
      title: 'Township Marathoner',
      description: 'Walked 20 km along Sime Darby park trails',
      icon: Icons.directions_walk_rounded,
      category: 'Healthy Living',
      isUnlocked: true,
      progress: 24,
      target: 20,
      unlockedDate: '20 Oct 2026',
    ),
    const TownshipBadge(
      id: 'b_street',
      title: 'Street Champion 👑',
      description: 'Led Jalan Makmur to #1 rank in the territorial rivalry',
      icon: Icons.military_tech_rounded,
      category: 'Community',
      isUnlocked: true,
      progress: 1,
      target: 1,
      unlockedDate: 'This Week',
    ),
    const TownshipBadge(
      id: 'b_compost',
      title: 'Compost King',
      description: 'Diverted 15 kg of organic food waste to bio-compost',
      icon: Icons.compost_rounded,
      category: 'Circular Garden',
      isUnlocked: false,
      progress: 9,
      target: 15,
    ),
    const TownshipBadge(
      id: 'b_shiny',
      title: '✨ Shiny Eco-Hunter',
      description: 'Discovered a rare sparkling Shiny Pokémon variant',
      icon: Icons.auto_awesome_rounded,
      category: 'Biodiversity',
      isUnlocked: true,
      progress: 1,
      target: 1,
      unlockedDate: 'Just now',
    ),
    const TownshipBadge(
      id: 'b_ewaste',
      title: 'E-Waste Guardian',
      description: 'Safely recycled 5 household batteries or scrap electronics',
      icon: Icons.battery_charging_full_rounded,
      category: 'Safety',
      isUnlocked: false,
      progress: 3,
      target: 5,
    ),
  ];
  List<TownshipBadge> get badges => List.unmodifiable(_badges);

  // Circular Economy Perks
  final List<CircularPerk> _circularPerks = [
    const CircularPerk(
      id: 'perk_cafe',
      title: 'RM 5 Voucher @ Oat & Green Eco-Cafe',
      partnerName: 'Oat & Green (BBR Town Centre)',
      category: 'Dining & Zero Waste',
      pointsCost: 350,
      description: 'Enjoy handcrafted zero-waste coffees and plant-based treats using locally grown herbs.',
      icon: Icons.coffee_rounded,
      voucherCode: 'ECO-OAT-5821',
    ),
    const CircularPerk(
      id: 'perk_maintenance',
      title: '10% Off Monthly Maintenance Fee',
      partnerName: 'Sime Darby Property Township Management',
      category: 'Township Living',
      pointsCost: 1200,
      description: 'Direct credit towards your monthly residential maintenance and security assessment fee.',
      icon: Icons.home_work_rounded,
      voucherCode: 'SDP-FEE-9912',
    ),
    const CircularPerk(
      id: 'perk_compost',
      title: '5 kg Enriched Organic Compost Bag',
      partnerName: 'Township Organic Bio-Hub',
      category: 'Circular Garden',
      pointsCost: 200,
      description: 'Nutrient-rich organic compost produced directly from the neighborhood food waste collection.',
      icon: Icons.compost_rounded,
      voucherCode: 'BIO-BAG-4410',
    ),
    const CircularPerk(
      id: 'perk_ev',
      title: '2-Hour Green EV Charging Pass',
      partnerName: 'Setia City Mall & BBR EV Station',
      category: 'Green Mobility',
      pointsCost: 400,
      description: 'Complimentary high-speed solar EV charging credits for township electric vehicle drivers.',
      icon: Icons.electric_car_rounded,
      voucherCode: 'EV-SOLAR-2284',
    ),
    const CircularPerk(
      id: 'perk_grocer',
      title: 'RM 10 Eco-Market Produce Voucher',
      partnerName: 'BBR Weekend Community Farmers Market',
      category: 'Local Fresh Produce',
      pointsCost: 600,
      description: 'Fresh organic greens and fruit harvested from urban micro-farms in Selangor.',
      icon: Icons.shopping_basket_rounded,
      voucherCode: 'MKT-FRESH-7719',
    ),
  ];
  List<CircularPerk> get circularPerks => List.unmodifiable(_circularPerks);

  // Activity Log
  final List<PointsActivity> _activity = List<PointsActivity>.from(MockData.activity);
  List<PointsActivity> get activity => List.unmodifiable(_activity);



  void setActiveCompanion(PokemonData pokemon) {
    _activeCompanion = pokemon;
    notifyListeners();
  }

  /// Gains EXP for the active companion, leveling up and checking evolution threshold
  bool gainCompanionExp(int exp) {
    int newExp = _activeCompanion.currentExp + exp;
    int newLevel = _activeCompanion.level;
    int neededExp = _activeCompanion.expToNextLevel;
    bool leveledUp = false;

    while (newExp >= neededExp) {
      newExp -= neededExp;
      newLevel++;
      neededExp = (neededExp * 1.25).round();
      leveledUp = true;
    }

    _activeCompanion = _activeCompanion.copyWith(
      level: newLevel,
      currentExp: newExp,
      expToNextLevel: neededExp,
    );

    final idx = _unlockedPokemon.indexWhere((p) => p.id == _activeCompanion.id);
    if (idx != -1) {
      _unlockedPokemon[idx] = _activeCompanion;
    }
    notifyListeners();
    return leveledUp && _activeCompanion.canEvolve && !_activeCompanion.hasDeclinedEvolution;
  }

  /// Resident chooses "No Need" to evolve now (keeps current form, can evolve later anytime)
  void declineEvolution(PokemonData pokemon) {
    final updated = pokemon.copyWith(hasDeclinedEvolution: true);
    if (_activeCompanion.id == pokemon.id) {
      _activeCompanion = updated;
    }
    final idx = _unlockedPokemon.indexWhere((p) => p.id == pokemon.id);
    if (idx != -1) {
      _unlockedPokemon[idx] = updated;
    }
    notifyListeners();
  }

  /// Evolution Feature: Evolve Pokémon to Stage 2 or Stage 3!
  Future<bool> evolvePokemon(PokemonData pokemon) async {
    if (pokemon.evolvesToId == null) return false;

    final targetId = pokemon.evolvesToId!;
    final baseEvolved = await PokeApiService.instance.getPokemon(targetId, isShiny: pokemon.isShiny);
    final evolved = baseEvolved.copyWith(
      isLocked: false,
      isShiny: pokemon.isShiny,
      level: math.max(pokemon.level, pokemon.requiredEvolutionLevel ?? 16),
      currentExp: 0,
      hasDeclinedEvolution: false,
    );

    final idx = _unlockedPokemon.indexWhere((p) => p.id == pokemon.id);
    if (idx != -1) {
      _unlockedPokemon[idx] = evolved;
    } else {
      _unlockedPokemon.add(evolved);
    }

    if (_activeCompanion.id == pokemon.id) {
      _activeCompanion = evolved;
    }

    _user = _user.copyWith(points: _user.points + 100);
    _activity.insert(
      0,
      PointsActivity(
        '✨ EVOLUTION: ${pokemon.displayName} evolved into ${evolved.displayName}!',
        'Just now',
        100,
      ),
    );

    notifyListeners();
    return true;
  }

  /// Interactive Eco-Battle Attack on Sludge-Hog
  int attackBossWithCompanion(PokemonMove move) {
    if (isBossOnCooldown) return 0;
    final damage = move.calculateDamage();
    _boss.bossCurrentHp = math.max(0, _boss.bossCurrentHp - damage);
    _boss.currentKg = math.min(_boss.targetKg, _boss.currentKg + (damage / 10.0));

    _user = _user.copyWith(points: _user.points + 15);

    // If Sludge-Hog defeated, give Forest Guardian Dog and start the respawn cooldown!
    if (_boss.isDefeated) {
      _onBossDefeated();
    }

    notifyListeners();
    return damage;
  }

  PokemonData unlockGuardianDog() {
    final guardian = PokeApiService.instance.getCatalogPokemon('dog').copyWith(isLocked: false, level: 20);
    if (!_unlockedPokemon.any((p) => p.id == guardian.id)) {
      _unlockedPokemon.add(guardian);
      _user = _user.copyWith(points: _user.points + 500);
      _activity.insert(
        0,
        PointsActivity('VICTORY: Unlocked Forest Guardian Dog!', 'Just now', 500),
      );
      notifyListeners();
    }
    return guardian;
  }

  bool feedCompanion(EcoMaterialType type) {
    bool fed = false;
    if (type == EcoMaterialType.grass && _grassBerries > 0) {
      _grassBerries--;
      fed = true;
    } else if (type == EcoMaterialType.water && _waterBerries > 0) {
      _waterBerries--;
      fed = true;
    } else if (type == EcoMaterialType.steel && _steelBerries > 0) {
      _steelBerries--;
      fed = true;
    }

    if (fed) {
      _activeCompanion = _activeCompanion.copyWith(
        friendship: math.min(100, _activeCompanion.friendship + 10),
        currentEvolutionBerries: _activeCompanion.currentEvolutionBerries + 1,
      );
      _user = _user.copyWith(points: _user.points + 5);
      gainCompanionExp(35);
    }
    return fed;
  }

  PokemonEgg? syncTownshipParkSteps(int steps) {
    final km = steps / 1350.0;
    return logWalkingDistance(km);
  }

  PokemonEgg? logWalkingDistance(double addedKm) {
    _todayWalkedKm += addedKm;
    PokemonEgg? newlyHatched;

    for (final egg in _eggs) {
      if (!egg.isHatched) {
        egg.walkedKm += addedKm;
        if (egg.walkedKm >= egg.targetKm) {
          egg.isHatched = true;
          newlyHatched = egg;
          _hatchEgg(egg);
          break;
        }
      }
    }

    notifyListeners();
    return newlyHatched;
  }

  void _hatchEgg(PokemonEgg egg) async {
    // 2% chance of Shiny or guaranteed on Golden Mystery Egg
    final isShiny = egg.isGoldenMystery || (math.Random().nextInt(50) == 0);

    final hatchedPoke = await PokeApiService.instance.getPokemon(
      egg.pokemonId,
      defaultEcoType: egg.eggType,
      isShiny: isShiny,
    );
    if (!_unlockedPokemon.any((p) => p.id == hatchedPoke.id)) {
      _unlockedPokemon.add(hatchedPoke.copyWith(isLocked: false));
    }
    _user = _user.copyWith(points: _user.points + (isShiny ? 100 : 50));
    _activity.insert(
      0,
      PointsActivity(
        isShiny
            ? '✨ SHINY HATCH: ${hatchedPoke.displayName}!'
            : 'Hatched ${hatchedPoke.displayName}! (Mobility Goal)',
        'Just now',
        isShiny ? 100 : 50,
      ),
    );
    notifyListeners();
  }

  void processWasteRecycled({
    required String wasteName,
    required EcoMaterialType materialType,
    required int points,
    required double weightKg,
    required String binName,
    bool isWalkedSelfDrop = true,
  }) {
    int calculatedPoints = isWalkedSelfDrop ? (points * 2) : points;

    if (_streetRivalries.first.isLeader) {
      calculatedPoints = (calculatedPoints * 1.10).round();
    }

    _user = _user.copyWith(points: _user.points + calculatedPoints);

    String rewardNotice = '';
    switch (materialType) {
      case EcoMaterialType.grass:
        _grassBerries += isWalkedSelfDrop ? 6 : 3;
        rewardNotice = isWalkedSelfDrop ? '+6 Grass Berries (2x Mobility)' : '+3 Grass Berries';
        break;
      case EcoMaterialType.steel:
        _steelBerries += isWalkedSelfDrop ? 6 : 3;
        rewardNotice = isWalkedSelfDrop ? '+6 Steel Berries (2x Mobility)' : '+3 Steel Berries';
        break;
      case EcoMaterialType.water:
        _waterBerries += isWalkedSelfDrop ? 6 : 3;
        rewardNotice = isWalkedSelfDrop ? '+6 Water Berries (2x Mobility)' : '+3 Water Berries';
        break;
      case EcoMaterialType.electric:
        _steelBerries += isWalkedSelfDrop ? 4 : 2;
        rewardNotice = isWalkedSelfDrop ? '+4 Electric Cells (2x Mobility)' : '+2 Electric Cells';
        break;
      default:
        _grassBerries += 2;
        rewardNotice = '+2 Eco-Berries';
    }

    if (isWalkedSelfDrop) {
      logWalkingDistance(0.35);
    }

    if (!isBossOnCooldown) {
      _boss.currentKg = (_boss.currentKg + weightKg).clamp(0.0, _boss.targetKg);
      _boss.bossCurrentHp = math.max(0, _boss.bossCurrentHp - (weightKg * 20).round());
      _boss.participantsCount += 1;

      if (_boss.isDefeated) {
        _onBossDefeated();
      }
    }

    if (_eggs.where((e) => !e.isHatched).length < 3) {
      final egg = _generateEggForMaterial(materialType);
      _eggs.add(egg);
    }

    if (!isWalkedSelfDrop && _isBuggySummoned) {
      _isBuggySummoned = false;
      _buggy.status = 'Cruising Precinct 3 Streets';
    }

    _activity.insert(
      0,
      PointsActivity(
        isWalkedSelfDrop
            ? '$wasteName (2x Self-Drop Walk) — $rewardNotice'
            : '$wasteName (Buggy Pickup) — $rewardNotice',
        'Just now',
        calculatedPoints,
      ),
    );

    notifyListeners();
  }

  PokemonEgg _generateEggForMaterial(EcoMaterialType materialType) {
    if (materialType == EcoMaterialType.steel) {
      return PokemonEgg(
        id: 'egg_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Steel Elephant Eco-Egg',
        eggType: EcoMaterialType.steel,
        targetKm: 3.0,
        walkedKm: 0.0,
        pokemonId: 304, // Steel Elephant
        pokemonName: 'Steel Elephant',
      );
    } else if (materialType == EcoMaterialType.water) {
      return PokemonEgg(
        id: 'egg_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Wetland Beaver Eco-Egg',
        eggType: EcoMaterialType.water,
        targetKm: 2.0,
        walkedKm: 0.0,
        pokemonId: 60, // Wetland Beaver
        pokemonName: 'Wetland Beaver',
      );
    } else {
      return PokemonEgg(
        id: 'egg_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Cube Bunny Flora Egg',
        eggType: EcoMaterialType.grass,
        targetKm: 2.0,
        walkedKm: 0.0,
        pokemonId: 1, // Cube Bunny
        pokemonName: 'Cube Bunny',
      );
    }
  }

  bool redeemCircularPerk(String perkId) {
    final index = _circularPerks.indexWhere((p) => p.id == perkId);
    if (index == -1) return false;

    final perk = _circularPerks[index];
    if (_user.points < perk.pointsCost || perk.isRedeemed) return false;

    _user = _user.copyWith(points: _user.points - perk.pointsCost);
    _circularPerks[index] = perk.copyWith(isRedeemed: true);

    _activity.insert(
      0,
      PointsActivity(
        'Redeemed: ${perk.title}',
        'Just now',
        -perk.pointsCost,
      ),
    );

    notifyListeners();
    return true;
  }
}
