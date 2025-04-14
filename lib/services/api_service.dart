import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job.dart';

class ApiService {
  static const String baseUrl = 'https://api.example.com'; // Replace with your API URL

  Future<List<Job>> fetchJobs() async {
    final response = await http.get(Uri.parse('$baseUrl/jobs'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((job) => Job.fromMap(job)).toList();
    } else {
      throw Exception('Failed to load jobs');
    }
  }

  Future<void> postJob(Job job) async {
    final response = await http.post(
      Uri.parse('$baseUrl/jobs'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(job.toMap()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to post job');
    }
  }
}