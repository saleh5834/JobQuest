import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'models/job.dart';
import 'main.dart';

class EmployerDashboard extends StatefulWidget {
  const EmployerDashboard({super.key});

  @override
  _EmployerDashboardState createState() => _EmployerDashboardState();
}

class _EmployerDashboardState extends State<EmployerDashboard> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _salaryController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  void _showPostJobDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Submit Job for Review'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Job Title'),
                ),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: _requirementsController,
                  decoration: const InputDecoration(labelText: 'Requirements'),
                ),
                TextField(
                  controller: _salaryController,
                  decoration: const InputDecoration(labelText: 'Salary'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final provider = Provider.of<AppProvider>(context, listen: false);
                final user = provider.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please log in to submit a job')),
                  );
                  Navigator.pop(context);
                  return;
                }
                final job = Job(
                  title: _titleController.text,
                  company: user.name,
                  location: _locationController.text,
                  description: _descriptionController.text,
                  requirements: _requirementsController.text,
                  salary: _salaryController.text,
                );
                await provider.addPendingJob(job);
                Navigator.pop(context);
                _titleController.clear();
                _locationController.clear();
                _descriptionController.clear();
                _requirementsController.clear();
                _salaryController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Job submitted for admin review')),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final user = appProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('${MyApp.appName} - Employer Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Employer: ${user?.name ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Submit jobs for review and manage postings.',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showPostJobDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Submit New Job'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pending Jobs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, child) {
                  final postedJobs = provider.pendingJobs
                      .where((job) => job.company == user?.name)
                      .toList();
                  return postedJobs.isEmpty
                      ? const Center(child: Text('No pending jobs'))
                      : ListView.builder(
                    itemCount: postedJobs.length,
                    itemBuilder: (context, index) {
                      final job = postedJobs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(job.title),
                          subtitle: const Text('Status: Pending Review'),
                          onTap: () {
                            Navigator.pushNamed(context, '/job-details', arguments: job);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}