import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

Dio createDio(String baseUrl) {
  return Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {
      'Content-Type': 'application/json',
    },
  ));
}

// final dioSenior = createDio('http://172.16.5.178:5175/senior/');
// final dioAgrimanager = createDio('http://172.16.5.178:5175/agrimanager/');
final dioSenior = createDio('http://192.168.103.251:3002/senior/');
final dioAgrimanager = createDio('http://192.168.103.251:3002/agrimanager/');

void addInterceptors(Dio dio, CookieJar cookieJar) {
  dio.interceptors.add(CookieManager(cookieJar));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      return handler.next(options);
    },
    onResponse: (response, handler) {
      return handler.next(response);
    },
    onError: (DioError error, handler) {
      if (error.response?.statusCode == 401) {}
      return handler.next(error);
    },
  ));
}

void configureDio() {
  final cookieJar = CookieJar();
  addInterceptors(dioSenior, cookieJar);
  addInterceptors(dioAgrimanager, cookieJar);
}
