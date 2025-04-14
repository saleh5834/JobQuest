import 'package:flutter/material.dart';
import 'main.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.work, size: 100, color: Colors.teal),
              const SizedBox(height: 20),
              Text(
                MyApp.appName,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 40),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Choose Your Role',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/login', arguments: 'user'),
                            child: const Text('User'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/login', arguments: 'admin'),
                            child: const Text('Admin'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}