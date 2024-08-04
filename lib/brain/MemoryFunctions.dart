import 'package:vita_seniors/components/Lang.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MemoryFunctions {
  final LangStrings langStrings = LangStrings();
  String lang = 'es-ES';

  Future<String> readFile(String name) async {
    final appDocumentsDir = await getApplicationDocumentsDirectory();
    final memoryDir = Directory('${appDocumentsDir.path}/assets/memory');

    await memoryDir.create(recursive: true);

    final filePath = '${memoryDir.path}/$name.json';
    final file = File(filePath);

    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString('{}');
    }

    return await file.readAsString();
  }

  Future<void> modifyFile(String name, String newValue) async {
    final appDocumentsDir = await getApplicationDocumentsDirectory();
    final memoryDir = Directory('${appDocumentsDir.path}/assets/memory');
    final file = File('${memoryDir.path}/$name.json');

    // Crea el archivo (si no existe) y escribe el contenido
    await file.writeAsString(newValue);
  }

  Future<void> deleteFile(String name) async {
    final appDocumentsDir = await getApplicationDocumentsDirectory();
    final memoryDir = Directory('${appDocumentsDir.path}/assets/memory');
    final file = File('${memoryDir.path}/$name.json');

    // Elimina el archivo
    await file.delete();
  }
}
