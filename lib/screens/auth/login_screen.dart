import 'package:emprestimos_app/core/helpers.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:emprestimos_app/screens/auth/alterar_senha_screen.dart';
import 'package:emprestimos_app/screens/auth/esqueci_minha_senha.dart';
import 'package:emprestimos_app/screens/planos/escolher_planos.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:emprestimos_app/widgets/password_field_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/main_screen.dart';
import '../../core/theme/theme.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _biometriaJaSolicitada = false;

  void _login() async {
    if (emailController.text.isEmpty || senhaController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha todos os campos!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response =
        await authProvider.login(emailController.text, senhaController.text);

    if (!mounted) return;

    if (!response.sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }
    if (!kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("email", emailController.text);
      await prefs.setString("senha", senhaController.text);
    }

    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (_) => MainScreen(
              role: response.data!.role,
              plano: authProvider.loginResponse?.plano)),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || kIsWeb || _biometriaJaSolicitada) return;
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString("email");
      final senha = prefs.getString("senha");
      if (!mounted || email == null || senha == null) return;
      _biometriaJaSolicitada = true;
      _loginComBiometria();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/img/background.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 48),
                        child: _buildLoginBox(authProvider),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _loginComBiometria() async {
    final biometria = BiometriaHelper();
    final sucesso = await biometria.autenticarComBiometria();

    if (sucesso) {
      // final authProvider = Provider.of<AuthProvider>(context);

      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString("email");
      final senha = prefs.getString("senha");

      if (email != null && senha != null) {
        emailController.text = email;
        senhaController.text = senha;
        _login();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Use e-mail e senha no primeiro login para ativar a biometria.",
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Autenticação biométrica falhou.")),
      );
    }
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
                scale: 1 + (_animation.value * 0.03),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor
                            .withOpacity(0.6 + (_animation.value * 0.4)),
                        blurRadius: 12 + (_animation.value * 12),
                        spreadRadius: 1 + (_animation.value * 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    "SC",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                      overflow: TextOverflow.ellipsis,
                      shadows: [
                        Shadow(
                          color: AppTheme.backgroundColor,
                          blurRadius: 12,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                "Comércio",
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool isObscure,
      {bool isPasswordField = false}) {
    if (isPasswordField) {
      return PasswordField(controller: controller, label: label, icon: icon);
    }

    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white),
      cursorColor: AppTheme.primaryColor,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: "Digite seu $label",
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }

  Widget _buildVendedorButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EscolherPlanoScreen()),
          );
        },
        child: const Text(
          "Cadastre-se",
          style: TextStyle(
              fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildLoginBox(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildTextField(emailController, "Email", Icons.email, false),
          const SizedBox(height: 16),
          _buildTextField(senhaController, "Senha", Icons.lock, true,
              isPasswordField: true),
          const SizedBox(height: 20),
          authProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomButton(text: 'Entrar', onPressed: _login),
          const SizedBox(height: 16),
          if (!authProvider.isLoading && !kIsWeb)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.fingerprint,
                      color: Colors.white, size: 36),
                  onPressed: _loginComBiometria,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Logar com biometria',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EsqueciMinhaSenhaScreen()),
              );
            },
            child: const Text(
              "Esqueci minha senha",
              style: TextStyle(color: Colors.blue),
            ),
          ),
          // _buildVendedorButton(),
        ],
      ),
    );
  }
}
