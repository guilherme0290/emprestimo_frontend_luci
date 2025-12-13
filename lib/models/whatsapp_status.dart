class WhatsappStatusResponse {
  final bool connected;
  final bool smartphoneConnected;
  final String? error;

  WhatsappStatusResponse({
    required this.connected,
    required this.smartphoneConnected,
    this.error,
  });

  factory WhatsappStatusResponse.fromJson(Map<String, dynamic> json) {
    return WhatsappStatusResponse(
      connected: json['connected'] ?? false,
      smartphoneConnected: json['smartphoneConnected'] ?? false,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'connected': connected,
      'smartphoneConnected': smartphoneConnected,
      'error': error,
    };
  }
}
