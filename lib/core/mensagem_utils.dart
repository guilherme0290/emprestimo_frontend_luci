import 'package:emprestimos_app/core/api.dart';
import 'package:emprestimos_app/core/mensagem_tags.dart';
import 'package:flutter/material.dart';

class MensagemUtils {
  static String limparTelefone(String telefone) {
    return telefone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String obterSaudacao() {
    final hora = DateTime.now().hour;
    if (hora < 12) return "Bom dia";
    if (hora < 18) return "Boa tarde";
    return "Boa noite";
  }

  static String aplicarTags(String template, Map<String, String> tags) {
    String resultado = MensagemTags.normalizarTemplate(template);
    tags.forEach((key, value) {
      resultado = resultado.replaceAll("{{${key}}}", value);
    });
    return resultado;
  }

  static Future<void> enviarMensagemTeste(
      BuildContext context, String telefone, String texto) async {
    final telefoneLimpo = limparTelefone(telefone);
    if (telefoneLimpo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informe um telefone válido.")),
      );
      return;
    }
    try {
      await Api.loadAuthToken();
      await Api.dio.post(
        "/whatsapp/mensagem/$telefoneLimpo",
        queryParameters: {"texto": texto},
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mensagem de teste enviada."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao enviar teste: $e")),
      );
    }
  }
}
