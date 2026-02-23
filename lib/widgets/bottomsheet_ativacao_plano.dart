import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:emprestimos_app/widgets/dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/models/planos.dart';

Future<void> showBottomSheetAtivacao({
  required BuildContext context,
  Plano? plano,
  Future<Plano?> Function()? buscarPlanoSelecionado,
}) async {
  final Plano? planoSelecionado = plano ??
      (buscarPlanoSelecionado != null ? await buscarPlanoSelecionado() : null);

  if (planoSelecionado == null ||
      (planoSelecionado.productIdGooglePlay?.trim().isEmpty ?? true)) {
    // Pode mostrar um alerta de erro aqui se quiser
    return;
  }

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Ativação de Plano",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Para concluir o cadastro da sua empresa, é necessário ativar sua assinatura na Google Play.",
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  if (kIsWeb) return;
                  final billing = InAppPurchase.instance;
                  final disponivel = await billing.isAvailable();
                  if (!disponivel) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Google Play indisponível no momento.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final productId = planoSelecionado!.productIdGooglePlay!.trim();
                  final response =
                      await billing.queryProductDetails({productId});

                  if (response.error != null ||
                      response.productDetails.isEmpty ||
                      response.notFoundIDs.isNotEmpty) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Produto da assinatura não encontrado na Play Store (${response.notFoundIDs.join(', ')}).',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final produto = response.productDetails.first;
                  final param = PurchaseParam(productDetails: produto);
                  await billing.buyNonConsumable(purchaseParam: param);

                  if (!context.mounted) return;
                  Navigator.pop(context);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao iniciar assinatura: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              // onPressed: () async {
              //   final productId = planoSelecionado!.productIdGooglePlay;
              //   final response = await InAppPurchase.instance
              //       .queryProductDetails({productId!});
              //   final produto = response.productDetails.first;

              //   final param = PurchaseParam(productDetails: produto);
              //   await InAppPurchase.instance
              //       .buyNonConsumable(purchaseParam: param);

              //   Navigator.pop(context);
              // },
              icon: const Icon(Icons.play_circle_fill),
              label: const Text("Ativar assinatura"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      );
    },
  );
}
