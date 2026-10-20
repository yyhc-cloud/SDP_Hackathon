// Placeholder data until the Supabase backend is wired up.

class UserProfile {
  const UserProfile({
    required this.name,
    required this.residence,
    required this.points,
    required this.streakDays,
    required this.guild,
    required this.isLanded,
  });

  final String name;
  final String residence;
  final int points;
  final int streakDays;
  final String guild;
  final bool isLanded;
}

class PointsActivity {
  const PointsActivity(this.title, this.date, this.points);

  final String title;
  final String date;
  final int points; // negative = redeemed
}

class LeaderboardEntry {
  const LeaderboardEntry(this.name, this.subtitle, this.points);

  final String name;
  final String subtitle;
  final int points;
}

class CollectionCentre {
  const CollectionCentre(this.name, this.distance, this.hours, this.accepts);

  final String name;
  final String distance;
  final String hours;
  final List<String> accepts;
}

class Announcement {
  const Announcement(this.tag, this.title, this.subtitle);

  final String tag;
  final String title;
  final String subtitle;
}

class MockData {
  MockData._();

  static const user = UserProfile(
    name: 'Aisyah',
    residence: 'Bandar Bukit Raja',
    points: 1280,
    streakDays: 6,
    guild: 'Precinct 3 Eco Warriors',
    isLanded: true,
  );

  /// Parking redemption rate: points per RM 1.
  static const pointsPerRinggit = 100;

  static const activity = [
    PointsActivity('Plastic bottles × 4 — Centre A', 'Today, 10:12 AM', 40),
    PointsActivity('Food waste pickup (2.1 kg)', 'Yesterday', 25),
    PointsActivity('Parking — Setia City Mall', '17 Oct', -300),
    PointsActivity('7-day streak bonus', '15 Oct', 100),
    PointsActivity('Paper & cardboard (3.4 kg)', '14 Oct', 34),
  ];

  static const residents = [
    LeaderboardEntry('Daniel Tan', 'Precinct 1', 4320),
    LeaderboardEntry('Nur Aina', 'Precinct 3', 3980),
    LeaderboardEntry('Ravi K.', 'Precinct 2', 3510),
    LeaderboardEntry('Aisyah (You)', 'Precinct 3', 1280),
    LeaderboardEntry('Mei Ling', 'Precinct 4', 1150),
  ];

  static const guilds = [
    LeaderboardEntry('Precinct 1 Green Squad', '48 members', 52300),
    LeaderboardEntry('Precinct 3 Eco Warriors', '61 members', 49870),
    LeaderboardEntry('Precinct 2 Zero Heroes', '39 members', 41200),
    LeaderboardEntry('Precinct 4 Leaf League', '27 members', 22950),
  ];

  static const centres = [
    CollectionCentre('Recycling Centre A', '0.8 km', '8am – 8pm', ['Plastic', 'Paper', 'Metal']),
    CollectionCentre('Food Waste Hub', '1.2 km', '7am – 10pm', ['Food waste']),
    CollectionCentre('Mall Smart Bin', '2.5 km', '10am – 10pm', ['Plastic', 'Paper', 'General']),
  ];

  static const announcements = [
    Announcement('Guild Wars', 'October Guild War is live', 'Top guild wins 5,000 bonus points'),
    Announcement('Event', 'E-waste drive this Saturday', 'Bring old gadgets to Centre A'),
    Announcement('Tip', 'Rinse before you recycle', 'Clean items earn full points'),
  ];
}
