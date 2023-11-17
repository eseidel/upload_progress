import "dart:io";

main() async {
  HttpClientRequest request =
      await HttpClient().post('localhost', 8000, '/upload');

  request.headers.contentType = ContentType.binary;

  final path = 'big_file.txt';
  if (!File(path).existsSync()) {
    File(path).writeAsString("big file\n" * 10000000, flush: true);
  }

  final file = File(path);
  final stream = file.openRead();
  final FileStat stat = await file.stat();
  var uploaded = 0;

  await request.addStream(stream.map((chunk) {
    uploaded += chunk.length;
    print("Uploaded ${((uploaded / stat.size) * 100.0).toStringAsFixed(2)}%");
    return chunk;
  }));

  request.close();
}
