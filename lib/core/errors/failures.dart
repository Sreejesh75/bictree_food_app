import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

/// Typed failure base class ensuring no raw unhandled exceptions reach the UI.
abstract class Failure extends Equatable implements Exception {
  final String message;
  final String code;
  final dynamic originalError;

  const Failure({
    required this.message,
    required this.code,
    this.originalError,
  });

  @override
  String toString() => '$code: $message';

  @override
  List<Object?> get props => [message, code];
}

/// Emitted when device is offline, DNS lookup fails, or network is unreachable.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection detected. Please check your Wi-Fi or cellular network.',
    super.code = 'NETWORK_OFFLINE',
    super.originalError,
  });
}

/// Emitted when HTTP response returns 5xx, 4xx, or malformed JSON payloads.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    super.message = 'Food server is temporarily unavailable. Please try again shortly.',
    super.code = 'SERVER_ERROR',
    this.statusCode,
    super.originalError,
  });

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Emitted when local Hive/storage operations fail.
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to load local offline food menu.',
    super.code = 'CACHE_ERROR',
    super.originalError,
  });
}

/// Emitted when network request times out.
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timed out while connecting to the kitchen. Please try again.',
    super.code = 'REQUEST_TIMEOUT',
    super.originalError,
  });
}

/// Fallback for unexpected anomalies.
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Something unexpected happened. Please try again.',
    super.code = 'UNKNOWN_ERROR',
    super.originalError,
  });
}

/// Helper function to transform raw Dart/HTTP exceptions into typed [Failure] instances.
Failure mapExceptionToFailure(dynamic error) {
  if (error is Failure) {
    return error;
  }
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure(
          message: 'Connection timed out. Please check your internet connection.',
          originalError: error,
        );
      case DioExceptionType.connectionError:
        return NetworkFailure(
          message: 'Unable to connect to the server. Please check your internet connection.',
          originalError: error,
        );
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode ?? 500;
        String? message;
        if (error.response?.data is Map) {
          message = error.response?.data['message']?.toString();
        }
        return ServerFailure(
          statusCode: status,
          message: message ?? 'Server returned error status: $status',
          originalError: error,
        );
      case DioExceptionType.cancel:
        return UnknownFailure(
          message: 'Request was cancelled.',
          originalError: error,
        );
      default:
        return NetworkFailure(
          message: 'Network error occurred. Please try again.',
          originalError: error,
        );
    }
  }
  if (error is SocketException ||
      error.toString().contains('SocketException') ||
      error.toString().contains('Failed host lookup') ||
      error.toString().contains('Network is unreachable')) {
    return NetworkFailure(originalError: error);
  }
  if (error is TimeoutException ||
      error.toString().contains('TimeoutException')) {
    return TimeoutFailure(originalError: error);
  }
  if (error is http.ClientException ||
      error.toString().contains('ClientException')) {
    return NetworkFailure(originalError: error);
  }
  if (error is FormatException ||
      error.toString().contains('FormatException')) {
    return ServerFailure(
      message: 'Invalid data format received from server.',
      originalError: error,
    );
  }

  final cleanMessage = error.toString().replaceAll('Exception: ', '').trim();
  return UnknownFailure(
    message: cleanMessage.isNotEmpty
        ? cleanMessage
        : 'An unexpected issue occurred.',
    originalError: error,
  );
}
