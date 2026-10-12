import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

class CSVHelper {
  String createCsv(List<List<dynamic>> rows) {
    String csv = Csv(autoDetect: false).encode(rows);
    return csv;
  }

  Future<File> saveCsvToFile(String csvData, String fileName) async {
    final directory = (Platform.isMacOS || Platform.isIOS)
        ? await getApplicationDocumentsDirectory()
        : await getDownloadsDirectory();
    final path = '${directory!.path}/$fileName.csv';
    
    final file = File(path);
    List<int> csvBytes = utf8.encode(csvData);
    List<int> bom = [0xEF, 0xBB, 0xBF];
    return await file.writeAsBytes(bom + csvBytes);
  }

  exportToCSV(List<List<dynamic>> rows, String fileName) async {
    final csv = createCsv(rows);
    final file = await saveCsvToFile(csv, fileName);
    return file;
  }
}
