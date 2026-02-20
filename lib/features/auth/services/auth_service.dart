import '../../../core/network/api_client.dart';
import '../models/auth_session.dart';

class AuthService {
  AuthService(this._apiClient);

  final ApiClient _apiClient;

  Future<void> register({
    required String email,
    required String username,
    required String password,
    String? fullName,
  }) async {
    await _apiClient.post(
      '/oneid/register',
      body: <String, dynamic>{
        if (email.trim().isNotEmpty) 'email': email.trim(),
        if (username.trim().isNotEmpty) 'username': username.trim(),
        if (fullName != null && fullName.trim().isNotEmpty)
          'full_name': fullName.trim(),
        'password': password,
        'kind': 'human',
      },
    );
  }

  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/oneid/login',
      body: <String, dynamic>{'identifier': identifier, 'password': password},
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException('Unexpected login response format');
    }

    final session = AuthSession.fromJson(response, identifier: identifier);
    if (session.accessToken.isEmpty) {
      throw ApiException('Login succeeded but token is missing');
    }

    return session;
  }
}
