import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../app/legal_content.dart';

typedef GeneratePdf = Future<Uint8List> Function(String title, String body);
typedef SharePdf = Future<void> Function(Uint8List bytes, String filename);

Future<Uint8List> defaultGeneratePdf(String title, String body) async {
  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Text(body),
        ],
      ),
    ),
  );
  return doc.save();
}

Future<void> defaultSharePdf(Uint8List bytes, String filename) async {
  await Printing.sharePdf(bytes: bytes, filename: filename);
}

const _pdfFilename = 'politicas-y-terminos-dcc.pdf';

/// RF-1/RF-2 (spec 008): políticas y términos de uso, con descarga en PDF.
class LegalScreen extends StatefulWidget {
  const LegalScreen({
    super.key,
    this.title = kLegalDocumentTitle,
    this.body = kLegalDocumentBody,
    this.generatePdf = defaultGeneratePdf,
    this.sharePdf = defaultSharePdf,
  });

  final String title;
  final String body;
  final GeneratePdf generatePdf;
  final SharePdf sharePdf;

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  bool _generating = false;

  Future<void> _download() async {
    setState(() => _generating = true);
    try {
      final bytes = await widget.generatePdf(widget.title, widget.body);
      await widget.sharePdf(bytes, _pdfFilename);
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Legal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.title,
            key: const Key('legal-title'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(widget.body, key: const Key('legal-body')),
          const SizedBox(height: 24),
          ElevatedButton(
            key: const Key('download-pdf-button'),
            onPressed: _generating ? null : _download,
            child: Text(_generating ? 'Generando...' : 'Descargar PDF'),
          ),
        ],
      ),
    );
  }
}
