import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../config/constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  late SharedPreferences _preferences;

  UserModel? _user;
  String? _authToken;
  bool _isLoading = false;
  String? _error;
  bool _isNewUser = false;

  // Getters
  UserModel? get user => _user;
  String? get authToken => _authToken;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authToken != null && _user != null;
  bool get isNewUser => _isNewUser;

  AuthProvider() {
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    _preferences = await SharedPreferences.getInstance();
    _loadStoredData();
  }

  void _loadStoredData() {
    _authToken = _preferences.getString('auth_token');
    final userJson = _preferences.getString('user_data');
    if (userJson != null) {
      // TODO: Parse user JSON and set _user
    }
  }

Future<void> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Create user with Firebase
      print('DEBUG: Starting signup...');
      print('DEBUG: API Base URL: ${ApiConfig.baseUrl}');
      final userCredential = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      print('DEBUG: User created successfully: ${userCredential.user?.uid}');

      if (userCredential.user == null) {
        _setError('Failed to create user');
        _setLoading(false);
        return;
      }

      // Update Firebase display name
      await _authService.updateDisplayName(fullName);
      print('DEBUG: Display name updated: $fullName');

      // Get ID token
      print('DEBUG: Getting ID token...');
      final idToken = await _authService.getIdToken();
      print('DEBUG: Got ID token: $idToken');

      if (idToken == null) {
        _setError('Failed to get ID token');
        _setLoading(false);
        return;
      }

      // Register with backend
      final response = await _apiService.post('/auth/verify-token', {
        'idToken': idToken,
        'fullName': fullName,
      });

      if (response['success']) {
        _authToken = response['token'];
        _user = UserModel.fromJson(response['user']);
        print('DEBUG SIGNUP: User created - ${_user?.fullName}');

        await _preferences.setString('auth_token', _authToken!);
        await _preferences.setString('user_data', response['user'].toString());
        _isNewUser = true;

        _setLoading(false);
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Sign in with Firebase
      print('DEBUG: Starting login...');
      print('DEBUG: API Base URL: ${ApiConfig.baseUrl}');
      final userCredential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      print('DEBUG: User signed in: ${userCredential.user?.uid}');

      if (userCredential.user == null) {
        _setError('Falha ao fazer login');
        _setLoading(false);
        return;
      }

      // Get ID token
      print('DEBUG: Getting ID token...');
      final idToken = await _authService.getIdToken();
      print('DEBUG: Got ID token: $idToken');

      if (idToken == null) {
        _setError('Falha ao obter token');
        _setLoading(false);
        return;
      }

      // Verify token with backend
      final response = await _apiService.post('/auth/verify-token', {
        'idToken': idToken,
      });

      if (response['success']) {
        _authToken = response['token'];
        _user = UserModel.fromJson(response['user']);
        _isNewUser = false;

        await _preferences.setString('auth_token', _authToken!);
        await _preferences.setString('user_data', response['user'].toString());

        _setLoading(false);
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.put(
        '/auth/profile',
        {
          'full_name': fullName,
          'phone': phone,
        },
        token: _authToken,
      );

      if (response['success']) {
        _user = UserModel.fromJson(response['user']);
        _setLoading(false);
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  void updateUserFromResponse(Map<String, dynamic> userData) {
    _user = UserModel.fromJson(userData);
    notifyListeners();
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _authToken = null;
      _user = null;
      _isNewUser = false;
      await _preferences.remove('auth_token');
      await _preferences.remove('user_data');
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String error) {
    _error = error;
  }

  void _clearError() {
    _error = null;
  }
}
