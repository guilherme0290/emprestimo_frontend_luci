import 'package:dio/dio.dart';
import 'package:emprestimos_app/core/api.dart';
import 'package:emprestimos_app/core/dio_error_handler.dart';
import 'package:emprestimos_app/models/api_response.dart';
import 'package:emprestimos_app/models/mensagem_manual.dart';
import 'package:emprestimos_app/models/mensagem_manual_template.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';

class MensagensManuaisProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  List<MensagemManual> _mensagens = [];

  MensagensManuaisProvider(AuthProvider _);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<MensagemManual> get mensagens => _mensagens;

  static const List<MensagemManualTemplate> _templatesCobrancaFallback = [
    MensagemManualTemplate(
      id: 'cobranca_1',
      tipo: TipoMensagemManual.cobrancaAtraso,
      titulo: 'Cobrança amigável',
      conteudo:
          'Olá {{nome}},\n\nPassando para lembrar que a parcela nº {{numero_parcela}} no valor de {{valor_parcela}} venceu em {{vencimento}}.\n\nSe já pagou, desconsidere. Qualquer dúvida estou à disposição.',
    ),
    MensagemManualTemplate(
      id: 'cobranca_2',
      tipo: TipoMensagemManual.cobrancaAtraso,
      titulo: 'Cobrança objetiva',
      conteudo:
          '{{saudacao}}, {{nome}}. A parcela nº {{numero_parcela}} no valor de {{valor_parcela}} venceu em {{vencimento}}. Por favor, confirme o pagamento.',
    ),
    MensagemManualTemplate(
      id: 'cobranca_3',
      tipo: TipoMensagemManual.cobrancaAtraso,
      titulo: 'Lembrete com saldo',
      conteudo:
          'Olá {{nome}},\n\nIdentificamos parcela em atraso ({{numero_parcela}}) no valor de {{valor_parcela}}.\nSaldo atual: {{saldo_devedor}}.\n\nPrecisando negociar, nos chame.',
    ),
    MensagemManualTemplate(
      id: 'cobranca_4',
      tipo: TipoMensagemManual.cobrancaAtraso,
      titulo: 'Cobrança formal',
      conteudo:
          'Prezado(a) {{nome}},\n\nConsta pendência referente à parcela nº {{numero_parcela}}, valor {{valor_parcela}}, vencimento em {{vencimento}}.\nSolicitamos regularização.',
    ),
    MensagemManualTemplate(
      id: 'cobranca_5',
      tipo: TipoMensagemManual.cobrancaAtraso,
      titulo: 'Cobrança curta',
      conteudo:
          'Olá {{primeiro_nome}}, parcela {{numero_parcela}} ({{valor_parcela}}) venceu em {{vencimento}}. Pode confirmar o pagamento?',
    ),
    MensagemManualTemplate(
      id: 'cobranca_6',
      tipo: TipoMensagemManual.cobrancaAtraso,
      titulo: 'Cobrança com resumo do contrato',
      conteudo:
          '{{saudacao}}, {{nome}}.\n\nContrato #{{contrato_id}} | Parcela {{progresso_parcela}}\nValor da parcela: {{valor_parcela}}\nVencimento: {{vencimento_extenso}}\nSaldo devedor atual: {{saldo_devedor}}\n\nNos avise sobre o pagamento para mantermos seu cadastro em dia.',
    ),
    MensagemManualTemplate(
      id: 'cobranca_7',
      tipo: TipoMensagemManual.cobrancaAtraso,
      titulo: 'Cobrança com cobrador identificado',
      conteudo:
          'Olá {{nome}}, aqui é {{cobrador}} da {{empresa}}.\n\nEstamos entrando em contato sobre a parcela {{numero_parcela}} no valor de {{valor_parcela}}, vencida em {{vencimento}}.\n\nSe precisar de apoio para regularizar, responda esta mensagem.',
    ),
    MensagemManualTemplate(
      id: 'cobranca_8',
      tipo: TipoMensagemManual.cobrancaAtraso,
      titulo: 'Cobrança para múltiplos atrasos',
      conteudo:
          'Olá {{nome}}.\n\nIdentificamos {{parcelas_em_atraso}} parcela(s) em atraso.\nSaldo em atraso: {{saldo_em_atraso}}\nSaldo total devedor: {{saldo_devedor}}\n\nPodemos combinar a melhor forma para regularização.',
    ),
    MensagemManualTemplate(
      id: 'cobranca_9',
      tipo: TipoMensagemManual.cobrancaAtraso,
      titulo: 'Cobrança com tom de urgência',
      conteudo:
          'Prezado(a) {{nome}},\n\nA parcela nº {{numero_parcela}} no valor de {{valor_parcela}} está em atraso desde {{vencimento}}.\nSaldo em aberto no contrato: {{saldo_devedor}}.\n\nSolicitamos retorno imediato para evitar bloqueios de crédito.',
    ),
    MensagemManualTemplate(
      id: 'cobranca_10',
      tipo: TipoMensagemManual.cobrancaAtraso,
      titulo: 'Cobrança com histórico de pagamento',
      conteudo:
          '{{saudacao}}, {{primeiro_nome}}.\n\nJá registramos {{total_pago}} pagos no seu contrato.\nNo momento, a parcela {{numero_parcela}} de {{valor_parcela}} está pendente (vencimento {{vencimento}}).\nSaldo devedor: {{saldo_devedor}}.\n\nConte conosco para finalizar essa regularização.',
    ),
  ];

  static const List<MensagemManualTemplate> _templatesBaixaFallback = [
    MensagemManualTemplate(
      id: 'baixa_1',
      tipo: TipoMensagemManual.baixaParcela,
      titulo: 'Confirmação amigável',
      conteudo:
          'Olá {{nome}},\n\nRecebemos o pagamento da parcela nº {{numero_parcela}} no valor de {{valor_pago}} em {{data_pagamento}}.\n\nObrigado!',
    ),
    MensagemManualTemplate(
      id: 'baixa_2',
      tipo: TipoMensagemManual.baixaParcela,
      titulo: 'Confirmação objetiva',
      conteudo:
          'Pagamento confirmado.\nParcela: {{numero_parcela}}\nValor pago: {{valor_pago}}\nData: {{data_pagamento}}',
    ),
    MensagemManualTemplate(
      id: 'baixa_3',
      tipo: TipoMensagemManual.baixaParcela,
      titulo: 'Baixa com saldo',
      conteudo:
          'Olá {{nome}}, registramos o pagamento da parcela {{numero_parcela}}.\nValor pago: {{valor_pago}}.\nSaldo da parcela: {{saldo_parcela}}.',
    ),
    MensagemManualTemplate(
      id: 'baixa_4',
      tipo: TipoMensagemManual.baixaParcela,
      titulo: 'Agradecimento',
      conteudo:
          '{{saudacao}}, {{nome}}!\nSeu pagamento da parcela {{numero_parcela}} foi registrado com sucesso.\nObrigado pela pontualidade.',
    ),
    MensagemManualTemplate(
      id: 'baixa_5',
      tipo: TipoMensagemManual.baixaParcela,
      titulo: 'Com total pago',
      conteudo:
          'Olá {{nome}},\nRecebemos {{valor_pago}} referente à parcela {{numero_parcela}}.\nTotal pago no contrato: {{total_pago}}.',
    ),
    MensagemManualTemplate(
      id: 'baixa_6',
      tipo: TipoMensagemManual.baixaParcela,
      titulo: 'Baixa com status do contrato',
      conteudo:
          '{{saudacao}}, {{nome}}.\n\nPagamento da parcela {{numero_parcela}} confirmado.\nValor pago: {{valor_pago}}\nData: {{data_pagamento}}\nSaldo devedor atualizado: {{saldo_devedor}}\n\nObrigado por manter seu contrato em dia.',
    ),
    MensagemManualTemplate(
      id: 'baixa_7',
      tipo: TipoMensagemManual.baixaParcela,
      titulo: 'Baixa parcial detalhada',
      conteudo:
          'Olá {{nome}}, registramos uma baixa na parcela {{numero_parcela}}.\nValor pago: {{valor_pago}}\nSaldo restante da parcela: {{saldo_parcela}}\nSaldo total do contrato: {{saldo_devedor}}\n\nSe desejar, enviamos o detalhamento completo.',
    ),
    MensagemManualTemplate(
      id: 'baixa_8',
      tipo: TipoMensagemManual.baixaParcela,
      titulo: 'Confirmação com progresso',
      conteudo:
          'Pagamento confirmado com sucesso.\nCliente: {{nome}}\nParcela: {{progresso_parcela}}\nValor pago: {{valor_pago}}\nData/hora: {{data_pagamento}}\n\nEquipe {{empresa}} agradece.',
    ),
    MensagemManualTemplate(
      id: 'baixa_9',
      tipo: TipoMensagemManual.baixaParcela,
      titulo: 'Baixa institucional',
      conteudo:
          'Prezado(a) {{nome}},\n\nInformamos que o pagamento da parcela {{numero_parcela}} ({{valor_parcela}}) foi registrado em {{data_pagamento}}.\nValor recebido: {{valor_pago}}\nContrato: #{{contrato_id}}\n\nAtenciosamente,\n{{empresa}}',
    ),
    MensagemManualTemplate(
      id: 'baixa_10',
      tipo: TipoMensagemManual.baixaParcela,
      titulo: 'Agradecimento com resumo financeiro',
      conteudo:
          '{{saudacao}}, {{primeiro_nome}}!\n\nRecebemos seu pagamento da parcela {{numero_parcela}}.\nValor pago agora: {{valor_pago}}\nTotal pago no contrato: {{total_pago}}\nSaldo devedor atual: {{saldo_devedor}}\n\nMuito obrigado pela confiança.',
    ),
  ];

  Future<void> buscarMensagens() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.get("/mensagens-manuais");

      final apiResponse = ApiResponse<List<MensagemManual>>.fromJson(
        response.data,
        (jsonList) => (jsonList as List)
            .map((json) => MensagemManual.fromJson(json))
            .toList(),
      );
      if (apiResponse.sucesso) {
        _mensagens = apiResponse.data ?? [];
      } else {
        _errorMessage = apiResponse.message;
      }

      notifyListeners();
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro ao buscar mensagens: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> salvarMensagens(
      List<MensagemManual> mensagensAtualizadas) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.put(
        "/mensagens-manuais",
        data: mensagensAtualizadas.map((m) => m.toJson()).toList(),
      );

      final apiResponse = ApiResponse<List<MensagemManual>>.fromJson(
        response.data,
        (jsonList) => (jsonList as List)
            .map((json) => MensagemManual.fromJson(json))
            .toList(),
      );

      if (apiResponse.sucesso) {
        _mensagens = apiResponse.data ?? [];
      } else {
        _errorMessage = apiResponse.message;
      }

      _successMessage = "Mensagens salvas com sucesso.";
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro ao salvar mensagens: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<MensagemManualTemplate>> buscarTemplatesPorTipo(
    TipoMensagemManual tipo,
  ) async {
    try {
      await Api.loadAuthToken();
      final response = await Api.dio.get(
        "/mensagens-manuais/templates",
        queryParameters: {"tipo": tipoMensagemManualToString(tipo)},
      );
      final apiResponse = ApiResponse<List<MensagemManualTemplate>>.fromJson(
        response.data,
        (jsonList) => (jsonList as List)
            .map((json) => MensagemManualTemplate.fromJson(json))
            .toList(),
      );
      if (apiResponse.sucesso && (apiResponse.data?.isNotEmpty ?? false)) {
        return _comEmojis(apiResponse.data!);
      }
    } catch (_) {
      // fallback local caso endpoint ainda não esteja disponível
    }
    return _comEmojis(_templatesFallback(tipo));
  }

  Future<void> salvarTemplatePadrao({
    required TipoMensagemManual tipo,
    required MensagemManualTemplate template,
    required bool ativo,
  }) async {
    await _salvarMensagemPorTipo(
      tipo: tipo,
      conteudo: template.conteudo,
      ativo: ativo,
      templateId: template.id,
      personalizada: false,
    );
  }

  Future<void> salvarMensagemPersonalizada({
    required TipoMensagemManual tipo,
    required String conteudo,
    required bool ativo,
    String? templateId,
  }) async {
    await _salvarMensagemPorTipo(
      tipo: tipo,
      conteudo: conteudo,
      ativo: ativo,
      templateId: templateId,
      personalizada: true,
    );
  }

  Future<void> restaurarPadrao({
    required TipoMensagemManual tipo,
    required MensagemManualTemplate template,
    required bool ativo,
  }) async {
    await salvarTemplatePadrao(tipo: tipo, template: template, ativo: ativo);
  }

  List<MensagemManualTemplate> _templatesFallback(TipoMensagemManual tipo) {
    return tipo == TipoMensagemManual.cobrancaAtraso
        ? _templatesCobrancaFallback
        : _templatesBaixaFallback;
  }

  List<MensagemManualTemplate> _comEmojis(List<MensagemManualTemplate> templates) {
    final emojisCobranca = ['📌', '⏰', '⚠️', '💬', '📣', '📅', '🔔', '📊', '🚨', '✅'];
    final emojisBaixa = ['✅', '🎉', '💰', '🙌', '📥', '🧾', '👍', '📈', '🏦', '🙏'];

    return List<MensagemManualTemplate>.generate(templates.length, (index) {
      final t = templates[index];
      final emoji = t.tipo == TipoMensagemManual.cobrancaAtraso
          ? emojisCobranca[index % emojisCobranca.length]
          : emojisBaixa[index % emojisBaixa.length];

      final titulo = _temEmoji(t.titulo) ? t.titulo : '$emoji ${t.titulo}';
      final conteudo = _temEmoji(t.conteudo)
          ? t.conteudo
          : t.tipo == TipoMensagemManual.cobrancaAtraso
              ? '$emoji ${t.conteudo}'
              : '$emoji ${t.conteudo}';

      return MensagemManualTemplate(
        id: t.id,
        tipo: t.tipo,
        titulo: titulo,
        conteudo: conteudo,
      );
    });
  }

  bool _temEmoji(String texto) {
    final emojiRegex = RegExp(
      r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]',
      unicode: true,
    );
    return emojiRegex.hasMatch(texto);
  }

  Future<void> _salvarMensagemPorTipo({
    required TipoMensagemManual tipo,
    required String conteudo,
    required bool ativo,
    String? templateId,
    bool? personalizada,
  }) async {
    if (_mensagens.isEmpty) {
      await buscarMensagens();
    }
    final atualizadas = _mensagens.map((m) => m.copyWith()).toList();
    final index = atualizadas.indexWhere((m) => m.tipo == tipo);
    final novaMensagem = MensagemManual(
      tipo: tipo,
      conteudo: conteudo,
      ativo: ativo,
      templateId: templateId,
      personalizada: personalizada,
    );
    if (index >= 0) {
      atualizadas[index] = novaMensagem;
    } else {
      atualizadas.add(novaMensagem);
    }
    await salvarMensagens(atualizadas);
  }
}
