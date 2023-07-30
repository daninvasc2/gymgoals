import 'package:flutter/material.dart';
import 'package:metas_academia/views/goals-form/goals_form.dart';
import 'package:metas_academia/views/login-form/login_form.dart';
import '../../models/current_user.dart';

class HomePage extends StatelessWidget {
  final CurrentUser currentUser;

  const HomePage({super.key, required this.currentUser});

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Goals'),
        actions: [
          CircleAvatar(
            radius: 15,
            backgroundImage: NetworkImage(currentUser.profilePictureUrl!),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginForm()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bem-vindo(a), ${currentUser.name}!'),
            Text('Seu e-mail é ${currentUser.email}.'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GoalsForm()),
                );
              },
             child: const Text('Criar nova meta'),
            )
          ],
        ),
      )
    );
  }
}