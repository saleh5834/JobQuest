import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'models/job.dart';
import 'main.dart';

class JobDetailsPage extends StatelessWidget {
  const JobDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Job job = ModalRoute.of(context)!.settings.arguments as Job;
    final appProvider = Provider.of<AppProvider>(context);
    final user = appProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('${MyApp.appName} - Job Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Company: ${job.company}', style: const TextStyle(fontSize: 18)),
                Text('Location: ${job.location}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                Text('Salary: ${job.salary}', style: const TextStyle(fontSize: 16, color: Colors.green)),
                const SizedBox(height: 20),
                const Text('Job Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(job.description, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                const Text('Requirements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(job.requirements, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: user == null
                        ? null
                        : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Applied to ${job.title} as ${user.name}!')),
                      );
                    },
                    child: const Text('Apply Now'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}