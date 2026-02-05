class WhatsappStatusResponse {
  final bool connected;
  final bool smartphoneConnected;
  final String? error;
  final String? state;

  WhatsappStatusResponse({
    required this.connected,
    required this.smartphoneConnected,
    this.error,
    this.state,
  });

  factory WhatsappStatusResponse.fromJson(Map<String, dynamic> json) {
    String? state;
    if (json['instance'] is Map<String, dynamic>) {
      state = (json['instance'] as Map<String, dynamic>)['state'] as String?;
    } else if (json['state'] is String) {
      state = json['state'] as String?;
    }

    final connected = json['connected'] ?? (state == 'open');
    final smartphoneConnected =
        json['smartphoneConnected'] ?? (state == 'open');

    return WhatsappStatusResponse(
      connected: connected ?? false,
      smartphoneConnected: smartphoneConnected ?? false,
      error: json['error'],
      state: state,
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
