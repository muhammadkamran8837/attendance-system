import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TaskPage(employId: 'GM003'),
    );
  }
}

class TaskPage extends StatelessWidget {
  final String employId;

  TaskPage({required this.employId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks for $employId'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('task')
            .where('employId', isEqualTo: employId)
            .where('taskDone', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data?.docs ?? [];

          if (tasks.isEmpty) {
            return Center(child: Text('No tasks found.'));
          }

          return ListView(
            children: tasks.map((doc) {
              return TaskCard(
                taskId: doc.id,
                taskData: doc.data() as Map<String, dynamic>,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String taskId;
  final Map<String, dynamic> taskData;

  TaskCard({required this.taskId, required this.taskData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task: ${taskData['taskName']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('task')
                    .doc(taskId)
                    .update({'taskDone': true});
              },
              child: Text('Mark as Done'),
            ),
          ],
        ),
      ),
    );
  }
}
