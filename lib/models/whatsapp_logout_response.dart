class WhatsappLogoutResponseDTO {
  final String status;
  final bool error;
  final ResponseDTO response;

  WhatsappLogoutResponseDTO({
    required this.status,
    required this.error,
    required this.response,
  });

  factory WhatsappLogoutResponseDTO.fromJson(Map<String, dynamic> json) {
    return WhatsappLogoutResponseDTO(
      status: json['status'],
      error: json['error'],
      response: ResponseDTO.fromJson(json['response']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'error': error,
      'response': response.toJson(),
    };
  }
}

class ResponseDTO {
  final String message;

  ResponseDTO({required this.message});

  factory ResponseDTO.fromJson(Map<String, dynamic> json) {
    return ResponseDTO(
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}
