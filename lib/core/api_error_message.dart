/// Converts API/exception text to a short user-facing message.
String shortApiErrorMessage(Object error) {
  final text = error.toString();
  if (text.contains('429') || text.contains('rate limit') || text.contains('quota')) {
    return 'OpenAI rate limit exceeded. Wait a minute and try again, or check billing at platform.openai.com.';
  }
  if (text.contains('401') || text.contains('Incorrect API key')) {
    return 'Invalid OpenAI API key. Check OPENAI_API_KEY in .env file.';
  }
  if (text.contains('404') || text.contains('not found')) {
    return 'OpenAI endpoint error. Check your API key and internet connection.';
  }
  if (text.contains('API key')) {
    return 'Invalid or missing OpenAI API key. Add OPENAI_API_KEY to .env.';
  }
  if (text.contains('403')) {
    return 'OpenAI access denied. Check API key permissions.';
  }
  if (text.contains('{') && text.contains('error')) {
    return 'OpenAI API error. Check API key and billing.';
  }
  if (text.length > 120) {
    return '${text.substring(0, 117)}...';
  }
  return text.replaceFirst('Exception: ', '').replaceFirst('DataLoadException: ', '');
}
