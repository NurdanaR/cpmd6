import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads OpenAI API key from `.env` or compile-time define.
class OpenAIConfig {
  OpenAIConfig._();

  /// Returns API key or null if not configured.
  static String? get apiKey {
    final fromEnv = dotenv.env['OPENAI_API_KEY']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;

    const fromDefine = String.fromEnvironment('OPENAI_API_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;

    return null;
  }

  /// True when a key is available for OpenAI requests.
  static bool get isConfigured => apiKey != null && apiKey!.isNotEmpty;
}
