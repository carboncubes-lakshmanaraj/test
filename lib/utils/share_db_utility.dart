// share_util.dart
import 'dart:io';
import 'dart:ui';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

class ShareUtil {
  static Future<void> shareDatabase() async {
    try {
      await Permission.storage.request();

      Directory? extDir = await getExternalStorageDirectory();
      String dbPath = join(extDir!.path, "SubhaMedicals.db");

      final file = File(dbPath);
      if (await file.exists()) {
        await SharePlus.instance.share(
          ShareParams(
            text: 'Here is the database file.',
            files: [XFile(dbPath)],
            sharePositionOrigin: Rect.fromLTWH(0, 0, 100, 100),
          ),
        );
        print("Database shared successfully.");
      } else {
        print("Database file not found.");
      }
    } catch (e) {
      print("Error sharing database: $e");
    }
  }
}
