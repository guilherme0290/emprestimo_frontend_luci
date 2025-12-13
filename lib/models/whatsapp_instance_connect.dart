class WhatsappInstanceConnect {
  final String pairingCode;
  final String code;
  final int count;
  final String base64;

  WhatsappInstanceConnect({
    required this.pairingCode,
    required this.code,
    required this.count,
    required this.base64,
  });

  factory WhatsappInstanceConnect.fromJson(Map<String, dynamic> json) {
    return WhatsappInstanceConnect(
      pairingCode: json['pairingCode'],
      code: json['code'],
      count: json['count'],
      base64: json['base64'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pairingCode': pairingCode,
      'code': code,
      'count': count,
      'base64': base64,
    };
  }
}
