import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job.dart';
import '../models/user.dart';
import '../services/database_service.dart';

class AppProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  static const String _baseUrl = 'https://api.example.com';
  List<Job> _jobs = [];
  List<Job> _pendingJobs = [];
  List<User> _pendingAdmins = [];
  User? _currentUser;

  List<Job> get jobs => _jobs;
  List<Job> get pendingJobs => _pendingJobs;
  List<User> get pendingAdmins => _pendingAdmins;
  User? get currentUser => _currentUser;

  AppProvider() {
    _initializeTestData();
  }

  Future<void> _initializeTestData() async {
    final existingJobs = await _dbService.getJobs();
    if (existingJobs.isEmpty) {
      await _dbService.insertPendingJob(Job(
        title: 'Test Job',
        company: 'Test Corp',
        location: 'Remote',
        description: 'A test job for demo purposes, Full-time',
        requirements: 'None',
        salary: '\$50,000',
      ));
    }
    await loadJobs();
    await loadPendingJobs();
    await loadPendingAdmins();
  }

  Future<void> loadJobs() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/jobs'));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        _jobs = jsonResponse.map((job) => Job.fromMap(job)).toList();
      } else {
        _jobs = await _dbService.getJobs();
      }
    } catch (e) {
      _jobs = await _dbService.getJobs();
    }
    notifyListeners();
  }

  Future<void> loadPendingJobs() async {
    _pendingJobs = await _dbService.getPendingJobs();
    notifyListeners();
  }

  Future<void> loadPendingAdmins() async {
    _pendingAdmins = await _dbService.getPendingAdmins();
    notifyListeners();
  }

  Future<void> addPendingJob(Job job) async {
    await _dbService.insertPendingJob(job);
    await loadPendingJobs();
  }

  Future<void> approveJob(Job job) async {
    await _dbService.insertJob(job);
    await _dbService.deletePendingJob(job.id!);
    await loadJobs();
    await loadPendingJobs();
  }

  Future<void> rejectJob(int id) async {
    await _dbService.deletePendingJob(id);
    await loadPendingJobs();
  }

  Future<void> addJob(Job job) async {
    await _dbService.insertJob(job);
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/jobs'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(job.toMap()),
      );
      if (response.statusCode != 201) throw Exception('Failed to post job');
    } catch (e) {
      print('API post failed: $e');
    }
    await loadJobs();
  }

  Future<int> getUserCount() async {
    return await _dbService.getUserCount();
  }

  Future<void> deleteJob(int id) async {
    await _dbService.deleteJob(id);
    await loadJobs();
  }

  Future<bool> login(String email, String password) async {
    _currentUser = await _dbService.getUser(email, password);
    notifyListeners();
    return _currentUser != null;
  }

  Future<void> signUp(User user) async {
    await _dbService.insertUser(user);
    _currentUser = user;
    notifyListeners();
  }

  Future<void> requestAdmin(User user) async {
    await _dbService.insertPendingAdmin(user);
    await loadPendingAdmins();
  }

  Future<void> approveAdmin(User user) async {
    final approvedUser = User(
      name: user.name,
      email: user.email,
      password: user.password,
      imagePath: user.imagePath,
      isAdmin: true,
    );
    await _dbService.insertUser(approvedUser);
    await _dbService.deletePendingAdmin(user.id!);
    await loadPendingAdmins();
  }

  Future<void> rejectAdmin(int id) async {
    await _dbService.deletePendingAdmin(id);
    await loadPendingAdmins();
  }

  Future<void> updateUser(String name, String email, {String? imagePath}) async {
    if (_currentUser != null) {
      final updatedUser = User(
        id: _currentUser!.id,
        name: name,
        email: email,
        password: _currentUser!.password,
        imagePath: imagePath ?? _currentUser!.imagePath,
        isAdmin: _currentUser!.isAdmin,
      );
      await _dbService.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}