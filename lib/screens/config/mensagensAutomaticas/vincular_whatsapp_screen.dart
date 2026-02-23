import 'dart:async';
import 'dart:convert';

import 'package:emprestimos_app/providers/whatsapp_provider.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VinculoWhatsappScreen extends StatefulWidget {
  const VinculoWhatsappScreen({Key? key}) : super(key: key);

  @override
  State<VinculoWhatsappScreen> createState() => _VinculoWhatsappScreenState();
}

class _VinculoWhatsappScreenState extends State<VinculoWhatsappScreen> {
  final _numeroController = TextEditingController();
  String? _codigoConexao;
  String? _qrBase64;
  DateTime? _codigoExpiraEm;
  Timer? _expiracaoTimer;
  bool _codigoExpirado = false;
  static const _numeroKey = 'whatsapp_numero_vinculo';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _carregarNumeroSalvo();
      await _carregarStatus();
      if (!mounted) return;
      final provider = Provider.of<WhatsappProvider>(context, listen: false);
      final numeroSalvo = _numeroController.text.trim();
      if (!provider.status && numeroSalvo.isNotEmpty) {
        await _gerarCodigo();
      }
    });
  }

  Future<void> _carregarStatus() async {
    final provider = Provider.of<WhatsappProvider>(context, listen: false);
    await provider.carregarStatusWhatsapp();
  }

  Future<void> _desconectar() async {
    final provider = Provider.of<WhatsappProvider>(context, listen: false);
    final ok = await provider.desconectarWhatsapp();
    if (!mounted) return;
    if (ok) {
      setState(() {
        _codigoConexao = null;
        _qrBase64 = null;
        _codigoExpiraEm = null;
        _codigoExpirado = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp desconectado com sucesso.')),
      );
    }
  }

  Future<void> _carregarNumeroSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    final numero = prefs.getString(_numeroKey);
    if (numero == null || numero.isEmpty) return;
    _numeroController.text = numero;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _gerarCodigo() async {
    final provider = Provider.of<WhatsappProvider>(context, listen: false);
    final numero = _numeroController.text.trim();
    if (numero.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_numeroKey, numero);
    final codigo = await provider.gerarCodigoConexao(numero);
    setState(() {
      _codigoConexao = codigo;
      _qrBase64 = provider.qrBase64;
      _codigoExpirado = false;
      _codigoExpiraEm = DateTime.now().add(const Duration(minutes: 2));
    });
    _iniciarTimerExpiracao();
  }

  Future<void> _copiarCodigo() async {
    final codigo = _codigoConexao;
    if (codigo == null || codigo.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: codigo));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Código copiado para a área de transferência.')),
    );
  }

  String _sanitizeBase64(String value) {
    if (value.contains(',')) {
      return value.split(',').last.trim();
    }
    return value.trim();
  }

  Future<void> _compartilharQrCode() async {
    final qr = _qrBase64;
    if (qr == null || qr.isEmpty) return;
    final bytes = base64Decode(_sanitizeBase64(qr));
    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          mimeType: 'image/png',
          name: 'whatsapp_qrcode.png',
        ),
      ],
      text: 'QR Code para conectar o WhatsApp',
    );
  }

  void _iniciarTimerExpiracao() {
    _expiracaoTimer?.cancel();
    if (_codigoExpiraEm == null) return;
    _expiracaoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final expiraEm = _codigoExpiraEm;
      if (expiraEm == null) return;
      if (DateTime.now().isAfter(expiraEm)) {
        timer.cancel();
        setState(() {
          _codigoConexao = null;
          _qrBase64 = null;
          _codigoExpirado = true;
          _codigoExpiraEm = null;
        });
      } else {
        setState(() {});
      }
    });
  }

  String _formatarTempoRestante() {
    if (_codigoExpiraEm == null) return '';
    final diff = _codigoExpiraEm!.difference(DateTime.now());
    final segundos = diff.inSeconds.clamp(0, 600);
    final minutos = (segundos ~/ 60).toString().padLeft(2, '0');
    final resto = (segundos % 60).toString().padLeft(2, '0');
    return '$minutos:$resto';
  }

  @override
  void dispose() {
    _expiracaoTimer?.cancel();
    _numeroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WhatsappProvider>(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statusColor = provider.status ? Colors.green : Colors.red;
    final statusText =
        provider.status ? "WhatsApp conectado" : "WhatsApp desconectado";
    final isBusy = provider.isLoading;
    final canGenerate = _numeroController.text.trim().isNotEmpty &&
        !isBusy &&
        !provider.status;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withValues(alpha: 0.10),
                  scheme.primary.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withValues(alpha: 0.18)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FontAwesomeIcons.whatsapp,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vincular WhatsApp',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 14,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _WhatsappPill(
                            icon: Icons.qr_code_2_outlined,
                            label: 'QR + código',
                            color: scheme.primary,
                          ),
                          _WhatsappPill(
                            icon: provider.status
                                ? Icons.verified_outlined
                                : Icons.link_outlined,
                            label: provider.status ? 'Conectado' : 'Pendente',
                            color: statusColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: isBusy ? null : _carregarStatus,
                  child: const Text('Verificar'),
                ),
              ],
            ),
          ),
          if (provider.status) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: isBusy ? null : _desconectar,
                icon: const Icon(Icons.link_off),
                label: const Text('Desconectar WhatsApp'),
              ),
            ),
          ],
          if (provider.errorMessage != null &&
              provider.errorMessage!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.phone_android, color: scheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Número do WhatsApp',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _numeroController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: "Ex: 5599999999999",
                    prefixIcon: const Icon(Icons.phone),
                    filled: true,
                    fillColor: scheme.primary.withValues(alpha: 0.03),
                    border: const OutlineInputBorder(),
                    helperText:
                        'Inclua o código do país e DDD. Somente números.',
                  ),
                  onChanged: (_) => setState(() {
                    _codigoConexao = null;
                    _qrBase64 = null;
                    _codigoExpiraEm = null;
                    _codigoExpirado = false;
                  }),
                ),
                const SizedBox(height: 10),
                if (isBusy)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: const LinearProgressIndicator(minHeight: 4),
                  ),
                const SizedBox(height: 8),
                CustomButton(
                  text: provider.status
                      ? 'WhatsApp ja conectado'
                      : (isBusy
                          ? 'Gerando código...'
                          : 'Gerar código de conexão'),
                  onPressed: canGenerate ? _gerarCodigo : null,
                  enabled: canGenerate,
                ),
              ],
            ),
          ),
          if (provider.status) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Para gerar um novo código, primeiro desconecte esta instância.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (_codigoExpirado) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Código expirado. Gere um novo código para continuar.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_codigoConexao != null || _qrBase64 != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withValues(alpha: 0.08),
                    scheme.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.key_outlined, color: Colors.blue, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Código de conexão gerado",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_codigoExpiraEm != null)
                    Text(
                      'Expira em ${_formatarTempoRestante()}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (_codigoConexao != null && _codigoConexao!.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            _codigoConexao!,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _copiarCodigo,
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copiar código',
                        ),
                      ],
                    ),
                  if (_qrBase64 != null && _qrBase64!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Image.memory(
                          base64Decode(_sanitizeBase64(_qrBase64!)),
                          width: 220,
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _compartilharQrCode,
                        icon: const Icon(Icons.share),
                        label: const Text('Compartilhar QRCode'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: scheme.outline.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.list_alt_outlined,
                        color: scheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Passo a passo',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Gere o código aqui no app\n'
                    '2. No WhatsApp, toque em Dispositivos conectados\n'
                    '3. Escolha Conectar com número de telefone\n'
                    '4. Digite o código antes de expirar',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
          // const SizedBox(height: 30),
          // ElevatedButton(
          //   onPressed: _carregarStatus,
          //   child: const Text("Verificar conexão"),
          // ),
        ],
      ),
    );
  }
}

class _WhatsappPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _WhatsappPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
