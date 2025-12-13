import 'package:emprestimos_app/models/login_response.dart';
import 'package:flutter/material.dart';
import '../models/usuario.dart';
import 'auth_provider.dart';

class UsuarioProvider with ChangeNotifier {
  Usuario? _usuario;
  LoginResponse? _loginResponse;

  Usuario? get usuario => _usuario;
  LoginResponse? get loginResponse => _loginResponse;

  void atualizarUsuario(AuthProvider authProvider) {
    if (authProvider.loginResponse != null) {
      _loginResponse = authProvider.loginResponse;
      _usuario = authProvider.loginResponse!.usuario;
      notifyListeners();
    }
  }
}
