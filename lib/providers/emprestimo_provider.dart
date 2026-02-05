import 'package:emprestimos_app/core/data_utils.dart';
import 'package:emprestimos_app/core/dio_error_handler.dart';
import 'package:emprestimos_app/models/agrupamento_parcelas.dart';
import 'package:emprestimos_app/models/api_response.dart';
import 'package:emprestimos_app/models/baixa-parcela.dart';
import 'package:emprestimos_app/models/baixa_parcela_result.dart';
import 'package:emprestimos_app/models/cliente_emprestimo_ativos.dart';
import 'package:emprestimos_app/models/detalhamento_parcela.dart';
import 'package:emprestimos_app/models/filtro_resumo.dart';
import 'package:emprestimos_app/models/previsao_recebimento.dart';
import 'package:emprestimos_app/models/transacoes.dart';
import 'package:emprestimos_app/models/vendedor.dart';
import 'package:emprestimos_app/models/emprestimo.dart';
import 'package:emprestimos_app/models/parcela.dart';
import 'package:emprestimos_app/models/parcela_resumo.dart';
import 'package:emprestimos_app/models/request_emprestimo.dart';
import 'package:emprestimos_app/models/resumo_vendedor.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/api.dart';

class ContasReceberProvider with ChangeNotifier {
  bool _isLoading = false;
  AuthProvider _authProvider;
  List<ParcelaResumoDTO> _parcelas = [];
  String? _errorMessage;
  ResumoTotalizadoresContasReceber? _resumoCliente;
  ResumoTotalizadoresContasReceber? _resumoVendedor;
  ResumoTotalizadoresContasReceber? _resumoEmpresa;

  List<PrevisaoRecebimento> _previsoes = [];
  List<PrevisaoRecebimento> get previsoes => _previsoes;
  List<ParcelaResumoDTO> _parcelasPrevisao = [];
  List<ParcelaResumoDTO> get parcelasPrevisao => _parcelasPrevisao;
  List<TransacaoCaixaDTO> _transacoes = [];
  List<AgrupamentoParcelaDTO> _resumoCobranca = [];

  // novo: detalhes flat para a tela de detalhamento
  FiltroResumo? _ultimoFiltro;
  List<DetalheParcelaDTO> detalhesGeral = [];

  bool esconderValores = true;

  List<ContasReceberDTO> _emprestimos = [];

  bool get isLoading => _isLoading;

  List<ParcelaResumoDTO> get parcelas => _parcelas;
  List<ContasReceberDTO> get contasreceber => _emprestimos;
  String? get errorMessage => _errorMessage;
  ResumoTotalizadoresContasReceber? get resumoVendedor => _resumoVendedor;
  ResumoTotalizadoresContasReceber? get resumoCliente => _resumoCliente;
  ResumoTotalizadoresContasReceber? get resumoEmpresa => _resumoEmpresa;
  List<AgrupamentoParcelaDTO> get resumoCobranca => _resumoCobranca;
  List<TransacaoCaixaDTO> get transacoes => _transacoes;

  ContasReceberProvider(this._authProvider);

  Future<List<ContasReceberDTO>> listarContasReceberCliente(
      int clienteId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response =
          await Api.dio.get("/contasreceber/cliente/$clienteId/resumo");
      final data = response.data as List<dynamic>;

      _emprestimos = data
          .map(
              (json) => ContasReceberDTO.fromJson(json as Map<String, dynamic>))
          .toList();

      return _emprestimos;
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao buscar contrato: $e");
      }
      _errorMessage = "Erro ao buscar contrato do cliente";
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ContasReceberDTO?> criarContasReceber(
      NovoContasReceberDTO emprestimo) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (_authProvider.loginResponse!.role == "VENDEDOR") {
      emprestimo.vendedorId = _authProvider.loginResponse!.usuario.id;
    }

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.post(
        "/contasreceber",
        data: emprestimo.toJson(),
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        if (response.statusCode! < 500) {
          _errorMessage = response.data.toString();
        } else {
          _errorMessage =
              "Ocorreu um erro inesperado. Tente novamente mais tarde.";
        }
        return null;
      }

      final newContasReceber =
          ContasReceberDTO.fromJson(response.data as Map<String, dynamic>);
      return newContasReceber;
    } on DioException catch (dioError) {
      if (dioError.response != null && dioError.response!.statusCode != null) {
        if (dioError.response!.statusCode! < 500) {
          _errorMessage = dioError.response!.data.toString();
        } else {
          _errorMessage =
              "Ocorreu um erro inesperado. Tente novamente mais tarde.";
        }
      } else {
        _errorMessage = "Erro de conexão, por favor verifique sua internet.";
      }
      return null;
    } catch (e) {
      _errorMessage = "Erro ao criar contrato do cliente";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ParcelaDTO> get cobrancasPendentes {
    return _emprestimos
        .expand((emprestimo) => emprestimo.parcelas)
        .where((parcela) =>
            parcela.status == "PENDENTE" || parcela.status == "ATRASADA")
        .toList();
  }

  ContasReceberDTO? getContasReceberByParcela(ParcelaDTO parcela) {
    for (var emprestimo in _emprestimos) {
      if (emprestimo.parcelas.any((p) => p.id == parcela.id)) {
        return emprestimo;
      }
    }
    return null;
  }

  Future<ContasReceberDTO?> buscarContasReceberPorId(
      int contasreceberId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.get("/contasreceber/$contasreceberId");

      if (response.statusCode == 200) {
        final emprestimoAtualizado = ContasReceberDTO.fromJson(response.data);
        return emprestimoAtualizado;
      } else {
        _errorMessage = "Erro ao buscar contrato: ${response.statusCode}";
        return null;
      }
    } catch (e) {
      _errorMessage = "Erro inesperado ao buscar contrato: $e";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> buscarAllContasReceber(Vendedor? vendedor) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    String path = "/contasreceber";

    if (vendedor != null) {
      path += '/vendedor/${vendedor.id}';
    }
    if (_authProvider.loginResponse!.role == "VENDEDOR") {
      path += "/vendedor/${_authProvider.loginResponse!.usuario.id}";
    }

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.get(path);

      final apiResponse = ApiResponse<List<ContasReceberDTO>>.fromJson(
        response.data,
        (data) => (data as List)
            .map((json) => ContasReceberDTO.fromJson(json))
            .toList(),
      );

      if (!apiResponse.sucesso) {
        _errorMessage = apiResponse.message;
      } else {
        _emprestimos = apiResponse.data!;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = "Erro inesperado ao buscar contas a receber: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // em ContasReceberProvider
  Future<void> buscarContasReceberPorQuery(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      String path = '/contasreceber/search';
      final params = <String, dynamic>{'q': query};

      if (_authProvider.loginResponse?.role == "VENDEDOR") {
        params['vendedorId'] = _authProvider.loginResponse!.usuario.id;
      }

      final response = await Api.dio.get(path, queryParameters: params);

      final data = response.data;
      late final List list;
      if (data is List) {
        list = data;
      } else {
        // caso venha envelopado
        final api = ApiResponse<List<dynamic>>.fromJson(
          data,
          (json) => json as List<dynamic>,
        );
        if (api.sucesso == false) {
          _errorMessage = api.message;
          _emprestimos = [];
          return;
        }
        list = api.data ?? [];
      }

      _emprestimos = list
          .map((e) => ContasReceberDTO.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _errorMessage = "Erro inesperado ao buscar contratos: $e";
      _emprestimos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ContasReceberDTO>> buscarContasReceberPorFiltro({
    required String query,
    int? vendedorId,
    int? caixaId,
  }) async {
    try {
      await Api.loadAuthToken();
      final response = await Api.dio.get(
        "/contasreceber/search",
        queryParameters: {
          "q": query,
          if (vendedorId != null) "vendedorId": vendedorId,
          if (caixaId != null) "caixaId": caixaId,
        },
      );

      final apiResponse = ApiResponse<List<ContasReceberDTO>>.fromJson(
        response.data,
        (data) => (data as List)
            .map((json) => ContasReceberDTO.fromJson(json))
            .toList(),
      );

      if (apiResponse.sucesso) {
        return apiResponse.data ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> transferirContasReceberVendedor({
    required List<int> contasReceberIds,
    required int novoVendedorId,
  }) async {
    try {
      await Api.loadAuthToken();
      final response = await Api.dio.post(
        "/contasreceber/transferencia-vendedor",
        data: {
          "contasReceberIds": contasReceberIds,
          "novoVendedorId": novoVendedorId,
        },
      );

      final apiResponse = ApiResponse<bool>.fromJson(
        response.data,
        (data) => data as bool? ?? true,
      );
      return apiResponse.sucesso;
    } catch (e) {
      return false;
    }
  }

  Future<bool> transferirContasReceberCaixa({
    required List<int> contasReceberIds,
    required int novoCaixaId,
  }) async {
    try {
      await Api.loadAuthToken();
      final response = await Api.dio.post(
        "/contasreceber/transferencia-caixa",
        data: {
          "contasReceberIds": contasReceberIds,
          "novoCaixaId": novoCaixaId,
        },
      );

      final apiResponse = ApiResponse<bool>.fromJson(
        response.data,
        (data) => data as bool? ?? true,
      );
      return apiResponse.sucesso;
    } catch (e) {
      return false;
    }
  }

  Future<void> buscarParcelasRelevantes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    String vendedorOrEmpresaId =
        _authProvider.loginResponse!.usuario.id.toString();
    String path = "";

    if (_authProvider.loginResponse!.role == "VENDEDOR") {
      path = '/parcelas/vendedor/$vendedorOrEmpresaId/relevantes';
    } else {
      path = '/parcelas/empresa/$vendedorOrEmpresaId/relevantes';
    }

    try {
      final response = await Api.dio.get(path);

      final apiResponse = ApiResponse<List<ParcelaResumoDTO>>.fromJson(
        response.data,
        (jsonList) => (jsonList as List)
            .map((json) => ParcelaResumoDTO.fromJson(json))
            .toList(),
      );

      if (apiResponse.sucesso) {
        _parcelas = apiResponse.data ?? [];
      } else {
        _errorMessage = apiResponse.message;
      }
    } catch (e) {
      _errorMessage = "Erro ao buscar parcelas.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double get somaContasReceber {
    return _emprestimos.fold(0.0, (soma, emp) => soma + emp.valor);
  }

  Future<BaixaParcelaResult> darBaixaParcela(BaixaParcelaDTO baixaDTO) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (_authProvider.loginResponse!.role == "VENDEDOR") {
      baixaDTO.vendedorId = _authProvider.loginResponse!.usuario.id;
    }

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.post(
        "/baixa-parcela",
        data: baixaDTO.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => json,
      );

      if (!apiResponse.sucesso) {
        return BaixaParcelaResult(
          sucesso: false,
          mensagemErro: apiResponse.message,
        );
      }

      return BaixaParcelaResult(sucesso: true);
    } on DioException catch (e) {
      if (e.response != null) {
        final apiResponse = ApiResponse.fromJson(
          e.response!.data,
          (json) => json,
        );
        final mensagem = (e.response!.statusCode == 500)
            ? "Erro interno no servidor. Tente novamente mais tarde."
            : apiResponse.message;

        return BaixaParcelaResult(sucesso: false, mensagemErro: mensagem);
      } else {
        return BaixaParcelaResult(
          sucesso: false,
          mensagemErro: "Erro de conexão com o servidor.",
        );
      }
    } catch (e) {
      return BaixaParcelaResult(
        sucesso: false,
        mensagemErro: "Erro inesperado: $e",
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> buscarResumoVendedor(Vendedor? vendedor) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      int? vendedorId;
      if (vendedor != null) {
        vendedorId = vendedor.id;
      } else {
        vendedorId = _authProvider.loginResponse!.usuario.id;
      }

      final response =
          await Api.dio.get('/contasreceber/vendedor/$vendedorId/resumo');

      final apiResponse =
          ApiResponse<ResumoTotalizadoresContasReceber>.fromJson(
        response.data,
        (json) => ResumoTotalizadoresContasReceber.fromJson(
            json as Map<String, dynamic>),
      );
      if (apiResponse.sucesso) {
        _resumoVendedor = apiResponse.data;
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao consutar resumo do vendedor: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> buscarResumoEmpresa() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      String empresaId = _authProvider.loginResponse!.usuario.id.toString();

      final response =
          await Api.dio.get('/contasreceber/empresa/$empresaId/resumo');

      final apiResponse =
          ApiResponse<ResumoTotalizadoresContasReceber>.fromJson(
        response.data,
        (json) => ResumoTotalizadoresContasReceber.fromJson(
            json as Map<String, dynamic>),
      );
      if (apiResponse.sucesso) {
        _resumoEmpresa = apiResponse.data;
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao consutar resumo da empresa: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ContasReceberDTO?> quitarContasReceberComPenhora(
      int contasreceberId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response =
          await Api.dio.post('/contasreceber/quitar-penhora/$contasreceberId');

      final apiResponse = ApiResponse<ContasReceberDTO>.fromJson(
        response.data,
        (json) => ContasReceberDTO.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.sucesso) {
        return apiResponse.data!;
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao quitar a venda com garantia: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<void> buscarResumoCliente(int cliented) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response =
          await Api.dio.get('/contasreceber/cliente/resumo/$cliented');

      final apiResponse =
          ApiResponse<ResumoTotalizadoresContasReceber>.fromJson(
        response.data,
        (json) => ResumoTotalizadoresContasReceber.fromJson(
            json as Map<String, dynamic>),
      );
      if (apiResponse.sucesso) {
        _resumoCliente = apiResponse.data;
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao consutar resumo do vendedor: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleEsconderValores() {
    esconderValores = !esconderValores;
    notifyListeners();
  }

  Future<ClientesContasReceberAtivos?> countContasReceberCliente(
      int clienteId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response =
          await Api.dio.get("/contasreceber/cliente/$clienteId/status");

      final apiResponse = ApiResponse<ClientesContasReceberAtivos>.fromJson(
        response.data,
        (json) =>
            ClientesContasReceberAtivos.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.sucesso == false) {
        _errorMessage = apiResponse.message;
        return null;
      }

      return apiResponse.data;
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao consultar vínculos: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  void atualizarAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> buscarPrevisaoRecebimentos() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      int? vendedorId;
      String path = '/parcelas/previsao-recebimento';
      if (_authProvider.loginResponse!.role == "VENDEDOR") {
        vendedorId = _authProvider.loginResponse!.usuario.id;
        path = '/parcelas/previsao-recebimento/vendedor/$vendedorId';
      }

      final response = await Api.dio.get(
        path,
      );

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.sucesso) {
        _previsoes = apiResponse.data!
            .map((e) => PrevisaoRecebimento.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao buscar previsões: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> buscarParcelasPrevisao({
    required int dias,
    String? dataInicio,
    String? dataFim,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      String path = '/parcelas/previsao-detalhe';
      final Map<String, dynamic> queryParams = {
        'dias': dias,
      };

      if (dataInicio != null) {
        queryParams['dataInicio'] = FormatData.formatarDataYYYYAADD(dataInicio);
      }
      if (dataFim != null) {
        queryParams['dataFim'] = FormatData.formatarDataYYYYAADD(dataFim);
      }

      if (_authProvider.loginResponse?.role == "VENDEDOR") {
        queryParams['vendedorId'] =
            _authProvider.loginResponse?.usuario.id ?? 0;
      }

      final response = await Api.dio.get(path, queryParameters: queryParams);

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.sucesso) {
        _parcelasPrevisao = apiResponse.data!
            .map((e) => ParcelaResumoDTO.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao buscar parcelas: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> buscarAgrupamentoParcelas({
    String? status,
    String? dataInicio,
    String? dataFim,
    String? vencimentoOuPagamento,
    String? tipoPagamento,
    int? caixaId,
    int? vendedorId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();

      final response =
          await Api.dio.get("/parcelas/agrupamento", queryParameters: {
        if (status != null) 'status': status,
        if (tipoPagamento != null) 'tipoPagamento': tipoPagamento,
        if (dataInicio != null)
          'dataInicio': FormatData.formatarDataYYYYAADD(dataInicio),
        if (dataFim != null)
          'dataFim': FormatData.formatarDataYYYYAADD(dataFim),
        if (vencimentoOuPagamento != null)
          'vencimentoOuPagamento': vencimentoOuPagamento,
        if (caixaId != null) 'caixaId': caixaId,
        if (vendedorId != null) 'vendedorId': vendedorId,
      });

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List,
      );

      if (apiResponse.sucesso) {
        _resumoCobranca = apiResponse.data!
            .map((e) =>
                AgrupamentoParcelaDTO.fromJson(e as Map<String, dynamic>))
            .toList();

        _ultimoFiltro = FiltroResumo(
          status: status,
          dataInicio: dataInicio,
          dataFim: dataFim,
          vencimentoOuPagamento: vencimentoOuPagamento,
          tipoPagamento: tipoPagamento,
          caixaId: caixaId,
          vendedorId: vendedorId,
        );
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro ao buscar agrupamento de parcelas: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> buscarDetalhesGeralUsandoUltimoFiltro({
    required int empresaId,
  }) async {
    if (_ultimoFiltro == null) return;

    _isLoading = true;
    notifyListeners();

    final f = _ultimoFiltro!;
    final response = await Api.dio.get('/parcelas/detalhes', queryParameters: {
      'empresaId': empresaId.toString(),
      'status': f.status,
      'dataInicio': f.dataInicio,
      'dataFim': f.dataFim,
      'vencimentoOuPagamento': f.vencimentoOuPagamento,
      'caixaId': f.caixaId?.toString(),
      'vendedorId': f.vendedorId?.toString(),
    });

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data,
      (json) => json as List,
    );

    if (apiResponse.sucesso) {
      detalhesGeral = apiResponse.data!
          .map((e) => DetalheParcelaDTO.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _errorMessage = apiResponse.message;
    }

    _isLoading = false;
    notifyListeners();
    _errorMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final f = _ultimoFiltro!;
      final response =
          await Api.dio.get('/parcelas/detalhes', queryParameters: {
        'empresaId': empresaId.toString(),
        'status': f.status,
        'dataInicio': f.dataInicio,
        'dataFim': f.dataFim,
        'vencimentoOuPagamento': f.vencimentoOuPagamento,
        'tipoPagamento': f.tipoPagamento,
        'caixaId': f.caixaId?.toString(),
        'vendedorId': f.vendedorId?.toString(),
      });

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List,
      );

      if (apiResponse.sucesso) {
        detalhesGeral = apiResponse.data!
            .map((e) => DetalheParcelaDTO.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro ao buscar detalhes das parcelas: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletarContrato(int contasReceberId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response =
          await Api.dio.delete('/contasreceber/deletar/$contasReceberId');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => null, // Não há `data` no caso de delete
      );

      if (apiResponse.sucesso) {
        return true;
      } else {
        _errorMessage = apiResponse.message;
        return false;
      }
    } on DioException catch (dioErr) {
      if (dioErr.response != null && dioErr.response?.data != null) {
        try {
          final data = dioErr.response!.data;
          if (data is Map<String, dynamic>) {
            _errorMessage = data['message'] ?? 'Erro desconhecido.';
          } else {
            _errorMessage = dioErr.message ?? 'Erro desconhecido.';
          }
        } catch (e) {
          _errorMessage = "Erro ao interpretar resposta: $e";
        }
      } else {
        _errorMessage = DioErrorHandler.handleDioException(dioErr);
      }
    } catch (e) {
      _errorMessage = "Erro inesperado ao deletar contrato: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
}
