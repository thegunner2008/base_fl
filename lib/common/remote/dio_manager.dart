import 'package:EMO/common/config/config.dart';
import 'package:EMO/common/di/injector.dart';
import 'package:EMO/common/generated/l10n.dart';
import 'package:EMO/common/service/service.dart';
import 'package:EMO/common/theme/theme.dart';
import 'package:EMO/common/utils/utils.dart';
import 'package:dio/dio.dart';

import '../store/store.dart';

class DioManager {
  static getDio({required bool showDefaultError}) {
    String baseUrl = BuildMode.current.baseUrl;

    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      headers: getAuthorizationHeader(),
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout:  const Duration(seconds: 20),
    );

    Dio dio = Dio(options);

    dio.interceptors.add(CustomInterceptor(showDefaultError));

    return dio;
  }

  static Map<String, String> getAuthorizationHeader() {
    var headers = <String, String>{};
    headers['Accept'] = 'application/json';
    headers['Content-Type'] = 'application/json';
    if (AppInjector.injector.isRegistered<UserStore>() && UserStore.to.hasToken) {
      headers['Authorization'] = 'Bearer ${UserStore.to.accessToken}';
    }
    return headers;
  }
}

class CustomInterceptor implements Interceptor {
  bool showDefaultError;

  CustomInterceptor(this.showDefaultError) : super();

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    Logger.write('onError ${err.requestOptions.uri} - ${err.message}');
    handleError(err);
    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Logger.write('onResponse ${response.requestOptions.uri} - ${response.data}');
    if (response.data['code'] != null && !['200', '000'].contains(response.data['code'])) {
      Logger.write('onError ${response.data['code']} - ${response.data['message']}');
      handler.reject(DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: response.data['message'],
      ));
      return;
    }
    AnalyticsService.to.logApiResponse(
      response.requestOptions.uri.toString(),
      response.toString(),
    );
    if (response.data['data'] != null && response.data['data'] is! List) {
      response.data = response.data['data'];
      handler.next(response);
    } else {
      handler.next(response);
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final logs = <String>[
      '${options.method} ${options.uri}',
      if (options.queryParameters.isNotEmpty) 'Query: ${options.queryParameters}',
      if (options.data.isNotEmpty) 'Body: ${options.data}',
    ];

    final msg = logs.join('\n');

    Logger.write(msg);

    handler.next(options);
  }

  void handleError(DioError err) {
    AnalyticsService.to.logApiError(
      err.requestOptions.uri.toString(),
      err.message ?? "unknown",
    );
    int? statusCode = err.response?.statusCode;
    String title = "${S.current.Loi} ${statusCode ?? ""}";
    String message = "";
    if (statusCode == 403 && !err.requestOptions.path.contains("login")) {
      UserStore.to.switchStatusLogin(false);
      UserStore.to.onLogout();
      message = S.current.Het_phien_lam_viec;
    } else {
      message = err.response?.data['message'] ?? err.message;
    }
    Loading.dismiss();
    if (showDefaultError && message.isNotEmpty) {
      debugConsoleLog("showDefaultError ${err.response} $message");
      CustomSnackBar.error(title: title, message: message);
    }
  }
}
