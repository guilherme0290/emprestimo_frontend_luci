class MensagemTags {
  static const List<Map<String, String>> todas = [
    {"tag": "{{nome}}", "desc": "Nome do cliente"},
    {"tag": "{{primeiro_nome}}", "desc": "Primeiro nome do cliente"},
    {"tag": "{{saudacao}}", "desc": "Saudacao (Bom dia/tarde/noite)"},
    {"tag": "{{numero_parcela}}", "desc": "Número da parcela"},
    {"tag": "{{valor_parcela}}", "desc": "Valor da parcela"},
    {"tag": "{{vencimento}}", "desc": "Data de vencimento (curta)"},
    {"tag": "{{vencimento_extenso}}", "desc": "Data de vencimento (extenso)"},
    {"tag": "{{data_pagamento}}", "desc": "Data do pagamento"},
    {"tag": "{{valor_total}}", "desc": "Valor total do contrato"},
    {"tag": "{{contrato_id}}", "desc": "Id do contrato"},
    {"tag": "{{progresso_parcela}}", "desc": "Número/total de parcelas"},
    {"tag": "{{empresa}}", "desc": "Nome da empresa"},
    {"tag": "{{cobrador}}", "desc": "Nome do cobrador"},
    {"tag": "{{saldo_devedor}}", "desc": "Saldo devedor"},
    {"tag": "{{saldo_em_atraso}}", "desc": "Saldo em atraso"},
    {"tag": "{{total_pago}}", "desc": "Total pago"},
    {"tag": "{{parcelas_em_atraso}}", "desc": "Qtd. parcelas em atraso"},
  ];

  static const Map<String, String> aliases = {
    "primeiroNome": "primeiro_nome",
    "numeroParcela": "numero_parcela",
    "valorParcela": "valor_parcela",
    "valor": "valor_parcela",
    "dataVencimento": "vencimento",
    "data_vencimento": "vencimento",
    "dataPagamento": "data_pagamento",
    "totalContasReceber": "valor_total",
    "numeroContrato": "contrato_id",
    "contratoId": "contrato_id",
    "saldoDevedor": "saldo_devedor",
    "saldoEmAtraso": "saldo_em_atraso",
    "parcelasEmAtraso": "parcelas_em_atraso",
    "saldo_devedor": "saldo_devedor",
    "saldo_em_atraso": "saldo_em_atraso",
  };

  static String normalizarTemplate(String template) {
    String resultado = template;
    aliases.forEach((orig, normalizada) {
      resultado = resultado.replaceAll("{{${orig}}}", "{{${normalizada}}}");
    });
    return resultado;
  }
}
