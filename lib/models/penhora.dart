class PenhoraDTO {
  final int? id;
  final String descricao;
  final double valorEstimado;
  final DateTime? dataExecucaoPenhora;
  final String? status;
  final DateTime? createdAt;

  PenhoraDTO({
    this.id,
    required this.descricao,
    required this.valorEstimado,
    this.dataExecucaoPenhora,
    this.status,
    this.createdAt,
  });

  factory PenhoraDTO.fromJson(Map<String, dynamic> json) {
    return PenhoraDTO(
      id: json['id'] as int?,
      descricao: json['descricao'] as String,
      valorEstimado: (json['valorEstimado'] as num).toDouble(),
      dataExecucaoPenhora: json['dataExecucaoPenhora'] != null
          ? DateTime.tryParse(json['dataExecucaoPenhora'])
          : null,
      status: json['status'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'valorEstimado': valorEstimado,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
