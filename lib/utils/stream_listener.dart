import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class SSEService {
  final String url;
  final Function(dynamic data) onDataReceived;
  final Function(dynamic error) onError;

  late Dio _dio;
  late CancelToken _cancelToken;

  SSEService({
    required this.url,
    required this.onDataReceived,
    required this.onError,
  }) {
    _dio = Dio();
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => true;
    };

    _cancelToken = CancelToken();
  }

  void connect() async {
    try {
      Response response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.stream),
        cancelToken: _cancelToken,
      );

      response.data!.stream.transform(utf8.decoder).transform(json.decoder).listen((event) {
        // Handle event data
        onDataReceived(event);
      }, onError: (error) {
        // Handle connection error
        onError(error);
      });
    } catch (e) {
      // Handle Dio error
      onError(e);
    }
  }

  void cancel() {
    _cancelToken.cancel("Cancelled by user");
  }
}
