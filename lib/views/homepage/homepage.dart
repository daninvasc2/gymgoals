import 'dart:io';

import 'package:flutter/material.dart';
import 'package:metas_academia/views/goals-form/goals_form.dart';
import 'package:metas_academia/views/login-form/login_form.dart';
import '../../models/current_user.dart';
import '../../models/goals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomePage extends StatefulWidget {
  final CurrentUser currentUser;

  const HomePage({Key? key, required this.currentUser}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _refreshPage() {
    setState(() {}); // Trigger widget rebuild
  }
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
              future: fetchGoals(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final goalsList = snapshot.data ?? [];
                  return Expanded(
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: goalsList.length,
                        itemBuilder: (context, index) {
                          final goal = goalsList[index];
                          final today = DateTime.now();
                          final daysLeft = calculateDaysLeft(today, goal.expirationDate);
                          return Padding(
                            padding: const EdgeInsets.only(right: 16, left: 16, bottom: 8),
                            child: Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                          title: Text(goal.name),
                                          subtitle: Text('$daysLeft dias restantes'),
                                        ),
                                      ),
                                      FutureBuilder<num>(
                                        future: countProgressOfGoal(goal.id!, widget.currentUser.id!),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          } else if (snapshot.hasError) {
                                            return Text('Error: ${snapshot.error}');
                                          } else {
                                            final progressCount = snapshot.data;
                                            return Text(
                                              '$progressCount/${goal.goalValue} dias',
                                              style: const TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(goal.description),
                                  ),
                                  ButtonBar(
                                    children: [
                                      TextButton(
                                        onPressed: () => addProgressAndChooseImage(context, goal.id!, widget.currentUser.id!, _refreshPage),
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
            setState(() {
              _refreshPage();
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
        id: doc.id,
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

Future<void> addProgressAndChooseImage(BuildContext context, String goalId, String userId, Function refreshPage) async {
  bool progressAddedToday = await checkProgressForToday(goalId, userId);

  if (progressAddedToday) {
    showToast('Progresso do dia já adicionado. Tente novamente amanhã');
    return;
  }

  // ignore: use_build_context_synchronously
  final source = await showDialog<ImageSource>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Escolha a origem da imagem'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, ImageSource.camera);
            },
            child: const Text('Câmera'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, ImageSource.gallery);
            },
            child: const Text('Galeria'),
          ),
        ],
      );
    },
  );

  if (source != null) {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      await uploadImageToStorage(pickedFile.path, goalId, userId, refreshPage);
      showToast('Progresso adicionado!');
    }
  }
}

Future<bool> checkProgressForToday(String goalId, String userId) async {
  final Reference storageRef = FirebaseStorage.instance.ref().child('users/$userId/goals/$goalId/progress');
  // get last upload
  final ListResult result = await storageRef.list();
  final List<Reference> allFiles = result.items;
  if (allFiles.isNotEmpty) {
    // final lastFile = allFiles.last;
  }
  return false;
}

Future<void> uploadImageToStorage(String imagePath, String goalId, String userId, Function refreshPage) async {
  final Reference storageRef = FirebaseStorage.instance.ref().child('users/$userId/goals/$goalId/progress');

  File imageFile = File(imagePath);

  String todayAsString = DateTime.now().toString();
  String imageFileName = 'progress_$todayAsString.jpg';

  UploadTask uploadTask = storageRef.child(imageFileName).putFile(imageFile);

  await uploadTask.whenComplete(() {
    showToast('Imagem enviada com sucesso!');
    refreshPage();
  });
}

Future<num> countProgressOfGoal(String goalId, String userId) async {
  try {
    final Reference storageRef = FirebaseStorage.instance.ref().child('users/$userId/goals/$goalId/progress');
    if (storageRef.fullPath.isEmpty) {
      return 0;
    }

    final ListResult result = await storageRef.list();
    final List<Reference> allFiles = result.items;

    return allFiles.length;
  } catch (e) {
    showToast('Error counting progress: $e');
    return 0;
  }
}
