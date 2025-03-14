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
  dio.interceptors.add(CookieManager(
      cookieJar)); // Usando cookies para gerenciar tokens de forma segura

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Se o token estiver armazenado em cookies, ele será automaticamente enviado
      // Certifique-se de que os cookies estão sendo gerenciados corretamente no backend
      return handler.next(options);
    },
    onResponse: (response, handler) {
      return handler.next(response);
    },
    onError: (DioError error, handler) {
      if (error.response?.statusCode == 401) {
        // Lógica para lidar com erro de autenticação (ex: renovar o token ou redirecionar para login)
      }
      return handler.next(error);
    },
  ));
}

void configureDio() {
  final cookieJar = CookieJar();
  addInterceptors(dioSenior, cookieJar);
  addInterceptors(dioAgrimanager, cookieJar);
}
