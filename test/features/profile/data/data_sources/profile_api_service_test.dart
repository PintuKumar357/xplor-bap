import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xplor/const/local_storage/shared_preferences_helper.dart';
import 'package:xplor/features/profile/data/data_sources/profile_api_service.dart';

class _CountAdapter implements HttpClientAdapter {
  _CountAdapter(this.respond);

  final ResponseBody Function(RequestOptions) respond;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<dynamic>? cancelFuture) async =>
      respond(options);

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Dio dio;
  late ProfileApiServiceImpl service;
  late List<RequestOptions> requests;
  dynamic appointmentTotal;
  dynamic orderTotal;
  int appointmentStatus = 200;
  int orderStatus = 200;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'accessToken': 'test-session'});
    final preferences = SharedPreferencesHelper();
    await preferences.init();
    requests = [];
    appointmentTotal = 42;
    orderTotal = 17;
    appointmentStatus = 200;
    orderStatus = 200;
    dio = Dio();
    dio.httpClientAdapter = _CountAdapter((request) {
      requests.add(request);
      final isAppointment = request.uri.path.endsWith('/Appointment/search');
      return ResponseBody.fromString(
        jsonEncode(isAppointment
            ? {'totalCount': appointmentTotal, 'data': [{}]}
            : {
                'data': {'totalCount': orderTotal, 'orders': [{}]},
              }),
        isAppointment ? appointmentStatus : orderStatus,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });
    service = ProfileApiServiceImpl(dio: dio, preferencesHelper: preferences);
  });

  tearDown(() => dio.close(force: true));

  test('uses API totals, not page lengths or profile job/order counts', () async {
    final counts = await service.getActivityCounts('+910000000000');

    expect(counts.appointments, 42);
    expect(counts.orders, 17);
    final appointment = requests.singleWhere((request) => request.method == 'POST');
    expect(appointment.uri.path, '/registry/api/v1/Appointment/search');
    expect(appointment.data, {
      'offset': 0,
      'limit': 1,
      'filters': {'mobile': {'eq': '+910000000000'}},
    });
    final order = requests.singleWhere((request) => request.method == 'GET');
    expect(order.uri.path, '/api/v1/user/orders');
    expect(order.queryParameters, {'page': 1, 'pageSize': 1});
    for (final request in requests) {
      expect(request.headers['Authorization'], 'test-session');
    }
  });

  test('preserves a legitimate zero count', () async {
    appointmentTotal = 0;
    orderTotal = 0;

    final counts = await service.getActivityCounts('+910000000000');

    expect(counts.appointments, 0);
    expect(counts.orders, 0);
  });

  test('accepts numeric string totals', () async {
    appointmentTotal = '12';
    orderTotal = '3';

    final counts = await service.getActivityCounts('+910000000000');

    expect(counts.appointments, 12);
    expect(counts.orders, 3);
  });

  test('keeps orders available when the appointment API fails', () async {
    appointmentStatus = 500;

    final counts = await service.getActivityCounts('+910000000000');

    expect(counts.appointments, isNull);
    expect(counts.orders, 17);
  });

  test('keeps appointments available when the order API fails', () async {
    orderStatus = 500;

    final counts = await service.getActivityCounts('+910000000000');

    expect(counts.appointments, 42);
    expect(counts.orders, isNull);
  });

  test('never requests unfiltered appointments without a phone number', () async {
    final counts = await service.getActivityCounts('   ');

    expect(counts.appointments, isNull);
    expect(counts.orders, 17);
    expect(requests, hasLength(1));
    expect(requests.single.uri.path, '/api/v1/user/orders');
  });

  for (final invalidTotal in [null, -1, 'unknown']) {
    test('does not present invalid total "$invalidTotal" as zero', () async {
      appointmentTotal = invalidTotal;
      orderTotal = invalidTotal;

      final counts = await service.getActivityCounts('+910000000000');

      expect(counts.appointments, isNull);
      expect(counts.orders, isNull);
    });
  }
}