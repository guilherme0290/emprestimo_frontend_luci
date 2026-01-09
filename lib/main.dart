import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/firebase_options.dart';
import 'package:emprestimos_app/providers/caixa_provider.dart';
import 'package:emprestimos_app/providers/cidade_provider.dart';
import 'package:emprestimos_app/providers/cliente_provider.dart';
import 'package:emprestimos_app/providers/transacoes_provider.dart';
import 'package:emprestimos_app/providers/vendedor_provider.dart';
import 'package:emprestimos_app/providers/compra_provider.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';
import 'package:emprestimos_app/providers/mensagens_cobranca_provider.dart';
import 'package:emprestimos_app/providers/mensagens_manuais_provider.dart';
import 'package:emprestimos_app/providers/notificacoes_provider.dart';
import 'package:emprestimos_app/providers/parametros_provider.dart';
import 'package:emprestimos_app/providers/planos_provider.dart';
import 'package:emprestimos_app/providers/score_provider.dart';
import 'package:emprestimos_app/providers/usuario_provider.dart';
import 'package:emprestimos_app/providers/whatsapp_provider.dart';
import 'package:emprestimos_app/screens/auth/auth_wrapper.dart';
import 'package:emprestimos_app/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/auth_provider.dart';
import 'package:emprestimos_app/core/navigation_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';

// 🚀 Configuração para Notificações Firebase
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🔔 Mensagem recebida em segundo plano: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('🛑 FlutterError: ${details.exception}');
  };

  await initializeDateFormatting('pt_BR', null);

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        //
        ChangeNotifierProxyProvider<AuthProvider, UsuarioProvider>(
          create: (context) => UsuarioProvider(),
          update: (context, authProvider, previous) =>
              previous!..atualizarUsuario(authProvider),
        ),

        ChangeNotifierProxyProvider<AuthProvider, EmpresaProvider>(
          create: (context) => EmpresaProvider(context.read<AuthProvider>()),
          update: (context, authProvider, previous) =>
              previous!..atualizarAuthProvider(authProvider),
        ),

        ChangeNotifierProxyProvider<AuthProvider, ContasReceberProvider>(
          create: (context) =>
              ContasReceberProvider(context.read<AuthProvider>()),
          update: (context, authProvider, previous) =>
              previous!..atualizarAuthProvider(authProvider),
        ),

        ChangeNotifierProxyProvider<AuthProvider, ClienteProvider>(
          create: (context) => ClienteProvider(context.read<AuthProvider>()),
          update: (context, authProvider, previous) =>
              previous!..atualizarAuthProvider(authProvider),
        ),

        ChangeNotifierProxyProvider<AuthProvider, VendedorProvider>(
          create: (context) => VendedorProvider(context.read<AuthProvider>()),
          update: (context, authProvider, previous) =>
              previous!..atualizarAuthProvider(authProvider),
        ),

        // Opcional: manter se quiser evitar recarregamento dos parâmetros
        ChangeNotifierProxyProvider<AuthProvider, ParametroProvider>(
          create: (context) => ParametroProvider(context.read<AuthProvider>()),
          update: (context, authProvider, previous) =>
              previous!..atualizarAuthProvider(authProvider),
        ),

        // Opcional: manter se você guarda notificações já carregadas
        ChangeNotifierProxyProvider<AuthProvider, NotificacaoProvider>(
          create: (context) =>
              NotificacaoProvider(context.read<AuthProvider>()),
          update: (context, authProvider, previous) =>
              previous!..atualizarAuthProvider(authProvider),
        ),

        ChangeNotifierProxyProvider<AuthProvider, MensagemCobrancaProvider>(
          create: (context) =>
              MensagemCobrancaProvider(context.read<AuthProvider>()),
          update: (context, authProvider, previous) =>
              MensagemCobrancaProvider(authProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, MensagensManuaisProvider>(
          create: (context) =>
              MensagensManuaisProvider(context.read<AuthProvider>()),
          update: (context, authProvider, previous) =>
              MensagensManuaisProvider(authProvider),
        ),
        ChangeNotifierProxyProvider<EmpresaProvider, CompraProvider>(
          create: (_) => CompraProvider(),
          update: (_, empresaProvider, compraProvider) =>
              compraProvider!..setEmpresaProvider(empresaProvider),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => ClienteScoreProvider()),
        ChangeNotifierProvider(create: (_) => PlanoProvider()),
        ChangeNotifierProvider(create: (_) => CidadeProvider()),
        ChangeNotifierProvider(create: (_) => WhatsappProvider()),
        ChangeNotifierProvider(create: (_) => TransacoesProvider()),
        ChangeNotifierProvider(create: (_) => CaixaProvider()),
        ChangeNotifierProvider(create: (_) => WhatsappProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SC Comércio',
        theme: AppTheme.lightTheme,
        navigatorKey: navigatorKey,
        home: const AuthWrapper(),
        localizationsDelegates: const [
          // Adicione os delegados de localização necessários
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'), // Português do Brasil
        ],
        onGenerateRoute: (settings) {
          if (settings.name == '/login') {
            return MaterialPageRoute(builder: (_) => LoginScreen());
          }
          // Rota padrão
          return MaterialPageRoute(builder: (_) => const AuthWrapper());
        },
      ),
    );
  }
}
