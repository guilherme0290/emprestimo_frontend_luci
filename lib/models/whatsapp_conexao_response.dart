import 'package:emprestimos_app/models/whatsapp_codigo_conexao.dart';

class WhatsappConexaoResponse {
  final WhatsappConexaoInstance instance;
  final WhatsappCodigoConexao? qrcode;

  WhatsappConexaoResponse({
    required this.instance,
    this.qrcode,
  });

  factory WhatsappConexaoResponse.fromJson(Map<String, dynamic> json) {
    return WhatsappConexaoResponse(
      instance: WhatsappConexaoInstance.fromJson(
          json['instance'] as Map<String, dynamic>),
      qrcode: json['qrcode'] is Map<String, dynamic>
          ? WhatsappCodigoConexao.fromJson(
              json['qrcode'] as Map<String, dynamic>)
          : null,
    );
  }
}

class WhatsappConexaoInstance {
  final String? instanceName;
  final String? instanceId;
  final String? status;

  WhatsappConexaoInstance({
    this.instanceName,
    this.instanceId,
    this.status,
  });

  factory WhatsappConexaoInstance.fromJson(Map<String, dynamic> json) {
    return WhatsappConexaoInstance(
      instanceName: json['instanceName'] as String?,
      instanceId: json['instanceId'] as String?,
      status: json['status'] as String?,
    );
  }
}
