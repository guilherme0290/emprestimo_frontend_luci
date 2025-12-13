import 'package:emprestimos_app/core/storage_service.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:emprestimos_app/screens/auth/login_screen.dart';
import 'package:emprestimos_app/screens/home/main_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:emprestimos_app/core/navigation_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarLoginECarregarDados();
    });
  }

  Future<void> _verificarLoginECarregarDados() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final empresaProvider =
        Provider.of<EmpresaProvider>(context, listen: false);

    final token = await StorageService.getToken();

    if (token?.isEmpty ?? true) {
      _navegarParaLogin();
      return;
    }

    final tokenValido = await authProvider.refreshToken();
    final loginResponse = authProvider.loginResponse;

    if (tokenValido && loginResponse != null) {
      final role = loginResponse.role;

      if (role == "EMPRESA") {
        await empresaProvider.buscarEmpresaById(loginResponse.usuario.id);
      }

      final plano = role == "EMPRESA" ? empresaProvider.empresa?.plano : null;
      _navegarParaMain(role, plano);
    } else {
      _navegarParaLogin();
    }

    await _configurarNotificacoes();
  }

  void _navegarParaLogin() {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  void _navegarParaMain(String role, dynamic plano) {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (_) => MainScreen(role: role, plano: plano),
      ),
    );
  }

  _validaAssinaturaGooglePlay(EmpresaProvider empresaProvider) async {
    final Stream<List<PurchaseDetails>> purchaseStream =
        InAppPurchase.instance.purchaseStream;
    final List<PurchaseDetails> purchases = await purchaseStream.first;

    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // ✅ Assinatura ativa (localmente)
        print("Assinatura ativa localmente: ${purchase.productID}");

        //  await empresaProvider
        //     .validarAssinaturaGooglePlay(authProvider.loginResponse!.usuario.id);
      } else if (purchase.status == PurchaseStatus.canceled ||
          purchase.status == PurchaseStatus.error) {
        print("Assinatura inativa ou com erro: ${purchase.productID}");
      }
    }
  }

  Future<void> _configurarNotificacoes() async {
    if (kIsWeb) return;
    // Inicializa o Flutter Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Pede permissão para notificações
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("🔔 Notificações autorizadas");

      String? token = await messaging.getToken();
      if (token != null) {
        if (kDebugMode) {
          print("🔥 Firebase Token: $token");
        }
      }

      // Escuta notificações quando o app está aberto
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _mostrarNotificacao(message);
      });

      // Detecta clique em notificação
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print(
              "🚀 Usuário clicou na notificação: ${message.notification?.title}");
        }
        // Aqui você pode navegar para uma tela específica se quiser
      });
    } else {
      if (kDebugMode) {
        print("🔕 Notificações não autorizadas");
      }
    }
  }

  Future<void> _mostrarNotificacao(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'canal_id',
        'Canal de notificações',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformDetails,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
