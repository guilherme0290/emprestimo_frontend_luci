import 'dart:io';
import 'dart:typed_data';

import 'package:emprestimos_app/core/data_utils.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/emprestimo.dart';
import 'package:emprestimos_app/models/parcela.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class RelatorioParcelasPdfService {
  static Future<Uint8List> gerarPdf(ContasReceberDTO emprestimo) async {
    final pdf = pw.Document();
    final parcelasOrdenadas = List<ParcelaDTO>.from(emprestimo.parcelas)
      ..sort((a, b) => a.numeroParcela.compareTo(b.numeroParcela));

    final totalParcelas = parcelasOrdenadas.length;
    final atrasadas =
        parcelasOrdenadas.where((p) => p.status == "ATRASADA").length;
    final pendentes =
        parcelasOrdenadas.where((p) => p.status == "PENDENTE").length;
    final pagas = parcelasOrdenadas.where((p) => p.status == "PAGA").length;
    final valorTotalParcelas =
        parcelasOrdenadas.fold(0.0, (sum, p) => sum + p.valor);
    final valorPago = parcelasOrdenadas.fold(
      0.0,
      (sum, p) => sum + (p.baixas ?? []).fold(0.0, (s, b) => s + b.valor),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            "Relatorio de parcelas",
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          _linhaInfo("Contrato", "#${emprestimo.id}"),
          _linhaInfo("Cliente", emprestimo.cliente.nome ?? "Nao informado"),
          _linhaInfo(
              "Telefone", emprestimo.cliente.telefone ?? "Nao informado"),
          _linhaInfo("Data do contrato", emprestimo.dataContrato),
          _linhaInfo("Status", emprestimo.statusContasReceber),
          _linhaInfo(
              "Valor do contrato", Util.formatarMoeda(emprestimo.valor)),
          pw.SizedBox(height: 12),
          pw.Text(
            "Resumo",
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              _boxResumo("Total", totalParcelas.toString()),
              _boxResumo("Pendentes", pendentes.toString()),
              _boxResumo("Atrasadas", atrasadas.toString()),
              _boxResumo("Pagas", pagas.toString()),
            ],
          ),
          pw.SizedBox(height: 6),
          _linhaInfo(
              "Valor total das parcelas", Util.formatarMoeda(valorTotalParcelas)),
          _linhaInfo("Valor pago", Util.formatarMoeda(valorPago)),
          _linhaInfo(
            "Saldo em aberto",
            Util.formatarMoeda(valorTotalParcelas - valorPago),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            "Parcelas",
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.2),
              1: const pw.FlexColumnWidth(2.5),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _cellHeader("Parcela"),
                  _cellHeader("Vencimento"),
                  _cellHeader("Status"),
                  _cellHeader("Valor"),
                  _cellHeader("Pago"),
                ],
              ),
              ...parcelasOrdenadas.map((parcela) {
                final pagoParcela = (parcela.baixas ?? [])
                    .fold(0.0, (sum, b) => sum + b.valor);
                return pw.TableRow(
                  children: [
                    _cell("${parcela.numeroParcela}"),
                    _cell(FormatData.formatarDataCompleta(parcela.dataVencimento)),
                    _cell(parcela.status),
                    _cell(Util.formatarMoeda(parcela.valor)),
                    _cell(Util.formatarMoeda(pagoParcela)),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<File> salvarPdf(ContasReceberDTO emprestimo) async {
    final bytes = await gerarPdf(emprestimo);
    final dir = await getTemporaryDirectory();
    final file =
        File("${dir.path}/relatorio_parcelas_${emprestimo.id}.pdf");
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static pw.Widget _linhaInfo(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Text(
            "$label: ",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  static pw.Widget _boxResumo(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        margin: const pw.EdgeInsets.only(right: 6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: 0.5, color: PdfColors.grey400),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _cellHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      ),
    );
  }

  static pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }
}
