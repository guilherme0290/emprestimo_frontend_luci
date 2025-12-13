class WhatsappCodigoConexao {
  final String code;  
  final String? error;

  WhatsappCodigoConexao({
    required this.code,   
    this.error,
  });

  factory WhatsappCodigoConexao.fromJson(Map<String, dynamic> json) {
    return WhatsappCodigoConexao(
      code: json['code'],      
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,    
      'error': error,
    };
  }
}
