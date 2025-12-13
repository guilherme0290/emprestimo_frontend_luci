import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:emprestimos_app/widgets/dialog_widget.dart';
import 'package:flutter/material.dart';
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
      planoSelecionado.productIdGooglePlay == null) {
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
                  // evita toque duplo
                  if (context.mounted) FocusScope.of(context).unfocus();

                  // 1) Verifica se a Play Store está disponível
                  final isAvailable =
                      await InAppPurchase.instance.isAvailable();
                  if (!isAvailable) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              "Play Store não disponivel no momento, tente novamente mais tarde.")),
                    );
                    return;
                  }

                  // 2) Busca detalhes do produto
                  final productId = planoSelecionado!.productIdGooglePlay!;
                  final response = await InAppPurchase.instance
                      .queryProductDetails({productId});

                  if (response.error != null ||
                      response.productDetails.isEmpty) {
                    // trate: produto não encontrado / erro de billing
                    return;
                  }

                  final produto = response.productDetails.first;

                  // 3) Dispara compra com PurchaseParam simples (sem payloads grandes)
                  final param = PurchaseParam(productDetails: produto);
                  final ok = await InAppPurchase.instance
                      .buyNonConsumable(purchaseParam: param);

                  // Só fecha o bottom sheet se a chamada foi aceita pelo BillingClient
                  if (ok && context.mounted) Navigator.pop(context);
                } catch (e) {
                  debugPrint("❌ Erro inesperado no fluxo de compra: $e");
                  debugPrint(e.toString());

                  MyAwesomeDialog(
                    dialogType: DialogType.error,
                    context: context,
                    btnCancelText: 'Ok',
                    title: "Ops, algo deu errado!",
                    message:
                        "Ocorreu um erro inesperado durante a tentativa de compra. "
                        "Tente novamente em alguns instantes.",
                  ).show();
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
