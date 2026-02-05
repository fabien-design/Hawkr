/// Utility class for handling and formatting error messages
class ErrorHandler {
  /// Extracts a user-friendly error message from exceptions
  /// 
  /// Specifically handles Supabase errors by extracting just the message
  /// portion and removing technical details like status codes and reasons.
  static String getErrorMessage(dynamic error, {String? fallbackMessage}) {
    final defaultMessage = fallbackMessage ?? "An error occurred";
    
    // Convert error to string
    final errorString = error.toString();
    
    // Try to extract the message field from Supabase errors
    // Pattern matches: message: <content> before statusCode or end of string
    final messageMatch = RegExp(
      r'message: ([^,]+(?:, [^,]+)*?)(?:, statusCode:|$)'
    ).firstMatch(errorString);
    
    if (messageMatch != null) {
      return messageMatch.group(1)!.trim();
    }
    
    // Return default message if parsing fails
    return defaultMessage;
  }
}
