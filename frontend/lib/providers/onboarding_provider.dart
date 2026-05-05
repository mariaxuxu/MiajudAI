import 'package:flutter/material.dart';
import '../models/onboarding_model.dart';

class OnboardingProvider extends ChangeNotifier {
  int _currentStep = 0;
  bool _isLoading = false;
  String? _error;

  // Step 1: Basic Info
  String _nomeUsuario = '';
  String _telefoneUsuario = '';
  String _idade = '';
  String _endereco = '';

  // Step 2: Security & Preferences
  String _cpfRg = '';
  String? _contatoEmergNome;
  String? _contatoEmergTel;
  String? _preferenciadieta;

  // Getters
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isStep1Complete =>
      _nomeUsuario.isNotEmpty &&
      _telefoneUsuario.isNotEmpty &&
      _idade.isNotEmpty &&
      _endereco.isNotEmpty;
  bool get isStep2Complete => _cpfRg.isNotEmpty;

  // Setters for Step 1
  void setNomeUsuario(String value) {
    _nomeUsuario = value;
    notifyListeners();
  }

  void setTelefoneUsuario(String value) {
    _telefoneUsuario = value;
    notifyListeners();
  }

  void setIdade(String value) {
    _idade = value;
    notifyListeners();
  }

  void setEndereco(String value) {
    _endereco = value;
    notifyListeners();
  }

  // Setters for Step 2
  void setCpfRg(String value) {
    _cpfRg = value;
    notifyListeners();
  }

  void setContatoEmergNome(String? value) {
    _contatoEmergNome = value;
    notifyListeners();
  }

  void setContatoEmergTel(String? value) {
    _contatoEmergTel = value;
    notifyListeners();
  }

  void setPreferenciadieta(String? value) {
    _preferenciadieta = value;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 1) {
      _currentStep++;
      _error = null;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _error = null;
      notifyListeners();
    }
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  OnboardingData getOnboardingData() {
    return OnboardingData(
      nomeUsuario: _nomeUsuario,
      telefoneUsuario: _telefoneUsuario,
      idade: _idade,
      endereco: _endereco,
      cpfRg: _cpfRg,
      contatoEmergNome: _contatoEmergNome,
      contatoEmergTel: _contatoEmergTel,
      preferenciadieta: _preferenciadieta,
    );
  }

  void reset() {
    _currentStep = 0;
    _isLoading = false;
    _error = null;
    _nomeUsuario = '';
    _telefoneUsuario = '';
    _idade = '';
    _endereco = '';
    _cpfRg = '';
    _contatoEmergNome = null;
    _contatoEmergTel = null;
    _preferenciadieta = null;
    notifyListeners();
  }
}
