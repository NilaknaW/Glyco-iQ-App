import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> generateGlucosePDF(List<Map<String, dynamic>> history) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Glucose History (Last 30 Days)',
              style: pw.TextStyle(fontSize: 20)),
          pw.SizedBox(height: 10),
          ...history.map((entry) => pw.Text(
              '${entry['date']} ${entry['time']} - ${entry['glucose']}')),
        ],
      ),
    ),
  );

  final outputDir = await getTemporaryDirectory();
  final file = File("${outputDir.path}/glucose_history.pdf");
  await file.writeAsBytes(await pdf.save());
  return file;
}
