import 'package:local_auth/local_auth.dart';

class BiometriaHelper {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> autenticarComBiometria() async {
    final bool canCheck = await auth.canCheckBiometrics;
    final bool isSupported = await auth.isDeviceSupported();

    if (!canCheck || !isSupported) return false;

    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Use sua biometria para continuar',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      throw Exception(e);      
    }
  }
}
