import 'package:emprestimos_app/models/notificacao.dart';
import 'package:flutter/material.dart';
import '../core/api.dart';
import '../providers/auth_provider.dart';

class NotificacaoProvider with ChangeNotifier {
  AuthProvider _authProvider;

  NotificacaoProvider(this._authProvider);

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  List<Notificacao> _notificacoes = [];
  int _page = 0;
  final int _pageSize = 20;
  bool _hasMore = true;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  List<Notificacao> get notificacoes => _notificacoes;

  int get notificacoesNaoVisualizadas =>
      _notificacoes.where((n) => !n.visualizado).length;

  Future<void> buscarNotificacoes({bool reset = false}) async {
    if (reset) {
      _page = 0;
      _hasMore = true;
      _notificacoes = [];
    }

    if (!_hasMore) {
      return;
    }

    if (_page == 0) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Api.dio.get(
        "/notificacoes",
        queryParameters: {"page": _page, "size": _pageSize},
      );

      final data = response.data;
      if (data is Map && data["content"] is List) {
        final novas = (data["content"] as List)
            .map((json) => Notificacao.fromJson(json))
            .toList();
        _notificacoes.addAll(novas);
        _notificacoes.sort((a, b) {
          final da = a.dataEnvio ?? DateTime.fromMillisecondsSinceEpoch(0);
          final db = b.dataEnvio ?? DateTime.fromMillisecondsSinceEpoch(0);
          return db.compareTo(da);
        });
        _hasMore = data["last"] == false && novas.isNotEmpty;
        if (novas.isNotEmpty) {
          _page += 1;
        }
      } else {
        _errorMessage = "Resposta inesperada do servidor.";
      }
    } catch (e) {
      _errorMessage = "Erro ao buscar notificações.";
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> marcarComoVisualizada(int id) async {
    try {
      await Api.dio.put("/notificacoes/$id/visualizar");
      final idx = _notificacoes.indexWhere((n) => n.id == id);
      if (idx >= 0) {
        final atual = _notificacoes[idx];
        _notificacoes[idx] = Notificacao(
          id: atual.id,
          titulo: atual.titulo,
          mensagem: atual.mensagem,
          visualizado: true,
          dataEnvio: atual.dataEnvio,
          tipo: atual.tipo,
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> marcarTodasComoVisualizadas() async {
    final pendentes =
        _notificacoes.where((n) => !n.visualizado).map((n) => n.id).toList();
    if (pendentes.isEmpty) {
      return;
    }

    await Future.wait(pendentes.map(marcarComoVisualizada));
  }

  void atualizarAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
  }
}
