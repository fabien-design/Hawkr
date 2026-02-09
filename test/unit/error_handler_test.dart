import 'package:flutter_test/flutter_test.dart';
import 'package:hawklap/core/utils/error_handler.dart';

void main() {
  group('ErrorHandler.getErrorMessage', () {
    test('extracts message from Supabase-style error string', () {
      final error = Exception(
        'AuthApiError(message: Invalid login credentials, statusCode: 400)',
      );

      final result = ErrorHandler.getErrorMessage(error);

      expect(result, 'Invalid login credentials');
    });

    test('returns fallbackMessage when message pattern not found', () {
      final error = Exception('some random error');

      final result = ErrorHandler.getErrorMessage(
        error,
        fallbackMessage: 'Custom fallback',
      );

      expect(result, 'Custom fallback');
    });

    test('returns default message when no fallback and no pattern match', () {
      final error = Exception('some random error');

      final result = ErrorHandler.getErrorMessage(error);

      expect(result, 'An error occurred');
    });
  });
}
