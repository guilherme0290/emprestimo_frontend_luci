import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/screens/auth/login_screen.dart';

class AlterarSenhaScreen extends StatefulWidget {
  const AlterarSenhaScreen({Key? key}) : super(key: key);

  @override
  _AlterarSenhaScreenState createState() => _AlterarSenhaScreenState();
}

class _AlterarSenhaScreenState extends State<AlterarSenhaScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController =
      TextEditingController();
  bool isLoading = false;

  void _alterarSenha() async {
    if (senhaController.text.isEmpty || confirmarSenhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos!")),
      );
      return;
    }

    if (senhaController.text != confirmarSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As senhas não coincidem!")),
      );
      return;
    }

    setState(() => isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await authProvider.alterarSenha(
        emailController.text, senhaController.text);

    setState(() => isLoading = false);

    if (!response.sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Senha alterada com sucesso! Faça login novamente.")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alterar Senha"),
      ),
      body: SafeArea(
        child: AppBackground(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildTextField(emailController, "Email", Icons.mail, false),
                  const SizedBox(height: 16),
                  _buildTextField(
                      senhaController, "Nova Senha", Icons.lock, true),
                  const SizedBox(height: 16),
                  _buildTextField(confirmarSenhaController, "Confirmar Senha",
                      Icons.lock_outline, true),
                  const SizedBox(height: 20),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Alterar Senha",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Digite uma nova senha para acessar sua conta",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool isObscure) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _alterarSenha,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppTheme.primaryColor,
          elevation: 4,
        ),
        child: const Text("Salvar Senha", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
