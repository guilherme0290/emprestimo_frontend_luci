import 'package:emprestimos_app/models/planos.dart';
import 'package:emprestimos_app/models/usuario.dart';

class LoginResponse {
  final String token;
  final String role;
  final Usuario usuario;
  final Plano? plano;

  LoginResponse({
    required this.token,
    required this.role,
    required this.usuario,
    this.plano,
  });
  

   factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json["token"] ?? "",
      role: json["role"] ?? "",
      usuario: Usuario.fromJson(json["usuario"]),
      plano: json["plano"] != null ? Plano.fromJson(json["plano"]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "token": token,
      "role": role,
      "usuario": usuario.toJson(),
    };
  }
}
