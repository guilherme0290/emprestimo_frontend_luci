class WhatsappInstanciaStatusDTO {
  final InstanceStatusDTO instance;

  WhatsappInstanciaStatusDTO({required this.instance});

  factory WhatsappInstanciaStatusDTO.fromJson(Map<String, dynamic> json) {
    return WhatsappInstanciaStatusDTO(
      instance: InstanceStatusDTO.fromJson(json['instance']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instance': instance.toJson(),
    };
  }
}

class InstanceStatusDTO {
  final String instanceName;
  final String state;

  InstanceStatusDTO({
    required this.instanceName,
    required this.state,
  });

  factory InstanceStatusDTO.fromJson(Map<String, dynamic> json) {
    return InstanceStatusDTO(
      instanceName: json['instanceName'],
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instanceName': instanceName,
      'state': state,
    };
  }
}
