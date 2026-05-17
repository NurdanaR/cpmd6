import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/fitness_model.dart';
import 'food_remote_source.dart';

/// Fetches nutrition-like data from JSONPlaceholder REST API.
class ApiService implements FoodRemoteSource {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _url = 'https://jsonplaceholder.typicode.com/posts';

  /// Loads up to 15 food items mapped from remote posts.
  @override
  Future<List<Food>> fetchFoods() async {
    final response = await _client
        .get(Uri.parse(_url))
        .timeout(AppConstants.networkTimeout);

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    final data = json.decode(response.body) as List<dynamic>;
    return data.map((item) => Food.fromJson(item as Map<String, dynamic>)).take(15).toList();
  }
}
