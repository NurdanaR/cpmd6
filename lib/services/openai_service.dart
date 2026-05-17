import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../core/nutrition_math.dart';
import '../core/openai_config.dart';
import '../core/errors.dart';
import '../models/daily_nutrition_plan.dart';
import '../models/food_log_entry.dart';

/// Nutrition estimates via OpenAI Chat Completions API (JSON responses).
class OpenAIService {
  OpenAIService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o-mini';

  /// Estimates macros for a product and portion via OpenAI.
  Future<FoodLogEntry> analyzeFood({
    required String name,
    required double grams,
  }) async {
    final prompt = '''
Estimate macronutrients per 100 grams for this food (USDA / common tables).
Food name may be Russian or English (e.g. "гречка", "курица", "rice").
Food: "$name"
User portion: ${grams.toStringAsFixed(0)} g — you return per 100g only; app scales.

Rules:
- Use realistic per-100g values for this exact food.
- For grains/pasta/potatoes assume COOKED unless name says "сухая", "сырая", "dry".
- For "курица" / chicken meat without skin: ~165 kcal/100g, ~31g protein, ~3.6g fat, ~0g carbs.
- For "гречка" cooked: ~92 kcal/100g; dry buckwheat ~343 kcal/100g.
- Do NOT return calories or portion totals — only per 100g macros.

Return JSON only:
{"proteinPer100G": number, "fatPer100G": number, "carbsPer100G": number}
''';

    final json = await _chatJson(prompt);
    final portion = NutritionMath.portionFromPer100(
      proteinPer100G: _num(json['proteinPer100G']),
      fatPer100G: _num(json['fatPer100G']),
      carbsPer100G: _num(json['carbsPer100G']),
      grams: grams,
    );
    return FoodLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      grams: grams,
      calories: portion.calories,
      protein: portion.protein,
      fat: portion.fat,
      carbs: portion.carbs,
      loggedAt: DateTime.now(),
    );
  }

  /// Calculates daily calorie norm and macros from height/weight.
  Future<DailyNutritionPlan> calculateDailyPlan({
    required double heightCm,
    required double weightKg,
    String activityLevel = 'moderate',
  }) async {
    final prompt = '''
Calculate daily nutrition targets for an adult.
Height: ${heightCm.toStringAsFixed(0)} cm
Weight: ${weightKg.toStringAsFixed(1)} kg
Activity: $activityLevel
Use Mifflin-St Jeor BMR × activity factor.

Return JSON only:
{"dailyCalories": number, "proteinG": number, "fatG": number, "carbsG": number, "note": "one short sentence"}
''';

    final json = await _chatJson(prompt);
    final proteinG = _num(json['proteinG']);
    final fatG = _num(json['fatG']);
    final carbsG = _num(json['carbsG']);
    return DailyNutritionPlan(
      dailyCalories: NutritionMath.caloriesFromMacros(proteinG, fatG, carbsG),
      proteinG: proteinG,
      fatG: fatG,
      carbsG: carbsG,
      note: json['note']?.toString(),
    );
  }

  /// Sends a chat completion request and parses JSON from the assistant reply.
  Future<Map<String, dynamic>> _chatJson(String userPrompt) async {
    final key = OpenAIConfig.apiKey;
    if (key == null) {
      throw const DataLoadException(
        'OpenAI API key missing. Add OPENAI_API_KEY to .env',
      );
    }

    final response = await _client
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $key',
          },
          body: jsonEncode({
            'model': _model,
            'messages': [
              {
                'role': 'system',
                'content': 'You are a professional nutritionist. Reply with valid JSON only.',
              },
              {'role': 'user', 'content': userPrompt},
            ],
            'response_format': {'type': 'json_object'},
            'temperature': 0.2,
          }),
        )
        .timeout(AppConstants.networkTimeout);

    if (response.statusCode == 401) {
      throw const DataLoadException('Invalid OpenAI API key (401).');
    }
    if (response.statusCode == 429) {
      throw const DataLoadException('OpenAI rate limit exceeded. Wait and retry.');
    }
    if (response.statusCode != 200) {
      throw DataLoadException('OpenAI request failed (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final content =
        body['choices']?[0]?['message']?['content'] as String?;
    if (content == null || content.isEmpty) {
      throw const DataLoadException('Empty OpenAI response.');
    }
    return _parseJsonObject(content);
  }

  /// Extracts JSON object from assistant text.
  Map<String, dynamic> _parseJsonObject(String raw) {
    var cleaned = raw.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      cleaned = cleaned.replaceFirst(RegExp(r'\s*```$'), '');
    }
    final decoded = jsonDecode(cleaned);
    if (decoded is! Map<String, dynamic>) {
      throw const DataLoadException('Invalid JSON from OpenAI.');
    }
    return decoded;
  }

  double _num(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
