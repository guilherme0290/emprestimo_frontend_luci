import 'package:emprestimos_app/core/role.dart';
import 'package:emprestimos_app/screens/auth/alterar_senha_screen.dart';
import 'package:emprestimos_app/screens/auth/login_screen.dart';
import 'package:emprestimos_app/screens/config/caixas/caixa_list_screen.dart';
import 'package:emprestimos_app/screens/config/mensagensAutomaticas/mensagens_cobranca.dart';
import 'package:emprestimos_app/screens/config/mensagensAutomaticas/mensagens_manuais.dart';
import 'package:emprestimos_app/screens/config/parametros/solicitacoes_parametro_screen.dart';
import 'package:emprestimos_app/screens/config/perfil/perfil_screen.dart';
import 'package:emprestimos_app/screens/parametros/parametros_empresa.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  bool notificacoesAtivadas = true;
  String versaoApp = "1.0.0";

  bool _isEmpresa = false;
  bool _loading = true;
  AuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _verificarTipoUsuario();
    _carregarVersao();
  }

  Future<void> _carregarVersao() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      versaoApp = info.version;
    });
  }

  Future<void> _verificarTipoUsuario() async {
    if (_authProvider == null) return;
    _authProvider!.carregarDadosSalvos();

    final roleStr = _authProvider!.loginResponse?.role ?? '';
    final roleEnum = Role.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => Role.EMPRESA, // valor padrão se não encontrar
    );

    setState(() {
      _isEmpresa = roleEnum == Role.EMPRESA;
      _loading = _authProvider!.isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : AppBackground(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  if (_isEmpresa)
                    _buildCardTile(
                      icon: Icons.person,
                      title: "Editar Perfil",
                      color: AppTheme.primaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PerfilEmpresaScreen()),
                        );
                      },
                    ),
                  if (_isEmpresa)
                    _buildCardTile(
                      icon: Icons.settings,
                      title: "Parâmetros da Empresa",
                      color: Colors.grey,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ParametrosEmpresaScreen()),
                        );
                      },
                    ),
                  if (_isEmpresa)
                    _buildCardTile(
                      icon: Icons.message,
                      title: "Mensagens Automáticas de Cobrança",
                      color: AppTheme.primaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MensagensCobrancaScreen()),
                        );
                      },
                    ),
                  if (_isEmpresa)
                    _buildCardTile(
                      icon: Icons.mark_email_read,
                      title: "Mensagens Manuais",
                      color: AppTheme.primaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MensagensManuaisScreen()),
                        );
                      },
                    ),
                  if (_isEmpresa)
                    _buildCardTile(
                      icon: Icons.money,
                      title: "Cadastro de Responsaveis",
                      color: AppTheme.primaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CaixaListScreen()),
                        );
                      },
                    ),
                  if (_isEmpresa)
                    _buildCardTile(
                      icon: Icons.check_circle,
                      title: "Aprovação de solicitações",
                      color: AppTheme.primaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const SolicitacoesParametrosScreen()),
                        );
                      },
                    ),
                  _buildCardTile(
                    icon: Icons.lock,
                    title: "Alterar Senha",
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AlterarSenhaScreen()),
                      );
                    },
                  ),
                  _buildCardTile(
                    icon: Icons.article,
                    title: "Termos de Uso e Privacidade",
                    color: Colors.blueAccent,
                    onTap: _abrirTermosDeUso,
                  ),
                  _buildCardTile(
                    icon: Icons.star_rate,
                    title: "Avalie o aplicativo",
                    color: Colors.amber.shade700,
                    onTap: _avaliarAplicativo,
                  ),
                  if (_isEmpresa)
                    _buildCardTile(
                      icon: FontAwesomeIcons.whatsapp,
                      title: "Suporte e Ajuda",
                      color: Colors.green,
                      onTap: () {
                        _authProvider!.loginResponse!.usuario.id;
                        final whatsappUrl = Uri.parse(
                            "https://wa.me/5567992917356?text=Olá, preciso de ajuda com o aplicativo. Meu ID de Empresa é: ${_authProvider!.loginResponse?.usuario.id}");
                        launchUrlString(whatsappUrl.toString(),
                            mode: LaunchMode.externalApplication);
                      },
                    ),
                  _buildCardTile(
                    icon: Icons.logout,
                    title: "Sair",
                    color: Colors.red,
                    onTap: () async {
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      await authProvider.logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text("Versão do aplicativo: $versaoApp",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                  ),
                ],
              ),
            ),
    );
  }

  void _avaliarAplicativo() async {
    final androidUrl = Uri.parse(
        "https://play.google.com/store/apps/details?id=br.com.sccomercio.app");

    if (await canLaunchUrlString(androidUrl.toString())) {
      await launchUrlString(androidUrl.toString(),
          mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Não foi possível abrir a loja.")),
      );
    }
  }

  Widget _buildCardTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Future<void> _abrirTermosDeUso() async {
    const url =
        'https://docs.google.com/document/d/1giXL4cy_Y6GjUe-7qg-qy8gI_e5UCilohO_2G-8NfIs/edit?usp=sharing';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // abre no navegador externo
      );
    } else {
      throw 'Não foi possível abrir o link $url';
    }
  }
}
