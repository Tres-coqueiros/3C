import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'http://192.168.103.122:3000/api/',
  headers: {
    'Content-Type': 'application/json',
  },
));

void configureDio() {
  final cookieJar = CookieJar();
  dio.interceptors.add(CookieManager(cookieJar));

  dio.interceptors.add(InterceptorsWrapper(
    onResponse: (response, handler) {
      return handler.next(response);
    },
  ));
}
