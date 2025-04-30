import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:news_app_test/src/core/dio/dio_exception.dart';
import 'package:news_app_test/src/core/loggers/dio_logging_interceptor.dart';
import 'package:news_app_test/src/core/loggers/logger.dart';
import 'package:news_app_test/src/core/network/network_info.dart';
import 'package:news_app_test/src/utils/constants.dart';

import 'result.dart';

class DioClient {
  final NetworkInfo _networkInfo;
  DioClient(this._networkInfo);

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 120), // 120 seconds
      receiveTimeout: const Duration(seconds: 120), // 120 seconds
      headers: {'Accept': "application/json"},
      queryParameters: {'api-key': _APIKey.newsAPIKey},
      baseUrl: BaseUrlConfig._baseUrl,
    ),
  )..interceptors.add(DioLoggingInterceptor());

  Future<Result> get(
    String endPoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    bool internetAvailale = await _networkInfo.isConnected;

    if (internetAvailale) {
      try {
        Response response = await _dio.get(
          endPoint,
          queryParameters: queryParameters,
        );

        return Result.success(response.data);
      } on DioException catch (error) {
        String errorMessage =
            DioExceptions.fromDioError(
              error,
              statusCode: error.response?.statusCode,
            ).message;

        Logger.logError("Default err case sc : ${error.response?.statusCode}");
        Logger.logError("error $error");
        Logger.logError("error.message ${error.message}");

        return Result.error(errorMessage, error.response?.statusCode);
      }
    }
    return Result.networkError('No internet connection');
  }
}

mixin BaseUrlConfig {
  static const String _baseUrl = "https://api.nytimes.com/svc/";

  static String popularNewsPath(PaginationType pagination) =>
      "mostpopular/v2/viewed/${pagination.value}.json";
}

mixin _APIKey {
  static String? get newsAPIKey => dotenv.env['NEWS_API_KEY'];
}