import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = ModalRoute.of(context)!.settings.arguments as String?;
    final isAdminLogin = role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text('${MyApp.appName} - ${isAdminLogin ? 'Admin ' : ''}Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        final provider = Provider.of<AppProvider>(context, listen: false);
                        bool success = await provider.login(
                          _emailController.text,
                          _passwordController.text,
                        );
                        if (success) {
                          if (isAdminLogin) {
                            if (provider.currentUser!.email == 'alif@gmail.com' || provider.currentUser!.isAdmin) {
                              Navigator.pushNamedAndRemoveUntil(context, '/admin-home', (route) => false);
                            } else {
                              await provider.requestAdmin(provider.currentUser!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Admin request sent to permanent admin')),
                              );
                              Navigator.pushNamedAndRemoveUntil(context, '/role-selection', (route) => false);
                            }
                          } else {
                            Navigator.pushNamedAndRemoveUntil(context, '/user-home', (route) => false);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid credentials')),
                          );
                        }
                      },
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup', arguments: role),
                      child: const Text('Don’t have an account? Sign Up', style: TextStyle(color: Colors.teal)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}