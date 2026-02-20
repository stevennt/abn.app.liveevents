class AuthSession {
  const AuthSession({
    required this.identifier,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.createdAt,
    this.userId,
  });

  final String identifier;
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime createdAt;
  final String? userId;

  bool get isExpired =>
      DateTime.now().isAfter(createdAt.add(Duration(seconds: expiresIn)));

  factory AuthSession.fromJson(
    Map<String, dynamic> json, {
    required String identifier,
  }) {
    final userJson = json['user'];
    String? resolvedUserId;
    if (userJson is Map<String, dynamic>) {
      resolvedUserId = (userJson['sticky_id'] ?? userJson['id'])?.toString();
    }

    return AuthSession(
      identifier: identifier,
      accessToken: (json['access_token'] ?? '').toString(),
      refreshToken: (json['refresh_token'] ?? '').toString(),
      tokenType: (json['token_type'] ?? 'Bearer').toString(),
      expiresIn: _toInt(json['expires_in']) ?? 3600,
      createdAt: DateTime.now(),
      userId: resolvedUserId,
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }
}
