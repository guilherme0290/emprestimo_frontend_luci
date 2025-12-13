// lib/screens/config/perfil_empresa_screen.dart
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/formatters.dart';
import 'package:emprestimos_app/widgets/input_field.dart';
import 'package:emprestimos_app/widgets/input_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:emprestimos_app/models/empresa_perfil.dart';

// ⬇️ mesmos componentes usados no formulário de Cliente
import 'package:emprestimos_app/providers/cidade_provider.dart';
import 'package:emprestimos_app/models/cidade.dart';
import 'package:emprestimos_app/widgets/uf_dropdown.dart';
import 'package:emprestimos_app/widgets/cidade_dropdown.dart';

// ⬇️ mesma lib de máscara usada no cliente
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PerfilEmpresaScreen extends StatefulWidget {
  const PerfilEmpresaScreen({super.key});

  @override
  State<PerfilEmpresaScreen> createState() => _PerfilEmpresaScreenState();
}

class _PerfilEmpresaScreenState extends State<PerfilEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();

  // controllers
  late final TextEditingController _nome = TextEditingController();
  late final TextEditingController _cnpj = TextEditingController();
  late final TextEditingController _telefone = TextEditingController();
  late final TextEditingController _email = TextEditingController();
  late final TextEditingController _rua = TextEditingController();
  late final TextEditingController _bairro = TextEditingController();
  late final TextEditingController _cep = TextEditingController();
  late final TextEditingController _numero = TextEditingController();
  late final TextEditingController _complemento = TextEditingController();

  // UF/Cidade (mesma lógica da tela de cliente)
  String? ufSelecionada;
  Cidade? cidadeSelecionada;

  // máscaras (iguais às do Cliente)
  final cepFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prov = context.read<EmpresaProvider>();
      await prov.fetchPerfil();

      final e = prov.empresaCompleto; // ou prov.empresa, conforme seu provider
      if (e != null) {
        _nome.text = e.nome ?? '';
        _cnpj.text = CpfCnpjFormatter.format(e.cnpj ?? '');
        _telefone.text = e.telefone ?? '';
        _email.text = e.email ?? '';
        _rua.text = e.rua ?? '';
        _bairro.text = e.bairro ?? '';
        _cep.text = e.cep ?? '';
        _numero.text = e.numero ?? '';
        _complemento.text = e.complemento ?? '';

        _telefone.text = TelefoneFormatter.format(e.telefone ?? '');
        _cep.text = CepFormatter.format(e.cep ?? '');

        // carrega UF/Cidade iniciais a partir do cidadeId já salvo
        if (e.cidadeId != null) {
          await _carregarCidadeInicial(e.cidadeId!);
        }
      }
    });
  }

  Future<void> _carregarCidadeInicial(int cidadeId) async {
    final cidadeProv = context.read<CidadeProvider>();
    final cidade = await cidadeProv.buscarCidadesById(cidadeId);
    if (!mounted) return;
    if (cidade != null) {
      setState(() {
        cidadeSelecionada = cidade;
        ufSelecionada = cidade.uf; // mesma regra do Cliente
      });
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _cnpj.dispose();
    _telefone.dispose();
    _email.dispose();
    _rua.dispose();
    _bairro.dispose();
    _cep.dispose();
    _numero.dispose();
    _complemento.dispose();
    super.dispose();
  }

  String? _validaObrig(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Obrigatório' : null;

  String? _validaEmail(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (!v.contains('@')) return 'E-mail inválido';
    return null;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final prov = context.read<EmpresaProvider>();
    final dto = EmpresaCompleto(
      id: prov.empresa?.id,
      nome: _nome.text.trim(),
      cnpj: _cnpj.text.trim(),
      telefone: _telefone.text.trim(),
      email: _email.text.trim(),
      rua: _rua.text.trim(),
      bairro: _bairro.text.trim(),
      cidadeId:
          cidadeSelecionada?.id ?? prov.empresaCompleto?.cidadeId, // << AQUI
      cep: _cep.text.trim(),
      numero: _numero.text.trim(),
      complemento: _complemento.text.trim(),
    );

    final ok = await prov.salvar(dto);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prov.errorMessage ?? 'Falha ao atualizar perfil'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmpresaProvider>(
      builder: (context, prov, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppTheme.secondaryColor,
            title: const Text('Perfil da Empresa'),
          ),
          body: prov.isLoading && prov.empresa == null
              ? const Center(child: CircularProgressIndicator())
              : AppBackground(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text('Dados da empresa',
                                      style: AppTheme.titleStyle),
                                  const SizedBox(height: 12),

                                  InputRow2(
                                    left: InputCustomizado(
                                      controller: _nome,
                                      labelText: 'Nome',
                                      validator: _validaObrig,
                                    ),
                                    right: InputCustomizado(
                                      controller: _cnpj,
                                      labelText: 'CPF/CNPJ (Opcional)',
                                      inputFormatters: [CpfCnpjFormatter()],
                                      validator: (value) =>
                                          Util.isCpfCnpjValid(_cnpj.text),
                                    ),
                                  ),

                                  InputRow2(
                                    left: InputCustomizado(
                                      controller: _telefone,
                                      labelText: 'Telefone',
                                      inputFormatters: [TelefoneFormatter()],
                                      type: TextInputType
                                          .number, // <- use "type" (não "keyboardType")
                                    ),
                                    right: InputCustomizado(
                                      controller: _email,
                                      labelText: 'E-mail',
                                      validator: _validaEmail,
                                      type: TextInputType.emailAddress,
                                    ),
                                  ),

                                  InputRow2(
                                    left: InputCustomizado(
                                      controller: _rua,
                                      labelText: 'Rua',
                                    ),
                                    right: InputCustomizado(
                                      controller: _numero,
                                      labelText: 'Número',
                                      type: TextInputType.number,
                                    ),
                                  ),

                                  InputRow2(
                                    left: InputCustomizado(
                                      controller: _bairro,
                                      labelText: 'Bairro (Opcional)',
                                    ),
                                    right: InputCustomizado(
                                      controller: _cep,
                                      labelText: 'CEP (Opcional)',
                                      inputFormatters: [CepFormatter()],
                                      type: TextInputType.number,
                                    ),
                                  ),

                                  // Linha 5 - UF / Cidade (mantém seus dropdowns)
                                  const SizedBox(height: 10),
                                  InputRow2(
                                    left: UfDropdown(
                                      selectedUf: ufSelecionada,
                                      onUfSelecionada: (uf) {
                                        setState(() {
                                          ufSelecionada = uf;
                                          cidadeSelecionada = null;
                                        });
                                      },
                                    ),
                                    right: CidadeDropdown(
                                      key: ValueKey(ufSelecionada),
                                      uf: ufSelecionada,
                                      selectedCidade: cidadeSelecionada,
                                      onCidadeSelecionada: (cidade) {
                                        cidadeSelecionada = cidade;
                                      },
                                    ),
                                  ),

                                  // Complemento (linha inteira)
                                  const SizedBox(height: 10),
                                  InputCustomizado(
                                    controller: _complemento,
                                    labelText: 'Complemento (Opcional)',
                                  ),

                                  const SizedBox(height: 18),

                                  // Botões
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: prov.isLoading
                                              ? null
                                              : () => Navigator.pop(context),
                                          child: const Text('Cancelar'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed:
                                              prov.isLoading ? null : _salvar,
                                          icon: prov.isLoading
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Icon(Icons.save),
                                          label: const Text('Salvar'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _Row2 extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _Row2({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 720;
    if (!isWide) {
      return Column(
        children: [
          left,
          const SizedBox(height: 12),
          right,
          const SizedBox(height: 12),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}
