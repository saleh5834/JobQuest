import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'models/job.dart';
import 'main.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${MyApp.appName} - Admin Panel'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Consumer<AppProvider>(
                    builder: (context, provider, child) {
                      return FutureBuilder(
                        future: Future.wait([
                          provider.getUserCount(),
                          Future.value(provider.jobs.length),
                          Future.value(provider.pendingJobs.length),
                        ]),
                        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final userCount = snapshot.data![0] as int;
                          final jobCount = snapshot.data![1] as int;
                          final pendingJobCount = snapshot.data![2] as int;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatCard('Users', userCount.toString()),
                              _buildStatCard('Jobs', jobCount.toString()),
                              _buildStatCard('Pending Jobs', pendingJobCount.toString()),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pending Jobs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Consumer<AppProvider>(
                builder: (context, provider, child) {
                  final jobs = provider.pendingJobs;
                  return jobs.isEmpty
                      ? const Center(child: Text('No pending jobs'))
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(job.title),
                          subtitle: Text('Company: ${job.company}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () async {
                                  await provider.approveJob(job);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${job.title} approved')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () async {
                                  await provider.rejectJob(job.id!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${job.title} rejected')),
                                  );
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/job-details', arguments: job);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Approved Jobs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Consumer<AppProvider>(
                builder: (context, provider, child) {
                  final jobs = provider.jobs;
                  return jobs.isEmpty
                      ? const Center(child: Text('No approved jobs'))
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(job.title),
                          subtitle: Text('Company: ${job.company}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await provider.deleteJob(job.id!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${job.title} deleted')),
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/job-details', arguments: job);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    appProvider.logout();
                    Navigator.pushNamedAndRemoveUntil(context, '/role-selection', (route) => false);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text('Logout', style: TextStyle(fontSize: 18, color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}