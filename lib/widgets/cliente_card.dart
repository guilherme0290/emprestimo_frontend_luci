import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import '../../models/cliente.dart';
import '../../screens/clientes/cliente_create_screen.dart';

class ClienteCard extends StatelessWidget {
  final Cliente cliente;

  const ClienteCard({Key? key, required this.cliente}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Cabeçalho: Nome + Ícone
            Row(
              children: [
                Expanded(
                  child: Text(
                    cliente.nome ?? "Cliente Sem Nome",
                    style: AppTheme.titleStyle.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    overflow: TextOverflow.ellipsis, // 🔹 Evita overflow
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 28),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 🔹 Informações: Email & Telefone
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child:
                        _buildInfoItem(Icons.email, "E-mail", cliente.email)),
                Expanded(
                    child: _buildInfoItem(
                        Icons.phone, "Telefone", cliente.telefone)),
              ],
            ),

            const SizedBox(height: 12),

            // 🔹 Endereço + Botões
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cliente.bairro ?? "Endereço não informado",
                          style: const TextStyle(color: Colors.white70),
                          overflow: TextOverflow.ellipsis, // 🔹 Evita overflow
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔹 Botão: Abrir no Google Maps
                IconButton(
                  icon: const Icon(Icons.map, color: Colors.white),
                  onPressed: () => _abrirNoGoogleMaps(cliente),
                ),

                // 🔹 Botão: Editar Cliente
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClienteFormScreen(cliente: cliente),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text("Editar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Método auxiliar para exibir informações com ícone
  Widget _buildInfoItem(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                value ?? "Não informado",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis, // 🔹 Evita overflow
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🔹 Método para abrir o Google Maps com o endereço do cliente
  void _abrirNoGoogleMaps(Cliente cliente) async {
    if (cliente.bairro == null) {
      return;
    }

    final String enderecoFormatado = Uri.encodeComponent(cliente.bairro!);
    final String url =
        "https://www.google.com/maps/search/?api=1&query=$enderecoFormatado";

    // if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   debugPrint("Não foi possível abrir o Google Maps.");
    // }
  }
}
