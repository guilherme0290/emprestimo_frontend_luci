import 'whatsapp_instance_connect.dart';

class WhatsappConexaoResponseDTO {
  final InstanceDTO instance;
  final WhatsappInstanceConnect qrcode;

  WhatsappConexaoResponseDTO({
    required this.instance,
    required this.qrcode,
  });

  factory WhatsappConexaoResponseDTO.fromJson(Map<String, dynamic> json) {
    return WhatsappConexaoResponseDTO(
      instance: InstanceDTO.fromJson(json['instance']),
      qrcode: WhatsappInstanceConnect.fromJson(json['qrcode']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instance': instance.toJson(),
      'qrcode': qrcode.toJson(),
    };
  }
}

class InstanceDTO {
  final String instanceName;
  final String instanceId;
  final String? webhookWaBusiness;
  final String? accessTokenWaBusiness;
  final String status;

  InstanceDTO({
    required this.instanceName,
    required this.instanceId,
    this.webhookWaBusiness,
    this.accessTokenWaBusiness,
    required this.status,
  });

  factory InstanceDTO.fromJson(Map<String, dynamic> json) {
    return InstanceDTO(
      instanceName: json['instanceName'],
      instanceId: json['instanceId'],
      webhookWaBusiness: json['webhook_wa_business'],
      accessTokenWaBusiness: json['access_token_wa_business'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instanceName': instanceName,
      'instanceId': instanceId,
      'webhook_wa_business': webhookWaBusiness,
      'access_token_wa_business': accessTokenWaBusiness,
      'status': status,
    };
  }
}
