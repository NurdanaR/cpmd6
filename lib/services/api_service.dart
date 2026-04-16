import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fitness_model.dart';

class ApiService {
  final String _url = 'https://jsonplaceholder.typicode.com/posts';

  Future<List<Food>> fetchFood() async {
    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        return data.map((item) => Food.fromJson(item)).take(15).toList();
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }
}