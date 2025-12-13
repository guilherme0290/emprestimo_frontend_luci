import 'dart:async';

import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EsqueciMinhaSenhaScreen extends StatefulWidget {
  @override
  State<EsqueciMinhaSenhaScreen> createState() =>
      _EsqueciMinhaSenhaScreenState();
}

class _EsqueciMinhaSenhaScreenState extends State<EsqueciMinhaSenhaScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _mensagem;

  bool _bloqueadoPorTempo = false;
  Timer? _timerBloqueio;
  int _segundosRestantes = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Digite seu e-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              authProvider.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        final email = _emailController.text.trim();

                        if (email.isEmpty) {
                          setState(() {
                            _mensagem = "Por favor, digite um e-mail válido.";
                          });
                          return;
                        }

                        // Bloqueio manual (caso tentem burlar)
                        if (_bloqueadoPorTempo) {
                          setState(() {
                            _mensagem =
                                "Aguarde ${_segundosRestantes ~/ 60} min e ${_segundosRestantes % 60} seg para tentar novamente.";
                          });
                          return;
                        }

                        final response =
                            await authProvider.solicitarRecuperacaoSenha(email);

                        setState(() {
                          _mensagem = response.sucesso
                              ? response.message
                              : authProvider.errorMessage ??
                                  response.message;

                          if (response.sucesso) {
                            _bloqueadoPorTempo = true;
                            _segundosRestantes = 300;

                            _timerBloqueio?.cancel();
                            _timerBloqueio = Timer.periodic(
                                const Duration(seconds: 1), (timer) {
                              if (_segundosRestantes <= 1) {
                                timer.cancel();
                                setState(() {
                                  _bloqueadoPorTempo = false;
                                  _segundosRestantes = 0;
                                });
                              } else {
                                setState(() {
                                  _segundosRestantes--;
                                });
                              }
                            });
                          }
                        });
                      },
                      child: const Text('Enviar link de recuperação'),
                    ),
              if (_mensagem != null) ...[
                const SizedBox(height: 20),
                Text(
                  _mensagem!,
                  style: TextStyle(
                    color: _mensagem!.toLowerCase().contains("sucesso")
                        ? Colors.green
                        : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (_bloqueadoPorTempo && _segundosRestantes > 0) ...[
                const SizedBox(height: 12),
                Text(
                  "Você poderá solicitar novamente em ${_segundosRestantes ~/ 60} min e ${_segundosRestantes % 60} seg.",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
