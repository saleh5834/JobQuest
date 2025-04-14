import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'models/job.dart';
import 'main.dart';

class JobListingsPage extends StatefulWidget {
  const JobListingsPage({super.key});

  @override
  _JobListingsPageState createState() => _JobListingsPageState();
}

class _JobListingsPageState extends State<JobListingsPage> {
  String _selectedLocation = 'All';
  String _selectedJobType = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).loadJobs();
    });
  }

  List<Job> _filterJobs(List<Job> jobs) {
    return jobs.where((job) {
      final matchesLocation = _selectedLocation == 'All' || job.location == _selectedLocation;
      final matchesJobType = _selectedJobType == 'All' ||
          (_selectedJobType == 'Full-time' && job.description.contains('Full-time')) ||
          (_selectedJobType == 'Part-time' && job.description.contains('Part-time'));
      return matchesLocation && matchesJobType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${MyApp.appName} - Job Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sort feature not implemented yet')),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final filteredJobs = _filterJobs(provider.jobs);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedLocation,
                        decoration: const InputDecoration(labelText: 'Location'),
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('All')),
                          DropdownMenuItem(value: 'Remote', child: Text('Remote')),
                          DropdownMenuItem(value: 'On-site', child: Text('On-site')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedLocation = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedJobType,
                        decoration: const InputDecoration(labelText: 'Job Type'),
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('All')),
                          DropdownMenuItem(value: 'Full-time', child: Text('Full-time')),
                          DropdownMenuItem(value: 'Part-time', child: Text('Part-time')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedJobType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredJobs.isEmpty
                    ? const Center(child: Text('No jobs available'))
                    : ListView.builder(
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = filteredJobs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: ListTile(
                        title: Text(job.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.company),
                            Text('Location: ${job.location}'),
                            Text(job.description.length > 50
                                ? '${job.description.substring(0, 50)}...'
                                : job.description),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.pushNamed(context, '/job-details', arguments: job);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}