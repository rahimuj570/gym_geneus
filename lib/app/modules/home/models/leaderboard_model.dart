// lib/app/modules/gamification/models/leaderboard_model.dart

class LeaderboardResponse {
  final bool success;
  final LeaderboardData data;

  LeaderboardResponse({required this.success, required this.data});

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return LeaderboardResponse(
      success: json['success'] ?? false,
      data: LeaderboardData.fromJson(json['data']),
    );
  }
}

class LeaderboardData {
  final String rank;
  final int rankLevel;
  final String rankColor;
  final int userPosition;
  final int totalUsersInRank;
  final String weekStart;
  final List<LeaderboardUser> leaderboard;

  LeaderboardData({
    required this.rank,
    required this.rankLevel,
    required this.rankColor,
    required this.userPosition,
    required this.totalUsersInRank,
    required this.weekStart,
    required this.leaderboard,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    return LeaderboardData(
      rank: json['rank'] ?? "Unranked",
      rankLevel: json['rank_level'] ?? 0,
      rankColor: json['rank_color'] ?? "#FFFFFF",
      userPosition: json['user_position'] ?? 0,
      totalUsersInRank: json['total_users_in_rank'] ?? 0,
      weekStart: json['week_start'] ?? "",
      leaderboard: (json['leaderboard'] as List)
          .map((item) => LeaderboardUser.fromJson(item))
          .toList(),
    );
  }
}

class LeaderboardUser {
  final int position;
  final String userId;
  final String username;
  final int weeklyPoints;
  final int totalPoints;
  final bool isCurrentUser;

  LeaderboardUser({
    required this.position,
    required this.userId,
    required this.username,
    required this.weeklyPoints,
    required this.totalPoints,
    required this.isCurrentUser,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      position: json['position'] ?? 0,
      userId: json['user_id'] ?? "",
      username: json['full_name'] ?? "Anonymous",
      weeklyPoints: json['weekly_points'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      isCurrentUser: json['is_current_user'] ?? false,
    );
  }
}
