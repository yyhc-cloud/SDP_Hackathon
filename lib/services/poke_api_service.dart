import '../models/pokemon_model.dart';

/// Service managing all Township Cube Pets (Kenney Cube 3D Assets & Evolution Trees).
class PokeApiService {
  PokeApiService._();
  static final PokeApiService instance = PokeApiService._();

  final Map<int, PokemonData> _cache = {};

  static const Map<String, String> _kennyPetMap = {
    // Grass line
    'bunny': 'assets/kenny_cube/Previews/animal-bunny.png',
    'deer': 'assets/kenny_cube/Previews/animal-deer.png',
    'panda': 'assets/kenny_cube/Previews/animal-panda.png',
    'chick': 'assets/kenny_cube/Previews/animal-chick.png',
    'caterpillar': 'assets/kenny_cube/Previews/animal-caterpillar.png',
    'parrot': 'assets/kenny_cube/Previews/animal-parrot.png',
    // Steel line
    'elephant': 'assets/kenny_cube/Previews/animal-elephant.png',
    'cow': 'assets/kenny_cube/Previews/animal-cow.png',
    'lion': 'assets/kenny_cube/Previews/animal-lion.png',
    // Electric line
    'bee': 'assets/kenny_cube/Previews/animal-bee.png',
    'monkey': 'assets/kenny_cube/Previews/animal-monkey.png',
    'giraffe': 'assets/kenny_cube/Previews/animal-giraffe.png',
    'cat': 'assets/kenny_cube/Previews/animal-cat.png',
    'fox': 'assets/kenny_cube/Previews/animal-fox.png',
    'tiger': 'assets/kenny_cube/Previews/animal-tiger.png',
    // Water line
    'fish': 'assets/kenny_cube/Previews/animal-fish.png',
    'crab': 'assets/kenny_cube/Previews/animal-crab.png',
    'penguin': 'assets/kenny_cube/Previews/animal-penguin.png',
    'beaver': 'assets/kenny_cube/Previews/animal-beaver.png',
    'koala': 'assets/kenny_cube/Previews/animal-koala.png',
    'polar': 'assets/kenny_cube/Previews/animal-polar.png',
    // Mythical Guardians
    'dog': 'assets/kenny_cube/Previews/animal-dog.png',
    'pig': 'assets/kenny_cube/Previews/animal-pig.png',
    // Villain & Sludge Overlords
    'hog': 'assets/kenny_cube/Previews/animal-hog.png',
  };

  static const Map<int, String> _kennyIdMap = {
    1: 'assets/kenny_cube/Previews/animal-bunny.png',
    2: 'assets/kenny_cube/Previews/animal-deer.png',
    3: 'assets/kenny_cube/Previews/animal-panda.png',
    43: 'assets/kenny_cube/Previews/animal-chick.png',
    44: 'assets/kenny_cube/Previews/animal-caterpillar.png',
    182: 'assets/kenny_cube/Previews/animal-parrot.png',
    304: 'assets/kenny_cube/Previews/animal-elephant.png',
    305: 'assets/kenny_cube/Previews/animal-cow.png',
    306: 'assets/kenny_cube/Previews/animal-lion.png',
    81: 'assets/kenny_cube/Previews/animal-bee.png',
    82: 'assets/kenny_cube/Previews/animal-monkey.png',
    462: 'assets/kenny_cube/Previews/animal-giraffe.png',
    172: 'assets/kenny_cube/Previews/animal-cat.png',
    25: 'assets/kenny_cube/Previews/animal-fox.png',
    26: 'assets/kenny_cube/Previews/animal-tiger.png',
    7: 'assets/kenny_cube/Previews/animal-fish.png',
    8: 'assets/kenny_cube/Previews/animal-crab.png',
    9: 'assets/kenny_cube/Previews/animal-penguin.png',
    60: 'assets/kenny_cube/Previews/animal-beaver.png',
    61: 'assets/kenny_cube/Previews/animal-koala.png',
    62: 'assets/kenny_cube/Previews/animal-polar.png',
    251: 'assets/kenny_cube/Previews/animal-dog.png',
    492: 'assets/kenny_cube/Previews/animal-pig.png',
    88: 'assets/kenny_cube/Previews/animal-hog.png',
  };

  static String getPetAsset(dynamic idOrName) {
    if (idOrName is int && _kennyIdMap.containsKey(idOrName)) {
      return _kennyIdMap[idOrName]!;
    }
    final key = idOrName.toString().toLowerCase();
    if (_kennyPetMap.containsKey(key)) {
      return _kennyPetMap[key]!;
    }
    // Also check aliases
    if (key.contains('bunny') || key.contains('bulba')) return 'assets/kenny_cube/Previews/animal-bunny.png';
    if (key.contains('deer') || key.contains('ivy')) return 'assets/kenny_cube/Previews/animal-deer.png';
    if (key.contains('panda') || key.contains('venu')) return 'assets/kenny_cube/Previews/animal-panda.png';
    if (key.contains('fish') || key.contains('squirt')) return 'assets/kenny_cube/Previews/animal-fish.png';
    if (key.contains('crab') || key.contains('wartort')) return 'assets/kenny_cube/Previews/animal-crab.png';
    if (key.contains('penguin') || key.contains('blast')) return 'assets/kenny_cube/Previews/animal-penguin.png';
    if (key.contains('elephant') || key.contains('aron')) return 'assets/kenny_cube/Previews/animal-elephant.png';
    if (key.contains('cow') || key.contains('lairon')) return 'assets/kenny_cube/Previews/animal-cow.png';
    if (key.contains('lion') || key.contains('aggron')) return 'assets/kenny_cube/Previews/animal-lion.png';
    if (key.contains('fox') || key.contains('pika')) return 'assets/kenny_cube/Previews/animal-fox.png';
    if (key.contains('tiger') || key.contains('raichu')) return 'assets/kenny_cube/Previews/animal-tiger.png';
    if (key.contains('cat') || key.contains('pichu')) return 'assets/kenny_cube/Previews/animal-cat.png';
    if (key.contains('bee') || key.contains('magnet')) return 'assets/kenny_cube/Previews/animal-bee.png';
    if (key.contains('monkey')) return 'assets/kenny_cube/Previews/animal-monkey.png';
    if (key.contains('giraffe')) return 'assets/kenny_cube/Previews/animal-giraffe.png';
    if (key.contains('dog') || key.contains('celebi')) return 'assets/kenny_cube/Previews/animal-dog.png';
    if (key.contains('pig') || key.contains('shaymin')) return 'assets/kenny_cube/Previews/animal-pig.png';
    if (key.contains('hog') || key.contains('grimer') || key.contains('sludge')) return 'assets/kenny_cube/Previews/animal-hog.png';

    return 'assets/kenny_cube/Previews/animal-bunny.png';
  }

  PokemonData getCatalogPokemon(dynamic idOrName, {bool isShiny = false}) {
    final key = idOrName is int ? idOrName : _resolveAliasToId(idOrName.toString());
    if (_cache.containsKey(key)) {
      final cached = _cache[key]!;
      return isShiny ? cached.copyWith(isShiny: true) : cached;
    }
    final fallback = _fallbackById(key) ?? _fallbackById(1)!;
    _cache[fallback.id] = fallback;
    return isShiny ? fallback.copyWith(isShiny: true) : fallback;
  }

  Future<PokemonData> getPokemon(dynamic idOrName, {EcoMaterialType? defaultEcoType, String? customBio, bool isShiny = false}) async {
    return getCatalogPokemon(idOrName, isShiny: isShiny);
  }

  static int _resolveAliasToId(String name) {
    final lower = name.toLowerCase();
    for (final entry in _fallbackPokemonCatalog.entries) {
      if (entry.key == lower || entry.value.name == lower || entry.value.displayName.toLowerCase() == lower) {
        return entry.value.id;
      }
    }
    // Backward compatibility aliases
    if (lower.contains('bulba') || lower.contains('bunny')) return 1;
    if (lower.contains('ivy') || lower.contains('deer')) return 2;
    if (lower.contains('venu') || lower.contains('panda')) return 3;
    if (lower.contains('squirt') || lower.contains('fish')) return 7;
    if (lower.contains('wartort') || lower.contains('crab')) return 8;
    if (lower.contains('blast') || lower.contains('penguin')) return 9;
    if (lower.contains('aron') || lower.contains('elephant')) return 304;
    if (lower.contains('lairon') || lower.contains('cow')) return 305;
    if (lower.contains('aggron') || lower.contains('lion')) return 306;
    if (lower.contains('pika') || lower.contains('fox')) return 25;
    if (lower.contains('raichu') || lower.contains('tiger')) return 26;
    if (lower.contains('pichu') || lower.contains('cat')) return 172;
    if (lower.contains('oddish') || lower.contains('chick')) return 43;
    if (lower.contains('gloom') || lower.contains('caterpillar')) return 44;
    if (lower.contains('bellossom') || lower.contains('parrot')) return 182;
    if (lower.contains('poliwag') || lower.contains('beaver')) return 60;
    if (lower.contains('koala')) return 61;
    if (lower.contains('polar')) return 62;
    if (lower.contains('bee') || lower.contains('magnet')) return 81;
    if (lower.contains('celebi') || lower.contains('dog')) return 251;
    if (lower.contains('shaymin') || lower.contains('pig')) return 492;
    if (lower.contains('hog') || lower.contains('grimer')) return 88;
    return 1;
  }

  static PokemonData? _fallbackById(int id) {
    for (final p in _fallbackPokemonCatalog.values) {
      if (p.id == id) return p;
    }
    return null;
  }

  static const Map<String, List<int>> _evolutionFamilies = {
    'bunny': [1, 2, 3], // Cube Bunny -> Flora Deer -> Bamboo Panda
    'fish': [7, 8, 9], // Aqua Fish -> Coral Crab -> Glacier Penguin
    'elephant': [304, 305, 306], // Steel Elephant -> Iron Cow -> Titan Lion
    'cat': [172, 25, 26], // Spark Cat -> Solar Fox -> Thunder Tiger
    'chick': [43, 44, 182], // Sprout Chick -> Bio Caterpillar -> Canopy Parrot
    'beaver': [60, 61, 62], // Wetland Beaver -> Eco Koala -> Polar Guardian
    'bee': [81, 82, 462], // Cyber Bee -> Magnetic Monkey -> Grid Giraffe
    'dog': [251], // Forest Guardian Dog
    'pig': [492], // Bloom Piglet
  };

  /// Returns the complete ordered evolutionary tree for any given Cube Pet
  List<PokemonData> getEvolutionTreeFor(PokemonData pet) {
    for (final entry in _evolutionFamilies.entries) {
      if (entry.value.contains(pet.id)) {
        return entry.value.map((id) => getCatalogPokemon(id)).toList();
      }
    }
    final list = <PokemonData>[pet];
    if (pet.evolvesToId != null) {
      list.add(getCatalogPokemon(pet.evolvesToId!));
    }
    return list;
  }

  /// Full Town Pet-Dex Catalog with 100% Kenney Cube 3D Assets, complete evolution stages, and clean Cube Pet names
  static final Map<String, PokemonData> _fallbackPokemonCatalog = {
    // 1. Organic Compost Evolution Family
    'bunny': const PokemonData(
      id: 1,
      name: 'bunny',
      displayName: 'Cube Bunny',
      types: ['grass', 'nature'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-bunny.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-bunny.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-bunny.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-bunny.png',
      hp: 45,
      attack: 49,
      defense: 49,
      bioDescription: 'Attracted to organic compost from food waste sorting in township gardens.',
      ecoType: EcoMaterialType.grass,
      evolutionStage: 1,
      maxEvolutionStage: 3,
      evolvesToId: 2,
      evolvesToName: 'Flora Deer',
      berriesToEvolve: 8,
      currentEvolutionBerries: 5,
      moves: [
        PokemonMove(name: 'Vine Whip', type: 'grass', power: 45, multiplierAgainstPollution: 1.5, description: 'Super Effective (1.5x) against toxic sludge boar!'),
        PokemonMove(name: 'Tackle', type: 'normal', power: 35, multiplierAgainstPollution: 1.0, description: 'Standard physical body strike.'),
      ],
    ),
    'deer': const PokemonData(
      id: 2,
      name: 'deer',
      displayName: 'Flora Deer',
      types: ['grass', 'nature'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-deer.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-deer.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-deer.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-deer.png',
      hp: 60,
      attack: 62,
      defense: 63,
      bioDescription: 'Stage 2 Evolution: The floral antlers bloom as food waste composting expands.',
      ecoType: EcoMaterialType.grass,
      evolutionStage: 2,
      maxEvolutionStage: 3,
      evolvesToId: 3,
      evolvesToName: 'Bamboo Panda',
      berriesToEvolve: 16,
      currentEvolutionBerries: 0,
      moves: [
        PokemonMove(name: 'Razor Leaf', type: 'grass', power: 55, multiplierAgainstPollution: 1.5, description: 'Sharp leaves slice through toxic grime.'),
        PokemonMove(name: 'Sweet Scent', type: 'grass', power: 40, multiplierAgainstPollution: 1.3, description: 'Neutralizes landfill odor in the park.'),
      ],
      isLocked: true,
    ),
    'panda': const PokemonData(
      id: 3,
      name: 'panda',
      displayName: 'Bamboo Panda',
      types: ['grass', 'guardian'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-panda.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-panda.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-panda.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-panda.png',
      hp: 80,
      attack: 82,
      defense: 83,
      bioDescription: 'Stage 3 Final Evolution: Giant forest guardian that completely purifies township soil.',
      ecoType: EcoMaterialType.grass,
      evolutionStage: 3,
      maxEvolutionStage: 3,
      moves: [
        PokemonMove(name: 'Solar Beam', type: 'grass', power: 120, multiplierAgainstPollution: 1.8, description: 'Concentrated solar energy blasts away all pollution!'),
      ],
      isLocked: true,
    ),
    'chick': const PokemonData(
      id: 43,
      name: 'chick',
      displayName: 'Sprout Chick',
      types: ['grass', 'nature'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-chick.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-chick.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-chick.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-chick.png',
      hp: 45,
      attack: 50,
      defense: 55,
      bioDescription: 'Hatched from organic food waste eggs in community farm planters.',
      ecoType: EcoMaterialType.grass,
      evolutionStage: 1,
      maxEvolutionStage: 3,
      evolvesToId: 44,
      evolvesToName: 'Bio Caterpillar',
      berriesToEvolve: 8,
      moves: [
        PokemonMove(name: 'Absorb', type: 'grass', power: 40, multiplierAgainstPollution: 1.5, description: 'Absorbs toxins to heal companion HP.'),
      ],
    ),
    'caterpillar': const PokemonData(
      id: 44,
      name: 'caterpillar',
      displayName: 'Bio Caterpillar',
      types: ['grass', 'insect'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-caterpillar.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-caterpillar.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-caterpillar.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-caterpillar.png',
      hp: 60,
      attack: 65,
      defense: 70,
      bioDescription: 'Stage 2 Evolution: Converts pungent compost odors into natural flower nectar.',
      ecoType: EcoMaterialType.grass,
      evolutionStage: 2,
      maxEvolutionStage: 3,
      evolvesToId: 182,
      evolvesToName: 'Canopy Parrot',
      berriesToEvolve: 15,
      isLocked: true,
    ),
    'parrot': const PokemonData(
      id: 182,
      name: 'parrot',
      displayName: 'Canopy Parrot',
      types: ['grass', 'flying'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-parrot.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-parrot.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-parrot.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-parrot.png',
      hp: 75,
      attack: 80,
      defense: 85,
      bioDescription: 'Final Evolution: Nurtured by pristine solar gardens at Bandar Bukit Raja.',
      ecoType: EcoMaterialType.grass,
      evolutionStage: 3,
      maxEvolutionStage: 3,
      isLocked: true,
    ),

    // 2. Steel & Metal Evolution Family
    'elephant': const PokemonData(
      id: 304,
      name: 'elephant',
      displayName: 'Steel Elephant',
      types: ['steel', 'rock'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-elephant.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-elephant.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-elephant.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-elephant.png',
      hp: 50,
      attack: 70,
      defense: 100,
      bioDescription: 'Feeds on recycled aluminium drink cans collected at community centres.',
      ecoType: EcoMaterialType.steel,
      evolutionStage: 1,
      maxEvolutionStage: 3,
      evolvesToId: 305,
      evolvesToName: 'Iron Cow',
      berriesToEvolve: 10,
      currentEvolutionBerries: 6,
      moves: [
        PokemonMove(name: 'Iron Head', type: 'steel', power: 60, multiplierAgainstPollution: 1.3, description: 'Heavy alloy bash impervious to poison damage.'),
        PokemonMove(name: 'Metal Claw', type: 'steel', power: 50, multiplierAgainstPollution: 1.2, description: 'Cuts through thick discarded rubbish.'),
      ],
    ),
    'cow': const PokemonData(
      id: 305,
      name: 'cow',
      displayName: 'Iron Cow',
      types: ['steel', 'rock'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-cow.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-cow.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-cow.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-cow.png',
      hp: 60,
      attack: 90,
      defense: 140,
      bioDescription: 'Stage 2 Evolution: Armored by 100% recycled scrap metals.',
      ecoType: EcoMaterialType.steel,
      evolutionStage: 2,
      maxEvolutionStage: 3,
      evolvesToId: 306,
      evolvesToName: 'Titan Lion',
      berriesToEvolve: 20,
      isLocked: true,
    ),
    'lion': const PokemonData(
      id: 306,
      name: 'lion',
      displayName: 'Titan Lion',
      types: ['steel', 'guardian'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-lion.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-lion.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-lion.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-lion.png',
      hp: 70,
      attack: 110,
      defense: 180,
      bioDescription: 'Stage 3 Final Evolution: The iron lion titan that protects township boundaries.',
      ecoType: EcoMaterialType.steel,
      evolutionStage: 3,
      maxEvolutionStage: 3,
      moves: [
        PokemonMove(name: 'Heavy Slam', type: 'steel', power: 100, multiplierAgainstPollution: 1.6, description: 'Crushes toxic debris with sheer recycled steel mass.'),
      ],
      isLocked: true,
    ),
    'bee': const PokemonData(
      id: 81,
      name: 'bee',
      displayName: 'Cyber Bee',
      types: ['electric', 'steel'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-bee.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-bee.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-bee.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-bee.png',
      hp: 25,
      attack: 35,
      defense: 70,
      bioDescription: 'Generated when residents recycle lithium batteries and e-waste into smart bins.',
      ecoType: EcoMaterialType.electric,
      evolutionStage: 1,
      maxEvolutionStage: 3,
      evolvesToId: 82,
      evolvesToName: 'Magnetic Monkey',
      berriesToEvolve: 10,
      moves: [
        PokemonMove(name: 'Thunder Shock', type: 'electric', power: 40, multiplierAgainstPollution: 1.2, description: 'Electro-magnetic zap.'),
      ],
    ),
    'monkey': const PokemonData(
      id: 82,
      name: 'monkey',
      displayName: 'Magnetic Monkey',
      types: ['electric', 'steel'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-monkey.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-monkey.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-monkey.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-monkey.png',
      hp: 50,
      attack: 60,
      defense: 95,
      bioDescription: 'Stage 2 Evolution: Links multiple solar micro-grids across the township.',
      ecoType: EcoMaterialType.electric,
      evolutionStage: 2,
      maxEvolutionStage: 3,
      evolvesToId: 462,
      evolvesToName: 'Grid Giraffe',
      isLocked: true,
    ),
    'giraffe': const PokemonData(
      id: 462,
      name: 'giraffe',
      displayName: 'Grid Giraffe',
      types: ['electric', 'steel'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-giraffe.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-giraffe.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-giraffe.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-giraffe.png',
      hp: 70,
      attack: 70,
      defense: 115,
      bioDescription: 'Final Evolution: High-voltage eco-sentinel powered by 100% township rooftop solar.',
      ecoType: EcoMaterialType.electric,
      evolutionStage: 3,
      maxEvolutionStage: 3,
      isLocked: true,
    ),

    // 3. Water & Clean Plastic Evolution Family
    'fish': const PokemonData(
      id: 7,
      name: 'fish',
      displayName: 'Aqua Fish',
      types: ['water'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-fish.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-fish.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-fish.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-fish.png',
      hp: 44,
      attack: 48,
      defense: 65,
      bioDescription: 'Loves clean washed glass and plastic bottles diverted from township lakes.',
      ecoType: EcoMaterialType.water,
      evolutionStage: 1,
      maxEvolutionStage: 3,
      evolvesToId: 8,
      evolvesToName: 'Coral Crab',
      berriesToEvolve: 8,
      currentEvolutionBerries: 4,
      moves: [
        PokemonMove(name: 'Water Gun', type: 'water', power: 45, multiplierAgainstPollution: 1.4, description: 'Washes away toxic grime with purified stream water.'),
      ],
    ),
    'crab': const PokemonData(
      id: 8,
      name: 'crab',
      displayName: 'Coral Crab',
      types: ['water'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-crab.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-crab.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-crab.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-crab.png',
      hp: 59,
      attack: 63,
      defense: 80,
      bioDescription: 'Stage 2 Evolution: Swims in restored retention ponds at Elmina and Bukit Raja.',
      ecoType: EcoMaterialType.water,
      evolutionStage: 2,
      maxEvolutionStage: 3,
      evolvesToId: 9,
      evolvesToName: 'Glacier Penguin',
      isLocked: true,
    ),
    'penguin': const PokemonData(
      id: 9,
      name: 'penguin',
      displayName: 'Glacier Penguin',
      types: ['water', 'ice'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-penguin.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-penguin.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-penguin.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-penguin.png',
      hp: 79,
      attack: 83,
      defense: 100,
      bioDescription: 'Final Evolution: High-pressure water cleansers cleanse entire river corridors.',
      ecoType: EcoMaterialType.water,
      evolutionStage: 3,
      maxEvolutionStage: 3,
      isLocked: true,
    ),
    'beaver': const PokemonData(
      id: 60,
      name: 'beaver',
      displayName: 'Wetland Beaver',
      types: ['water'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-beaver.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-beaver.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-beaver.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-beaver.png',
      hp: 40,
      attack: 50,
      defense: 40,
      bioDescription: 'Swims in the restored wetlands at Elmina Lakeside Promenade.',
      ecoType: EcoMaterialType.water,
      evolutionStage: 1,
      maxEvolutionStage: 3,
      evolvesToId: 61,
      evolvesToName: 'Eco Koala',
    ),
    'koala': const PokemonData(
      id: 61,
      name: 'koala',
      displayName: 'Eco Koala',
      types: ['water'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-koala.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-koala.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-koala.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-koala.png',
      hp: 65,
      attack: 65,
      defense: 65,
      bioDescription: 'Stage 2 Evolution: Patrols stormwater filtration wetlands.',
      ecoType: EcoMaterialType.water,
      evolutionStage: 2,
      maxEvolutionStage: 3,
      evolvesToId: 62,
      evolvesToName: 'Polar Guardian',
      isLocked: true,
    ),
    'polar': const PokemonData(
      id: 62,
      name: 'polar',
      displayName: 'Polar Guardian',
      types: ['water', 'fighting'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-polar.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-polar.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-polar.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-polar.png',
      hp: 90,
      attack: 95,
      defense: 95,
      bioDescription: 'Final Evolution: Powerful swimmer with unmatched stamina against pollution.',
      ecoType: EcoMaterialType.water,
      evolutionStage: 3,
      maxEvolutionStage: 3,
      isLocked: true,
    ),

    // 4. Electric & Solar Energy Evolution Family
    'cat': const PokemonData(
      id: 172,
      name: 'cat',
      displayName: 'Spark Cat',
      types: ['electric'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-cat.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-cat.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-cat.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-cat.png',
      hp: 20,
      attack: 40,
      defense: 15,
      bioDescription: 'Discharged safely from properly insulated recycled lithium cells.',
      ecoType: EcoMaterialType.electric,
      evolutionStage: 1,
      maxEvolutionStage: 3,
      evolvesToId: 25,
      evolvesToName: 'Solar Fox',
      isLocked: true,
    ),
    'fox': const PokemonData(
      id: 25,
      name: 'fox',
      displayName: 'Solar Fox',
      types: ['electric'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-fox.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-fox.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-fox.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-fox.png',
      hp: 35,
      attack: 55,
      defense: 40,
      bioDescription: 'Stage 2 Evolution: Powers community EV charging stations with pure clean spark.',
      ecoType: EcoMaterialType.electric,
      evolutionStage: 2,
      maxEvolutionStage: 3,
      evolvesToId: 26,
      evolvesToName: 'Thunder Tiger',
      isLocked: true,
    ),
    'tiger': const PokemonData(
      id: 26,
      name: 'tiger',
      displayName: 'Thunder Tiger',
      types: ['electric'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-tiger.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-tiger.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-tiger.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-tiger.png',
      hp: 60,
      attack: 90,
      defense: 55,
      bioDescription: 'Final Evolution: Lightning tail absorbs residual battery waste energy.',
      ecoType: EcoMaterialType.electric,
      evolutionStage: 3,
      maxEvolutionStage: 3,
      isLocked: true,
    ),

    // 5. Mythical Sanctuary Guardians
    'dog': const PokemonData(
      id: 251,
      name: 'dog',
      displayName: 'Forest Guardian Dog',
      types: ['nature', 'guardian'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-dog.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-dog.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-dog.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-dog.png',
      hp: 100,
      attack: 100,
      defense: 100,
      bioDescription: 'The Loyal Voice of the Forest. Awarded when the Pollution Sludge-Hog is defeated!',
      ecoType: EcoMaterialType.mythical,
      evolutionStage: 1,
      maxEvolutionStage: 1,
      moves: [
        PokemonMove(name: 'Leaf Storm', type: 'grass', power: 130, multiplierAgainstPollution: 2.0, description: 'Mythical green hurricane purifies all toxic waste!'),
      ],
      isLocked: true,
    ),
    'pig': const PokemonData(
      id: 492,
      name: 'pig',
      displayName: 'Bloom Piglet',
      types: ['grass', 'guardian'],
      officialArtworkUrl: 'assets/kenny_cube/Previews/animal-pig.png',
      spriteUrl: 'assets/kenny_cube/Previews/animal-pig.png',
      shinySpriteUrl: 'assets/kenny_cube/Previews/animal-pig.png',
      shinyArtworkUrl: 'assets/kenny_cube/Previews/animal-pig.png',
      hp: 100,
      attack: 100,
      defense: 100,
      bioDescription: 'Transmutes polluted industrial fumes into fresh jasmine aroma.',
      ecoType: EcoMaterialType.mythical,
      evolutionStage: 1,
      maxEvolutionStage: 1,
      isLocked: true,
    ),
  };

  /// Returns full list of pokedex items
  static List<PokemonData> getAllPokedexEntries() {
    return _fallbackPokemonCatalog.values.toList();
  }
}
