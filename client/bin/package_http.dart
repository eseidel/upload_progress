import 'dart:io';

import 'package:http/http.dart';

main() async {
  final path = 'big_file.txt';
  if (!File(path).existsSync()) {
    File(path).writeAsString("big file\n" * 10000000, flush: true);
  }

  final file = File(path);
  final FileStat stat = file.statSync();
  final length = stat.size;
  var uploaded = 0;

  var stream = file.openRead().map((chunk) {
    uploaded += chunk.length;
    print("Uploaded ${((uploaded / length) * 100.0).toStringAsFixed(2)}%");
    return chunk;
  });
  final multipartFile = MultipartFile('file', stream, length, filename: path);

  final uri = Uri.http('localhost:8000', 'upload');
  var request = MultipartRequest('POST', uri)..files.add(multipartFile);
  var response = await request.send();
  if (response.statusCode == 200) print('Uploaded!');
}
