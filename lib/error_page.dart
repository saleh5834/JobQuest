import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'main.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final user = appProvider.currentUser;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 100, color: Colors.redAccent),
                  const SizedBox(height: 20),
                  const Text(
                    '404',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Oops! Page Not Found',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'The page you’re looking for doesn’t exist or something went wrong.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        user == null ? '/role-selection' : (user.isAdmin ? '/admin-home' : '/user-home'),
                            (route) => false,
                      );
                    },
                    child: Text(user == null ? 'Go to Role Selection' : 'Go to Home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}