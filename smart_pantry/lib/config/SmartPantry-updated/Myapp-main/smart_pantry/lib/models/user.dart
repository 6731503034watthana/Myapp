class User {
  final String id;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final UserPreferences preferences;
  final UserStatistics statistics;

  User({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    required this.preferences,
    required this.statistics,
  });
}

class UserPreferences {
  bool notificationsEnabled;
  int expiryAlertDays;
  String language;
  String fontSize;
  bool weeklyReportEnabled;

  UserPreferences({
    this.notificationsEnabled = true,
    this.expiryAlertDays = 3,
    this.language = 'th',
    this.fontSize = 'large',
    this.weeklyReportEnabled = true,
  });
}

class UserStatistics {
  int totalItemsAdded;
  int totalConsumed;
  int totalDiscarded;

  UserStatistics({
    this.totalItemsAdded = 0,
    this.totalConsumed = 0,
    this.totalDiscarded = 0,
  });

  double get consumptionRate {
    if (totalItemsAdded == 0) return 0;
    return (totalConsumed / totalItemsAdded) * 100;
  }

  double get wasteRate {
    if (totalItemsAdded == 0) return 0;
    return (totalDiscarded / totalItemsAdded) * 100;
  }
}
