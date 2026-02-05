class WhatsappCodigoConexao {
  final String code;
  final String? error;
  final String? base64;

  WhatsappCodigoConexao({
    required this.code,
    this.error,
    this.base64,
  });

  factory WhatsappCodigoConexao.fromJson(Map<String, dynamic> json) {
    return WhatsappCodigoConexao(
      code: (json['pairingCode'] ?? json['code'] ?? '').toString(),
      error: json['error'],
      base64: json['base64'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'error': error,
      'base64': base64,
    };
  }
}
