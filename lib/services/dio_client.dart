import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';

class DioClient {
  DioClient(this._authService) {
    _dio = Dio();

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final String accessToken = await _authService.getAccessToken();
          debugPrint(accessToken);
          options.headers["Authorization"] = "Bearer $accessToken";
          options.headers["Content-Type"] = "application/json";
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              final newToken = await _authService.getAccessToken(
                forceRefresh: true,
              );
              error.requestOptions.headers["Authorization"] =
                  "Bearer $newToken";

              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
          debugPrint(error.toString());
          return handler.next(error);
        },
      ),
    );
  }
  late Dio _dio;
  final AuthService _authService;

  Dio get dio => _dio;
}
