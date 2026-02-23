import 'dart:async';

import 'package:emprestimos_app/core/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';

class CompraProvider with ChangeNotifier {
  final InAppPurchase? _inAppPurchase = kIsWeb ? null : InAppPurchase.instance;

  bool _assinaturaProcessando = false;

  bool get assinaturaProcessando => _assinaturaProcessando;

  EmpresaProvider? _empresaProvider;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  bool _assinaturaVinculadaComSucesso = false;
  bool get assinaturaVinculadaComSucesso => _assinaturaVinculadaComSucesso;

  void marcarAssinaturaComoConcluida() {
    _assinaturaVinculadaComSucesso = true;
    notifyListeners();
  }

  void limparStatus() {
    _assinaturaVinculadaComSucesso = false;
  }

  void setEmpresaProvider(EmpresaProvider provider) {
    _empresaProvider = provider;
  }

  CompraProvider() {
    _init();
  }

  void _init() {
    if (!kIsWeb) {
      _purchaseSub = _inAppPurchase?.purchaseStream.listen((purchases) {
        debugPrint(
            "🎧 Recebido do purchaseStream: ${purchases.length} compras");
        _handlePurchaseUpdates(purchases);
      }, onDone: () {
        debugPrint("🛑 Fim da stream de compras");
      }, onError: (error) {
        debugPrint("❌ Erro no fluxo de compras: $error");
      });
    }
  }

  // Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
  //   for (final p in purchases) {
  //     debugPrint(
  //         "🔄 Produto: ${p.productID}, status: ${p.status}, token: ${p.verificationData.serverVerificationData}");
  //     if (p.status == PurchaseStatus.purchased && p.pendingCompletePurchase) {
  //       final token = p.verificationData.serverVerificationData;
  //       final produtoId = p.productID;

  //       debugPrint("📥 Assinatura confirmada: $produtoId, token: $token");

  //       final empresaId = await StorageService.getEmpresaTemporariaId();

  //       if (empresaId == null) {
  //         debugPrint(
  //             "⚠️ Empresa temporária não definida. Não foi possível vincular assinatura.");
  //         return;
  //       }

  //       _assinaturaProcessando = true;
  //       notifyListeners();

  //       final sucesso = await _empresaProvider.vincularAssinaturasGooglePlay(
  //         empresaId: empresaId,
  //         planoToken: token,
  //       );
  //       if (sucesso) {
  //         marcarAssinaturaComoConcluida();
  //         debugPrint("✅ Token vinculado com sucesso à empresa ID $empresaId");
  //       } else {
  //         debugPrint("❌ Falha ao vincular token à empresa");
  //       }

  //       await _inAppPurchase?.completePurchase(p);

  //       _assinaturaProcessando = false;
  //       notifyListeners();
  //     }
  //   }
  // }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      debugPrint(
          "🔄 Produto: ${p.productID}, status: ${p.status}, token: ${p.verificationData.serverVerificationData}");
      if (p.status == PurchaseStatus.error) {
        debugPrint("❌ Erro na compra: ${p.error}");
        continue;
      }

      if (p.status == PurchaseStatus.pending) {
        debugPrint("⏳ Compra pendente: ${p.productID}");
        continue;
      }

      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        if (p.pendingCompletePurchase) {
          final token = p.verificationData
              .serverVerificationData; // não faça debugPrint disso
          final produtoId = p.productID;

          final empresaId = await StorageService.getEmpresaTemporariaId();
          if (empresaId == null) {
            await _inAppPurchase?.completePurchase(p);
            continue;
          }

          if (_empresaProvider == null) {
            debugPrint(
                "⚠️ EmpresaProvider ainda não configurado. Assinatura não vinculada neste momento.");
            await _inAppPurchase?.completePurchase(p);
            continue;
          }

          _assinaturaProcessando = true;
          notifyListeners();

          final sucesso = await _empresaProvider!.vincularAssinaturasGooglePlay(
            empresaId: empresaId,
            planoToken: token,
          );

          await _inAppPurchase?.completePurchase(p);
          _assinaturaProcessando = false;

          if (sucesso) {
            marcarAssinaturaComoConcluida();
            debugPrint("✅ Token vinculado com sucesso à empresa ID $empresaId");
          } else {
            debugPrint("❌ Falha ao vincular token à empresa");
          }
          notifyListeners();
        }
      }
    }
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }
}
