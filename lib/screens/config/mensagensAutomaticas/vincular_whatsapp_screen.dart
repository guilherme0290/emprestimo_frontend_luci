import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/empresa.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:emprestimos_app/providers/whatsapp_provider.dart';
import 'package:emprestimos_app/screens/planos/escolher_planos.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:emprestimos_app/widgets/custom_swithtile.dart';
import 'package:emprestimos_app/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

class VinculoWhatsappScreen extends StatefulWidget {
  const VinculoWhatsappScreen({Key? key}) : super(key: key);

  @override
  State<VinculoWhatsappScreen> createState() => _VinculoWhatsappScreenState();
}

class _VinculoWhatsappScreenState extends State<VinculoWhatsappScreen> {
  final _numeroController = TextEditingController();

  final telefoneFormater = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  String? _pairingCode;
  String? _qrCodeBase64;
  bool _aguardandoConexao = false;
  bool _fieldsVisible = true;
  late WhatsappProvider provider;
  Empresa? _empresa;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      provider = Provider.of<WhatsappProvider>(context, listen: false);
      _empresa = Provider.of<EmpresaProvider>(context, listen: false).empresa;
      await _verificarStatusOuCriar();
    });
  }

  Future<void> _verificarStatusOuCriar() async {
    final numero = Util.removerMascara(_numeroController.text);
    final status = await provider.getStatus();

    if (provider.errorMessage?.contains("Instancia não encontrada") == true) {
      if (numero.isNotEmpty) {
        final criado = await provider.criarInstancia(numero);
        if (criado != null) {
          _qrCodeBase64 = criado.qrcode.base64;
          _pairingCode = criado.qrcode.pairingCode;
          _aguardandoConexao = true;
          _iniciarMonitoramentoConexao();
        }
      }
    } else if (status != null && status.instance.state == "open") {
      setState(() {
        _fieldsVisible = false;
        _aguardandoConexao = false;
      });
    } else if (status != null &&
        (status.instance.state == "close" ||
            status.instance.state == "connecting")) {
      final conectado = await provider.conectarInstancia(numero);
      if (conectado != null) {
        _pairingCode = conectado.pairingCode;
        _qrCodeBase64 = conectado.base64;
        _aguardandoConexao = true;
        _iniciarMonitoramentoConexao();
      }
    }
  }

  Future<void> _iniciarMonitoramentoConexao() async {
    Future.delayed(const Duration(seconds: 5), () async {
      if (!mounted || !_aguardandoConexao) return;
      final status = await provider.getStatus();
      if (status != null && status.instance.state == "open") {
        setState(() {
          _fieldsVisible = false;
          _aguardandoConexao = false;
        });
      } else {
        _iniciarMonitoramentoConexao();
      }
    });
  }

  Future<void> _desconectar() async {
    await provider.logout();
    await provider.deletarInstancia();
    setState(() {
      _fieldsVisible = true;
      _pairingCode = null;
      _qrCodeBase64 = null;
      _aguardandoConexao = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<WhatsappProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!empresaPodeUsarWhatsapp()) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock, color: Colors.orange),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "O envio automático de mensagens por WhatsApp está disponível apenas para planos com suporte a essa funcionalidade.",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EscolherPlanoScreen(),
                        ),
                      );
                    },
                    child: const Text("Ver planos"),
                  ),
                ],
              ),
            ),
          ],
          if (_fieldsVisible) ...[
            const Text(
              "Vinculação do WhatsApp",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Insira seu número de WhatsApp para iniciar a vinculação via código de pareamento.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            InputCustomizado(
                controller: _numeroController,
                labelText: "Numero celular (xx) xxxxx-xxxx",
                type: TextInputType.number,
                enabled: empresaPodeUsarWhatsapp(),
                leadingIcon:
                    const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
                inputFormatters: [telefoneFormater],
                validator: (value) =>
                    value!.isEmpty ? "Campo obrigatório" : null),
          ],
          const SizedBox(height: 16),
          if (_aguardandoConexao && _qrCodeBase64 != null) ...[
            const SizedBox(height: 20),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomButton(
                    text: "Gerar novo QR Code",
                    onPressed: _verificarStatusOuCriar,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Escaneie o QR Code abaixo ou insira o código manualmente no seu WhatsApp:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Image.memory(
                    Uri.parse(_qrCodeBase64!).data!.contentAsBytes(),
                    height: 220,
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    _pairingCode ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "No WhatsApp: Vá em Dispositivos Conectados > Conectar com número de telefone > insira o código acima.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!_aguardandoConexao &&
              !provider.statusConectado &&
              _qrCodeBase64 == null) ...[
            if (provider.isLoading) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 16),
            ] else ...[
              CustomButton(
                text: "Criar Conexão",
                onPressed: _verificarStatusOuCriar,
                enabled: empresaPodeUsarWhatsapp(),
              ),
            ],
          ],
          if (!_aguardandoConexao && provider.statusConectado) ...[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(child: Text("WhatsApp conectado e pronto para uso."))
                ],
              ),
            ),
            CustomButton(
              text: "Desconectar",
              onPressed: _desconectar,
              backgroundColor: Colors.red,
            ),
          ],
        ],
      ),
    );
  }

  bool empresaPodeUsarWhatsapp() {
    return _empresa?.plano?.incluiWhatsapp ?? false;
  }
}
