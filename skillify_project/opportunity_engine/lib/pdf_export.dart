import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'state.dart';

// Note: the built-in PDF fonts support Latin characters only.

final _accent = PdfColor.fromInt(0xFF9A6B0A);

pw.Widget _heading(String t) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 14, bottom: 4),
      child: pw.Text(t.toUpperCase(),
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _accent)),
    );

pw.Widget _entry(Entry e) {
  final head = [e.title, e.org].where((s) => s.trim().isNotEmpty).join(' - ');
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Expanded(
            child: pw.Text(head, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11))),
        if (e.dates.trim().isNotEmpty) pw.Text(e.dates, style: const pw.TextStyle(fontSize: 10)),
      ]),
      if (e.details.trim().isNotEmpty) pw.Text(e.details, style: const pw.TextStyle(fontSize: 10)),
    ]),
  );
}

Future<Uint8List> buildResumePdf(Resume r) async {
  final doc = pw.Document();
  final contact = [r.email, r.phone, r.location, r.links].where((s) => s.trim().isNotEmpty).join('   |   ');
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(36),
    build: (ctx) => [
      pw.Text(r.name.isEmpty ? 'Your Name' : r.name,
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
      if (r.headline.trim().isNotEmpty)
        pw.Text(r.headline, style: pw.TextStyle(fontSize: 13, color: _accent)),
      if (contact.isNotEmpty)
        pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text(contact, style: const pw.TextStyle(fontSize: 10))),
      pw.Divider(),
      if (r.summary.trim().isNotEmpty) ...[
        _heading('Summary'),
        pw.Text(r.summary, style: const pw.TextStyle(fontSize: 10.5)),
      ],
      if (r.skills.isNotEmpty) ...[
        _heading('Skills'),
        pw.Text(r.skills.join(', '), style: const pw.TextStyle(fontSize: 10.5)),
      ],
      if (r.experience.isNotEmpty) ...[
        _heading('Experience'),
        ...r.experience.map(_entry),
      ],
      if (r.projects.isNotEmpty) ...[
        _heading('Projects'),
        ...r.projects.map(_entry),
      ],
      if (r.education.isNotEmpty) ...[
        _heading('Education'),
        ...r.education.map(_entry),
      ],
    ],
  ));
  return doc.save();
}

Future<Uint8List> buildLetterPdf(String text, String name) async {
  final doc = pw.Document();
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(50),
    build: (ctx) => [
      ...text.split('\n').map((line) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text(line, style: const pw.TextStyle(fontSize: 11.5, lineSpacing: 3)),
          )),
    ],
  ));
  return doc.save();
}

Future<void> sharePdf(Uint8List bytes, String filename) =>
    Printing.sharePdf(bytes: bytes, filename: filename);
