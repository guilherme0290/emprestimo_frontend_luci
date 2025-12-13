enum Role {
  EMPRESA,
  VENDEDOR;

  static Role fromString(String role) {
    return Role.values.firstWhere((e) => e.toString().split('.').last == role,
        orElse: () => Role.EMPRESA);
  }
}
