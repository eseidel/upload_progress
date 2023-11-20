import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final path = 'big_file.txt';
  if (!File(path).existsSync()) {
    File(path).writeAsString("big file\n" * 10000000, flush: true);
  }

  final multipartFile = await http.MultipartFile.fromPath('file', path);
  final uri = Uri.http('localhost:8000', 'upload');
  final request = MultipartRequest('POST', uri, onProgress: (bytes, total) {
    print('Uploaded ${((bytes / total) * 100.0).toStringAsFixed(2)}%');
  })
    ..files.add(multipartFile);
  print('sending request');
  final response = await request.send();
  if (response.statusCode == 200) print('Uploaded!');
}

class MultipartRequest extends http.MultipartRequest {
  MultipartRequest(
    String method,
    Uri url, {
    this.onProgress,
  }) : super(method, url);

  final void Function(int bytes, int totalBytes)? onProgress;

  @override
  http.ByteStream finalize() {
    if (onProgress == null) return super.finalize();
    final byteStream = super.finalize();

    final totalBytes = contentLength;
    var bytes = 0;

    final transformer = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress?.call(bytes, totalBytes);
        sink.add(data);
      },
    );
    return http.ByteStream(byteStream.transform(transformer));
  }
}
