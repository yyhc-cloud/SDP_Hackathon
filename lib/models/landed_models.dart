import 'package:flutter/material.dart';
import 'pokemon_model.dart';

enum DisposalChoice {
  selfDropWalk, // 2x Active Mobility Multiplier
  collectorBuggy, // Doorstep pickup at gate (1x points)
}

class CollectorBuggy {
  CollectorBuggy({
    required this.id,
    required this.name,
    required this.driverName,
    required this.plateNumber,
    required this.currentStreet,
    required this.etaMinutes,
    required this.xRatio,
    required this.yRatio,
    required this.status,
    this.phone = '+60 12-345 6789',
    this.batteryPercent = 88,
  });

  final String id;
  final String name;
  final String driverName;
  final String plateNumber;
  String currentStreet;
  int etaMinutes;
  double xRatio;
  double yRatio;
  String status;
  final String phone;
  final int batteryPercent;
}

class StreetTerritory {
  const StreetTerritory({
    required this.id,
    required this.streetName,
    required this.precinct,
    required this.color,
    required this.weeklyKg,
    required this.householdCount,
    required this.rank,
    required this.isLeader,
    required this.topMaterial,
    this.isUserStreet = false,
  });

  final String id;
  final String streetName;
  final String precinct;
  final Color color;
  final double weeklyKg;
  final int householdCount;
  final int rank;
  final bool isLeader;
  final String topMaterial;
  final bool isUserStreet;

  String get territoryReward => isLeader
      ? '👑 10% Points Boost Active + Sponsored Street BBQ this month!'
      : 'Trail by ${(rank == 2 ? 14.5 : 32.0).toStringAsFixed(1)} kg to take lead!';
}

class ParkTrail {
  const ParkTrail({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.stepsVerified,
    required this.isGeofenced,
    required this.tag,
  });

  final String id;
  final String name;
  final double distanceKm;
  final int stepsVerified;
  final bool isGeofenced;
  final String tag;
}

/// Real-world Sime Darby Property Townships (matching official SDP site)
class TownshipSite {
  const TownshipSite({
    required this.id,
    required this.name,
    required this.tagline,
    required this.state,
    required this.activeSmartBins,
    required this.activeBuggies,
    required this.prominentFeature,
  });

  final String id;
  final String name;
  final String tagline;
  final String state;
  final int activeSmartBins;
  final int activeBuggies;
  final String prominentFeature;
}

/// Township Gamification Badges
class TownshipBadge {
  const TownshipBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.isUnlocked,
    required this.progress,
    required this.target,
    this.unlockedDate,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String category;
  final bool isUnlocked;
  final int progress;
  final int target;
  final String? unlockedDate;
}

/// Neighbor-to-Neighbor Eco Gifting
class EcoGift {
  const EcoGift({
    required this.id,
    required this.senderName,
    required this.street,
    required this.itemType,
    required this.message,
    required this.timestamp,
  });

  final String id;
  final String senderName;
  final String street;
  final String itemType;
  final String message;
  final String timestamp;
}

/// Neighbor Pokemon Trade Offer
class TradeOffer {
  TradeOffer({
    required this.id,
    required this.neighborName,
    required this.street,
    required this.offeredPokemon,
    required this.wantedType,
    this.isCompleted = false,
  });

  final String id;
  final String neighborName;
  final String street;
  final PokemonData offeredPokemon;
  final String wantedType;
  bool isCompleted;
}

/// Neighbourhood Guild for Guild Wars
class NeighbourhoodGuild {
  const NeighbourhoodGuild({
    required this.id,
    required this.name,
    required this.neighbourhood,
    required this.township,
    required this.badgeColor,
    required this.memberCount,
    required this.weeklyWarPoints,
    required this.rank,
    required this.isUserGuild,
    required this.motto,
  });

  final String id;
  final String name;
  final String neighbourhood;
  final String township;
  final Color badgeColor;
  final int memberCount;
  final int weeklyWarPoints;
  final int rank;
  final bool isUserGuild;
  final String motto;
}

/// Active Battlefronts in Neighbourhood Guild Wars
class GuildBattlefront {
  GuildBattlefront({
    required this.id,
    required this.name,
    required this.location,
    required this.controllingGuild,
    required this.challengerGuild,
    required this.ourControlPercent,
    required this.totalWarPower,
    required this.bonusPerk,
    required this.frontlineIcon,
  });

  final String id;
  final String name;
  final String location;
  String controllingGuild;
  final String challengerGuild;
  double ourControlPercent;
  int totalWarPower;
  final String bonusPerk;
  final IconData frontlineIcon;
}

/// Guild War Activity Log
class GuildWarActivity {
  const GuildWarActivity({
    required this.residentName,
    required this.action,
    required this.pointsAdded,
    required this.battlefrontName,
    required this.timeAgo,
  });

  final String residentName;
  final String action;
  final int pointsAdded;
  final String battlefrontName;
  final String timeAgo;
}
