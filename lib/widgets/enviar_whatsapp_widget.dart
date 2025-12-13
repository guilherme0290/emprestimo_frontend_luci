import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';


String _apenasNumeros(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

Future<void> enviarWhatsapp({
    required BuildContext context,
    required String telefoneCliente,
    required String mensagem,
  }) async {
    final telefone = _apenasNumeros(telefoneCliente);
    final texto = Uri.encodeComponent(mensagem);

    // Schemes dos apps
    final uriWA = Uri.parse('whatsapp://send?phone=$telefone&text=$texto');
    final uriWAB =
        Uri.parse('whatsapp-business://send?phone=$telefone&text=$texto');

    final temWhats = await canLaunchUrl(uriWA);
    final temWhatsBusiness = await canLaunchUrl(uriWAB);

    Future<void> _abrir(Uri u) async {
      final ok = await launchUrl(u, mode: LaunchMode.externalApplication);
      if (!ok) {
        // fallback opcional para wa.me (abre navegador / escolhe app)
        final link = 'https://wa.me/$telefone?text=$texto';
        if (!await launchUrlString(link,
            mode: LaunchMode.externalApplication)) {
          // Se nada deu certo, mostra alerta
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Erro ao abrir o WhatsApp"),
                content: const Text(
                    "Não foi possível abrir o WhatsApp. Verifique se ele está instalado ou tente novamente."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }
        }
      }
    }

    if (temWhats && temWhatsBusiness) {
      // Pergunta qual app usar
      if (!context.mounted) return;
      final escolha = await showModalBottomSheet<String>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Escolha o WhatsApp para enviar a mensagem',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: const Text('WhatsApp'),
                onTap: () => Navigator.pop(ctx, 'wa'),
              ),
              ListTile(
                leading: const Icon(Icons.store_mall_directory_outlined),
                title: const Text('WhatsApp Business'),
                onTap: () => Navigator.pop(ctx, 'wab'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );

      if (escolha == 'wa') {
        await _abrir(uriWA);
      } else if (escolha == 'wab') {
        await _abrir(uriWAB);
      }
      return;
    }

    if (temWhatsBusiness) {
      await _abrir(uriWAB);
      return;
    }

    if (temWhats) {
      await _abrir(uriWA);
      return;
    }

    // Nenhum instalado → fallback/alerta já tratado dentro de _abrir via wa.me
    await _abrir(uriWA);
  }