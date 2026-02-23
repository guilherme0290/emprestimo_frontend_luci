import 'package:emprestimos_app/widgets/enviar_whatsapp_widget.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:emprestimos_app/core/theme/theme.dart';

void showEditMessageDialog({
  required BuildContext context,
  required TextEditingController mensagemController,
  required String telefoneCliente,
  VoidCallback? onOpenModelosMensagens,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;
      return AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 🔹 Borda mais suave
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔹 **Título do Popup**
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Editar mensagem",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (onOpenModelosMensagens != null) ...[
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        onOpenModelosMensagens();
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Ink(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Modelos de mensagens',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Escolha outro modelo pronto.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          Colors.black.withValues(alpha: 0.62),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                /// 🔹 **Campo de Edição de Texto**
                TextField(
                  controller: mensagemController,
                  minLines: 5,
                  maxLines: 10,
                  scrollPadding: const EdgeInsets.only(bottom: 120),
                  decoration: InputDecoration(
                    hintText: "Edite a mensagem antes de enviar...",
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppTheme.primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),

                const SizedBox(height: 16),

                /// 🔹 **Botões de Ação**
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.secondaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);

                        // Pegar o texto editado e formatar para URL
                        String mensagemFinal =
                            Uri.encodeComponent(mensagemController.text);

                        // URL para abrir no app do WhatsApp
                        // String whatsappDeepLink =
                        //     "whatsapp://send?phone=$telefoneCliente&text=$mensagemFinal";

                        // URL de fallback para abrir no navegador se o app não estiver instalado
                        String whatsappWebLink =
                            "https://wa.me/$telefoneCliente?text=$mensagemFinal";

                        // if (await canLaunchUrlString(whatsappDeepLink)) {
                        //   await launchUrlString(whatsappDeepLink);

                        //if (await launchUrl(whatsappWebLink, mode: LaunchMode.externalApplication)) {
                        if (await launchUrlString(whatsappWebLink,
                            mode: LaunchMode.externalApplication)) {
                        } else {
                          debugPrint("❌ Não foi possível abrir o WhatsApp.");
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
                      },
                      icon: const Icon(Icons.send, size: 20),
                      label: const Text(
                        "Enviar",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
