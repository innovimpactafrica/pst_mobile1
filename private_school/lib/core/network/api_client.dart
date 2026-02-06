import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../storage/secure_storage.dart';
import '../utils/base_url.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  final SecureStorage _storage = SecureStorage();

  Dio get dio => _dio;

  Future<void> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: BaseUrl.current,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add JWT token automatically to requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint('🔑 Token added to request: ${options.path}');
          } else {
            debugPrint('⚠️ No token found for request: ${options.path}');
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          debugPrint('❌ API Error: ${error.response?.statusCode} - ${error.message}');
          
          // Handle token expiration
          if (error.response?.statusCode == 401) {
            debugPrint('🔒 Unauthorized - Clearing storage');
            await _storage.clearAll();
          }
          return handler.next(error);
        },
        onResponse: (response, handler) {
          debugPrint('✅ API Response: ${response.statusCode} - ${response.requestOptions.path}');
          return handler.next(response);
        },
      ),
    );

    // Logger for debugging
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      Map<String, dynamic>? mergedQueryParams = queryParameters;
      
      if (data != null && data is Map<String, dynamic>) {
        mergedQueryParams = {...?queryParameters, ...data};
      }

      return await _dio.delete(
        path,
        data: data,
        queryParameters: mergedQueryParams,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Clean error handling without nested exceptions
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Délai de connexion dépassé';
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        
        // Extract error message from response
        String message = 'Erreur serveur';
        
        if (responseData is Map<String, dynamic>) {
          message = responseData['error'] ?? 
                    responseData['message'] ?? 
                    responseData['msg'] ?? 
                    'Erreur serveur';
        } else if (responseData is String) {
          message = responseData;
        }
        
        switch (statusCode) {
          case 400:
            return 'Requête invalide: $message';
          case 401:
            return 'Non autorisé: $message';
          case 403:
            return 'Accès interdit: $message';
          case 404:
            // User-friendly message for not found errors
            if (message.contains('User not found')) {
              return 'Email ou mot de passe incorrect';
            }
            return 'Ressource introuvable: $message';
          case 500:
            return 'Erreur serveur: $message';
          default:
            return message;
        }
        
      case DioExceptionType.cancel:
        return 'Requête annulée';
        
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return 'Pas de connexion internet';
        }
        return 'Erreur inconnue: ${error.message}';
        
      default:
        return 'Erreur: ${error.message}';
    }
  }
}