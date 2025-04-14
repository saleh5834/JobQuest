import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'providers/app_provider.dart';
import 'models/job.dart';
import 'main.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(AppProvider provider) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/profile_${provider.currentUser!.id}.jpg';
      await File(image.path).copy(imagePath);
      await provider.updateUser(
        provider.currentUser!.name,
        provider.currentUser!.email,
        imagePath: imagePath,
      );
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final user = appProvider.currentUser;

    if (user == null) return;

    _nameController.text = user.name;
    _emailController.text = user.email;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = _nameController.text.trim();
                final newEmail = _emailController.text.trim();
                if (newName.isEmpty || newEmail.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All fields are required')),
                  );
                  return;
                }
                await appProvider.updateUser(newName, newEmail);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated')),
                );
              },
              child: const Text('Save'),
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
        title: Text('${MyApp.appName} - My Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _pickImage(appProvider),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: user?.imagePath != null
                              ? FileImage(File(user!.imagePath!))
                              : const NetworkImage('https://via.placeholder.com/150') as ImageProvider,
                          child: user?.imagePath == null
                              ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user?.name ?? 'Guest',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user?.email ?? 'No email',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _showEditProfileDialog(context),
                        child: const Text('Edit Profile'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Applied Jobs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Consumer<AppProvider>(
                builder: (context, provider, child) {
                  final appliedJobs = provider.jobs.take(2).toList();
                  return appliedJobs.isEmpty
                      ? const Center(child: Text('No applied jobs yet'))
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appliedJobs.length,
                    itemBuilder: (context, index) {
                      final job = appliedJobs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(job.title),
                          subtitle: Text('${job.company} • Applied on: 04/04/2025'),
                          trailing: const Icon(Icons.check_circle, color: Colors.green),
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
}