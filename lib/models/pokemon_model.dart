import 'package:flutter/material.dart';

enum EcoMaterialType {
  grass,
  steel,
  water,
  electric,
  ground,
  mythical,
  general,
}

extension EcoMaterialTypeExt on EcoMaterialType {
  String get label {
    switch (this) {
      case EcoMaterialType.grass:
        return 'Organic / Food Waste';
      case EcoMaterialType.steel:
        return 'Metal & Aluminium';
      case EcoMaterialType.water:
        return 'Plastic & Clean Glass';
      case EcoMaterialType.electric:
        return 'E-Waste & Batteries';
      case EcoMaterialType.ground:
        return 'Cardboard & Paper';
      case EcoMaterialType.mythical:
        return 'Township Sanctuary Guardian';
      case EcoMaterialType.general:
        return 'General Recyclable';
    }
  }

  Color get color {
    switch (this) {
      case EcoMaterialType.grass:
        return const Color(0xFF4CAF50);
      case EcoMaterialType.steel:
        return const Color(0xFF607D8B);
      case EcoMaterialType.water:
        return const Color(0xFF2196F3);
      case EcoMaterialType.electric:
        return const Color(0xFFFFB300);
      case EcoMaterialType.ground:
        return const Color(0xFF8D6E63);
      case EcoMaterialType.mythical:
        return const Color(0xFF9C27B0);
      case EcoMaterialType.general:
        return const Color(0xFF9E9E9E);
    }
  }

  String get pokemonTypeLabel {
    switch (this) {
      case EcoMaterialType.grass:
        return 'Grass / Bug';
      case EcoMaterialType.steel:
        return 'Steel / Rock';
      case EcoMaterialType.water:
        return 'Water / Ice';
      case EcoMaterialType.electric:
        return 'Electric';
      case EcoMaterialType.ground:
        return 'Ground';
      case EcoMaterialType.mythical:
        return 'Mythical Guardian';
      case EcoMaterialType.general:
        return 'Normal';
    }
  }
}

class PokemonMove {
  const PokemonMove({
    required this.name,
    required this.type,
    required this.power,
    required this.multiplierAgainstPollution, // e.g. 1.5x for Grass against Grimer
    required this.description,
  });

  final String name;
  final String type;
  final int power;
  final double multiplierAgainstPollution;
  final String description;

  int calculateDamage() => (power * multiplierAgainstPollution).round();
}

class PokemonData {
  const PokemonData({
    required this.id,
    required this.name,
    required this.displayName,
    required this.types,
    required this.officialArtworkUrl,
    required this.spriteUrl,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.bioDescription,
    required this.ecoType,
    this.friendship = 50,
    this.isShiny = false,
    this.shinyArtworkUrl,
    this.shinySpriteUrl,
    this.evolutionStage = 1,
    this.maxEvolutionStage = 3,
    this.evolvesToId,
    this.evolvesToName,
    this.berriesToEvolve = 10,
    this.currentEvolutionBerries = 4,
    this.moves = const [],
    this.isLocked = false,
    this.level = 15,
    this.currentExp = 75,
    this.expToNextLevel = 100,
    this.requiredEvolutionLevel = 16,
    this.hasDeclinedEvolution = false,
    this.evolutionFamilyId,
  });

  final int id;
  final String name;
  final String displayName;
  final List<String> types;
  final String officialArtworkUrl;
  final String spriteUrl;
  final int hp;
  final int attack;
  final int defense;
  final String bioDescription;
  final EcoMaterialType ecoType;
  final int friendship;
  final bool isShiny;
  final String? shinyArtworkUrl;
  final String? shinySpriteUrl;
  final int evolutionStage;
  final int maxEvolutionStage;
  final int? evolvesToId;
  final String? evolvesToName;
  final int berriesToEvolve;
  final int currentEvolutionBerries;
  final List<PokemonMove> moves;
  final bool isLocked;
  final int level;
  final int currentExp;
  final int expToNextLevel;
  final int? requiredEvolutionLevel;
  final bool hasDeclinedEvolution;
  final String? evolutionFamilyId;

  String get activeArtwork => isShiny && shinyArtworkUrl != null ? shinyArtworkUrl! : officialArtworkUrl;
  String get activeSprite => isShiny && shinySpriteUrl != null ? shinySpriteUrl! : spriteUrl;
  
  /// Can evolve if target evolution exists and either level threshold or berry threshold reached
  bool get canEvolve =>
      evolvesToId != null &&
      ((requiredEvolutionLevel != null && level >= requiredEvolutionLevel!) ||
          currentEvolutionBerries >= berriesToEvolve);

  PokemonData copyWith({
    int? friendship,
    bool? isShiny,
    int? currentEvolutionBerries,
    bool? isLocked,
    int? evolutionStage,
    int? level,
    int? currentExp,
    int? expToNextLevel,
    int? requiredEvolutionLevel,
    bool? hasDeclinedEvolution,
    String? evolutionFamilyId,
    List<PokemonMove>? moves,
  }) {
    return PokemonData(
      id: id,
      name: name,
      displayName: displayName,
      types: types,
      officialArtworkUrl: officialArtworkUrl,
      spriteUrl: spriteUrl,
      hp: hp,
      attack: attack,
      defense: defense,
      bioDescription: bioDescription,
      ecoType: ecoType,
      friendship: friendship ?? this.friendship,
      isShiny: isShiny ?? this.isShiny,
      shinyArtworkUrl: shinyArtworkUrl,
      shinySpriteUrl: shinySpriteUrl,
      evolutionStage: evolutionStage ?? this.evolutionStage,
      maxEvolutionStage: maxEvolutionStage,
      evolvesToId: evolvesToId,
      evolvesToName: evolvesToName,
      berriesToEvolve: berriesToEvolve,
      currentEvolutionBerries: currentEvolutionBerries ?? this.currentEvolutionBerries,
      moves: moves ?? this.moves,
      isLocked: isLocked ?? this.isLocked,
      level: level ?? this.level,
      currentExp: currentExp ?? this.currentExp,
      expToNextLevel: expToNextLevel ?? this.expToNextLevel,
      requiredEvolutionLevel: requiredEvolutionLevel ?? this.requiredEvolutionLevel,
      hasDeclinedEvolution: hasDeclinedEvolution ?? this.hasDeclinedEvolution,
      evolutionFamilyId: evolutionFamilyId ?? this.evolutionFamilyId,
    );
  }
}

class PokemonEgg {
  PokemonEgg({
    required this.id,
    required this.name,
    required this.eggType,
    required this.targetKm,
    required this.walkedKm,
    required this.pokemonId,
    required this.pokemonName,
    this.isHatched = false,
    this.isShiny = false,
    this.isGoldenMystery = false,
  });

  final String id;
  final String name;
  final EcoMaterialType eggType;
  final double targetKm;
  double walkedKm;
  final int pokemonId;
  final String pokemonName;
  bool isHatched;
  final bool isShiny;
  final bool isGoldenMystery;

  double get progress => (walkedKm / targetKm).clamp(0.0, 1.0);
  double get remainingKm => (targetKm - walkedKm).clamp(0.0, targetKm);
}

class SmartBinLocation {
  const SmartBinLocation({
    required this.id,
    required this.name,
    required this.precinct,
    required this.fillPercentage,
    required this.acceptedMaterials,
    required this.distanceMeters,
    required this.xRatio,
    required this.yRatio,
    this.isOnline = true,
    this.isGoldenMysteryBin = false,
  });

  final String id;
  final String name;
  final String precinct;
  final int fillPercentage;
  final List<String> acceptedMaterials;
  final int distanceMeters;
  final double xRatio;
  final double yRatio;
  final bool isOnline;
  final bool isGoldenMysteryBin;

  Color get statusColor {
    if (isGoldenMysteryBin) return const Color(0xFFFFD700); // Gold
    if (fillPercentage >= 90) return const Color(0xFFD32F2F); // Red
    if (fillPercentage >= 65) return const Color(0xFFFFA000); // Amber
    return const Color(0xFF388E3C); // Green
  }

  String get statusText {
    if (isGoldenMysteryBin) return '✨ MYSTERY GOLDEN BIN (Double Drops & Shiny Boost)';
    if (fillPercentage >= 90) return 'Almost Full (90%+)';
    if (fillPercentage >= 65) return 'Medium (Moderate capacity)';
    return 'Available (Plenty of room)';
  }
}

class CommunityBoss {
  CommunityBoss({
    required this.id,
    required this.name,
    required this.pokemonId,
    required this.title,
    required this.locationName,
    required this.currentKg,
    required this.targetKg,
    required this.daysRemaining,
    required this.rewardPokemonName,
    required this.rewardPokemonId,
    required this.participantsCount,
    this.bossMaxHp = 1000,
    this.bossCurrentHp = 320,
    this.bossAsset = 'assets/kenny_cube/Previews/animal-hog.png',
  });

  final String id;
  final String name;
  final int pokemonId;
  final String title;
  final String locationName;
  double currentKg;
  final double targetKg;
  final int daysRemaining;
  final String rewardPokemonName;
  final int rewardPokemonId;
  int participantsCount;
  final int bossMaxHp;
  int bossCurrentHp;
  final String bossAsset;

  double get progressRatio => (currentKg / targetKg).clamp(0.0, 1.0);
  double get hpRatio => (bossCurrentHp / bossMaxHp).clamp(0.0, 1.0);
  bool get isDefeated => currentKg >= targetKg || bossCurrentHp <= 0;
}

class CircularPerk {
  const CircularPerk({
    required this.id,
    required this.title,
    required this.partnerName,
    required this.category,
    required this.pointsCost,
    required this.description,
    required this.icon,
    required this.voucherCode,
    this.isRedeemed = false,
  });

  final String id;
  final String title;
  final String partnerName;
  final String category;
  final int pointsCost;
  final String description;
  final IconData icon;
  final String voucherCode;
  final bool isRedeemed;

  CircularPerk copyWith({bool? isRedeemed}) {
    return CircularPerk(
      id: id,
      title: title,
      partnerName: partnerName,
      category: category,
      pointsCost: pointsCost,
      description: description,
      icon: icon,
      voucherCode: voucherCode,
      isRedeemed: isRedeemed ?? this.isRedeemed,
    );
  }
}
