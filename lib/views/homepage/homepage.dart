import 'package:flutter/material.dart';
import 'package:metas_academia/views/goals-form/goals_form.dart';
import 'package:metas_academia/views/login-form/login_form.dart';
import '../../models/current_user.dart';
import '../../models/goals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../helper.dart';

class HomePage extends StatefulWidget {
  final CurrentUser currentUser;

  const HomePage({Key? key, required this.currentUser}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Goals'),
        actions: [
          CircleAvatar(
            radius: 15,
            backgroundImage: NetworkImage(widget.currentUser.profilePictureUrl!),
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
            FutureBuilder<List<Goals>>(
              future: fetchGoals(), // Call the function to fetch goals for the current user
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final goalsList = snapshot.data ?? [];
                  // Display the list of goals using the ListView or any other widget
                  return Expanded(
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: goalsList.length,
                        itemBuilder: (context, index) {
                          final goal = goalsList[index];
                          final daysLeft = calculateDaysLeft(goal.startDate, goal.expirationDate);
                          return Padding(
                            padding: const EdgeInsets.only(right: 16, left: 16, bottom: 8),
                            child: Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: Text(goal.name),
                                    subtitle: Text('$daysLeft dias restantes'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(goal.description),
                                  ),
                                  ButtonBar(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          // Implement the logic to view the goal
                                          // For example, navigate to a new page where the user can view the goal details.
                                        },
                                        child: const Text('Abrir meta'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Implement the logic to add progress to the goal
                                          // For example, navigate to a new page where the user can update progress.
                                        },
                                        child: const Text('Adicionar progresso'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );

                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newGoalId = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GoalsForm()),
          );
          if (newGoalId != null) {
            // Fetch the updated list of goals when a new goal is created
            // You can choose to do this in any way that works for your application
            setState(() {
              // Here you can call the function to fetch the updated list of goals or update the list using the newGoalId
              fetchGoals();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
Future<List<Goals>> fetchGoals() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('goals')
        .get();

    final goalsList = snapshot.docs.map((doc) {
      final data = doc.data();
      return Goals(
        name: data['name'],
        description: data['description'],
        startDate: DateTime.parse(data['startDate']),
        expirationDate: DateTime.parse(data['expirationDate']),
        goalValue: data['goalValue'],
      );
    }).toList();

    return goalsList;
  } catch (e) {
    showToast('Error fetching goals: $e');
    return [];
  }
}
