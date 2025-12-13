class WhatsappMensagemEnviadaDTO {
  final KeyDTO key;
  final MessageDTO message;
  final String messageTimestamp;
  final String status;

  WhatsappMensagemEnviadaDTO({
    required this.key,
    required this.message,
    required this.messageTimestamp,
    required this.status,
  });

  factory WhatsappMensagemEnviadaDTO.fromJson(Map<String, dynamic> json) {
    return WhatsappMensagemEnviadaDTO(
      key: KeyDTO.fromJson(json['key']),
      message: MessageDTO.fromJson(json['message']),
      messageTimestamp: json['messageTimestamp'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key.toJson(),
      'message': message.toJson(),
      'messageTimestamp': messageTimestamp,
      'status': status,
    };
  }
}

class KeyDTO {
  final String remoteJid;
  final bool fromMe;
  final String id;

  KeyDTO({
    required this.remoteJid,
    required this.fromMe,
    required this.id,
  });

  factory KeyDTO.fromJson(Map<String, dynamic> json) {
    return KeyDTO(
      remoteJid: json['remoteJid'],
      fromMe: json['fromMe'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'remoteJid': remoteJid,
      'fromMe': fromMe,
      'id': id,
    };
  }
}

class MessageDTO {
  final ExtendedTextMessageDTO extendedTextMessage;

  MessageDTO({required this.extendedTextMessage});

  factory MessageDTO.fromJson(Map<String, dynamic> json) {
    return MessageDTO(
      extendedTextMessage:
          ExtendedTextMessageDTO.fromJson(json['extendedTextMessage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'extendedTextMessage': extendedTextMessage.toJson(),
    };
  }
}

class ExtendedTextMessageDTO {
  final String text;

  ExtendedTextMessageDTO({required this.text});

  factory ExtendedTextMessageDTO.fromJson(Map<String, dynamic> json) {
    return ExtendedTextMessageDTO(
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }
}
