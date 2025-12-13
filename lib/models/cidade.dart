class Cidade {
  final int id;
  final String nome;
  final String uf;

  Cidade({
    required this.id,
    required this.nome,
    required this.uf,
  });

  // Método para converter JSON para objeto Cidade
  factory Cidade.fromJson(Map<String, dynamic> json) {
    return Cidade(
      id: json["id"],
      nome: json["nome"],
      uf: json["uf"],
    );
  }

  // Método para converter objeto para JSON (se necessário)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nome": nome,
      "uf": uf,
    };
  }

   @override
  String toString() => nome;
}
