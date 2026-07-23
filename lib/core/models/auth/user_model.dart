class LoginResponse {
  final String accessToken;
  final int expiresIn;
  final String refreshToken;
  final List<String> roles;
  final String state;
  final String tokenType;
  final String message;

  const LoginResponse({
    required this.accessToken,
    required this.expiresIn,
    required this.refreshToken,
    required this.roles,
    required this.state,
    required this.tokenType,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return LoginResponse(
      accessToken: data['access_token'] as String,
      expiresIn: data['expires_in'] as int,
      refreshToken: data['refresh_token'] as String,
      roles: List<String>.from(data['roles'] as List),
      state: data['state'] as String,
      tokenType: data['token_type'] as String,
      message: json['message'] as String? ?? '',
    );
  }
}
