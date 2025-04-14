import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'models/user.dart';
import 'main.dart';

class PendingAdminPage extends StatelessWidget {
  const PendingAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${MyApp.appName} - Pending Admins'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pending Admin Requests',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, child) {
                  final admins = provider.pendingAdmins;
                  return admins.isEmpty
                      ? const Center(child: Text('No pending admin requests'))
                      : ListView.builder(
                    itemCount: admins.length,
                    itemBuilder: (context, index) {
                      final admin = admins[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(admin.name),
                          subtitle: Text('Email: ${admin.email}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () async {
                                  await provider.approveAdmin(admin);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${admin.name} approved as admin')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () async {
                                  await provider.rejectAdmin(admin.id!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${admin.name} rejected')),
                                  );
                                },
                              ),
                            ],
                          ),
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