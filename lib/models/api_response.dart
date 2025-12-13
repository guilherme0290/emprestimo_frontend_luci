class ApiResponse<T> {
  final bool sucesso;
  final String message;
  final T? data;

  ApiResponse({required this.sucesso, required this.message, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      sucesso: json['sucesso'],
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}
