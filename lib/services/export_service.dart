import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

abstract class ExportService {
  Future<void> shareCsv(String csv, String fileName);
}

class SharePlusExportService implements ExportService {
  @override
  Future<void> shareCsv(String csv, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'Finance Tracker export');
  }
}

final exportServiceProvider = Provider<ExportService>((ref) {
  return SharePlusExportService();
});
