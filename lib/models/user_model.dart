class UserModel {
  final int id;
  final String email;
  final String nickname;
  final String? profileImageUrl;
  final String region;
  final String createdAt;
  final String token;

  const UserModel({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImageUrl,
    required this.region,
    required this.createdAt,
    required this.token,
  });

  // Mock JSON (assets/mock/user.json)
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        email: json['email'] as String,
        nickname: json['nickname'] as String,
        profileImageUrl: json['profileImageUrl'] as String?,
        region: json['region'] as String,
        createdAt: json['createdAt'] as String,
        token: json['token'] as String? ?? '',
      );

  // Real API: GET /users/me → {id, email, nickname, region, level, exp}
  factory UserModel.fromApiJson(Map<String, dynamic> json,
      {String token = ''}) =>
      UserModel(
        id: (json['id'] as num).toInt(),
        email: json['email'] as String? ?? '',
        nickname: json['nickname'] as String? ?? '',
        profileImageUrl: json['profileImageUrl'] as String?,
        region: json['region'] as String? ?? '',
        createdAt: json['createdAt'] as String? ??
            DateTime.now().toIso8601String(),
        token: token,
      );

  String get shortRegion {
    final parts = region.split(' ');
    return parts.isNotEmpty ? parts.last : region;
  }
}
