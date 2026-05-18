import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

typedef JsonMap = Map<String, dynamic>;

List<String> resolveApiBaseUrls() {
  const override = String.fromEnvironment('API_BASE_URL');
  if (override.isNotEmpty) {
    return [override];
  }
  if (kIsWeb) {
    return ['http://localhost:3000/api'];
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return const [
        'http://127.0.0.1:3000/api',
        'http://10.0.2.2:3000/api',
        'http://localhost:3000/api',
      ];
    default:
      return ['http://localhost:3000/api'];
  }
}

JsonMap _asMap(dynamic value) =>
    value is Map<String, dynamic> ? value : <String, dynamic>{};

class AppRepository {
  AppRepository({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrls = _dedupeBaseUrls(
        baseUrl == null ? resolveApiBaseUrls() : [baseUrl],
      ),
      _activeBaseUrl = _dedupeBaseUrls(
        baseUrl == null ? resolveApiBaseUrls() : [baseUrl],
      ).first;

  static const _sessionTokenKey = 'niveshiq_auth_token';
  static const _sessionUserKey = 'niveshiq_auth_user';
  final http.Client _client;
  final List<String> _baseUrls;
  String _activeBaseUrl;
  String? _authToken;
  JsonMap? _sessionUser;

  bool get isAuthenticated => (_authToken ?? '').isNotEmpty;
  JsonMap? get currentUser => _sessionUser;

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_sessionTokenKey);
    final savedUser = prefs.getString(_sessionUserKey);
    if (savedToken == null || savedToken.isEmpty) {
      return;
    }

    _authToken = savedToken;
    if (savedUser != null && savedUser.isNotEmpty) {
      final decoded = jsonDecode(savedUser);
      if (decoded is Map<String, dynamic>) {
        _sessionUser = decoded;
      }
    }

    try {
      final session = await fetchSession();
      final authenticatedUser = _asMap(session['user']);
      if (authenticatedUser.isEmpty) {
        await clearSession();
        return;
      }
      _sessionUser = authenticatedUser;
      await _persistSession();
    } catch (_) {
      await clearSession();
    }
  }

  Future<void> clearSession() async {
    _authToken = null;
    _sessionUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_sessionUserKey);
  }

  Future<void> _persistSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_authToken != null && _authToken!.isNotEmpty) {
      await prefs.setString(_sessionTokenKey, _authToken!);
    }
    if (_sessionUser != null) {
      await prefs.setString(_sessionUserKey, jsonEncode(_sessionUser));
    }
  }

  Future<void> _applyAuthResponse(JsonMap response) async {
    final token = response['token']?.toString() ?? '';
    final user = _asMap(response['user']);
    if (token.isEmpty || user.isEmpty) {
      throw Exception('Authentication response is missing session details.');
    }
    _authToken = token;
    _sessionUser = user;
    await _persistSession();
  }

  Map<String, String> _headers({bool includeJson = false}) {
    final headers = <String, String>{};
    if (includeJson) {
      headers['Content-Type'] = 'application/json';
    }
    if ((_authToken ?? '').isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  static List<String> _dedupeBaseUrls(List<String> urls) {
    final unique = <String>[];
    for (final url in urls) {
      if (!unique.contains(url)) {
        unique.add(url);
      }
    }
    return unique;
  }

  List<String> _candidateBaseUrls() {
    return [_activeBaseUrl, ..._baseUrls.where((url) => url != _activeBaseUrl)];
  }

  bool _isReachabilityError(Object error) {
    return error is TimeoutException ||
        error is SocketException ||
        error is http.ClientException;
  }

  Future<http.Response> _send(
    Future<http.Response> Function(String baseUrl) request,
  ) async {
    Object? lastError;
    final candidates = _candidateBaseUrls();
    for (final baseUrl in candidates) {
      try {
        final response = await request(
          baseUrl,
        ).timeout(const Duration(seconds: 10));
        _activeBaseUrl = baseUrl;
        return response;
      } on Exception catch (error) {
        lastError = error;
        if (!_isReachabilityError(error) || baseUrl == candidates.last) {
          rethrow;
        }
      }
    }
    throw lastError ?? Exception('Unable to reach the local API service.');
  }

  Future<JsonMap> _get(String path) async {
    final response = await _send(
      (baseUrl) => _client.get(Uri.parse('$baseUrl$path'), headers: _headers()),
    );
    return _decodeMap(response);
  }

  Future<JsonMap> _post(String path, JsonMap body) async {
    final response = await _send(
      (baseUrl) => _client.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers(includeJson: true),
        body: jsonEncode(body),
      ),
    );
    return _decodeMap(response);
  }

  Future<JsonMap> _patch(String path, JsonMap body) async {
    final response = await _send(
      (baseUrl) => _client.patch(
        Uri.parse('$baseUrl$path'),
        headers: _headers(includeJson: true),
        body: jsonEncode(body),
      ),
    );
    return _decodeMap(response);
  }

  JsonMap _decodeMap(http.Response response) {
    final dynamic decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    if (response.statusCode >= 400) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']
          : 'Request failed.';
      throw Exception(message);
    }
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception('Unexpected response payload.');
  }

  Future<JsonMap> fetchBootstrap() => _get('/bootstrap');
  Future<JsonMap> fetchHealth() => _get('/health');
  Future<JsonMap> fetchSession() => _get('/session');

  Future<JsonMap> login(String email, String password) async {
    final response = await _post('/auth/login', {
      'email': email,
      'password': password,
    });
    await _applyAuthResponse(response);
    return response;
  }

  Future<JsonMap> register(
    String fullName,
    String email,
    String password,
  ) async {
    final response = await _post('/auth/register', {
      'fullName': fullName,
      'email': email,
      'password': password,
    });
    await _applyAuthResponse(response);
    return response;
  }

  Future<JsonMap> socialLogin(String provider) =>
      _post('/auth/${provider.toLowerCase()}', {});
  Future<JsonMap> fetchDashboard() => _get('/dashboard');
  Future<JsonMap> fetchWatchlist() => _get('/watchlist');
  Future<JsonMap> addWatchlistAsset(String symbol, String name, double price) =>
      _post('/watchlist', {'symbol': symbol, 'name': name, 'price': price});
  Future<JsonMap> fetchSymbols(String query) =>
      _get('/symbols?query=${Uri.encodeQueryComponent(query)}');
  Future<JsonMap> fetchAnalytics() => _get('/market/analytics');
  Future<JsonMap> fetchPrediction(String symbol) =>
      _get('/predictions/${symbol.toUpperCase()}');
  Future<JsonMap> fetchStockDetails(String symbol) =>
      _get('/stocks/${symbol.toUpperCase()}');
  Future<JsonMap> createTrade(String symbol, String side, double amount) =>
      _post('/trade', {'symbol': symbol, 'side': side, 'amount': amount});
  Future<JsonMap> fetchNotifications() => _get('/notifications');
  Future<JsonMap> fetchProfile() => _get('/profile');
  Future<JsonMap> fetchSettings() => _get('/settings');
  Future<JsonMap> updateSetting(
    String sectionTitle,
    String itemLabel,
    dynamic value,
  ) => _patch('/settings', {
    'sectionTitle': sectionTitle,
    'itemLabel': itemLabel,
    'value': value,
  });
  Future<JsonMap> fetchAdmin() => _get('/admin');
}
