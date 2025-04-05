import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/tasks/v1.dart' as tasks_api;
import 'package:googleapis_auth/auth_io.dart';
import 'firebase_options.dart';

// void main() {
//   runApp(TodoApp());
// }

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['https://www.googleapis.com/auth/tasks']);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _tasks = [];
  Future<void> _fetchTasks() async {
    final user = await _googleSignIn.signIn();
    if (user == null) return;

    final clientId = ClientId(
      'YOUR_CLIENT_ID.apps.googleusercontent.com',  // Replace with your real client ID
      'YOUR_CLIENT_SECRET',                         // Replace with your real client secret
    );

    final scopes = [tasks_api.TasksApi.tasksScope];

    final client = await clientViaUserConsent(clientId, scopes, (url) {
      // Open the URL for user consent
      print('Please go to the following URL and grant access:');
      print(url);
    });

    final taskApi = tasks_api.TasksApi(client);

    final taskLists = await taskApi.tasklists.list();
    if (taskLists.items != null && taskLists.items!.isNotEmpty) {
      final firstListId = taskLists.items!.first.id!;
      final taskList = await taskApi.tasks.list(firstListId);

      setState(() {
        _tasks = taskList.items
            ?.map((task) => {
          'id': task.id,
          'title': task.title ?? 'Untitled',
          'completed': task.status == 'completed',
          'synced': true,
        })
            .toList() ??
            [];
      });
    }

    client.close();
  }


  Future<void> _addTask(String title) async {
    final newTask = {
      'title': title,
      'completed': false,
      'synced': false,
    };

    setState(() {
      _tasks.add(newTask);
    });

    await _firestore.collection('tasks').add(newTask);
  }

  Future<void> _toggleTaskCompletion(int index) async {
    setState(() {
      _tasks[index]['completed'] = !_tasks[index]['completed'];
      _tasks[index]['synced'] = false;
    });

    await _firestore.collection('tasks').doc(_tasks[index]['id']).update({
      'completed': _tasks[index]['completed'],
      'synced': false,
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Tasks')),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            leading: Checkbox(
              value: task['completed'],
              onChanged: (_) => _toggleTaskCompletion(index),
            ),
            title: Text(task['title']),
            trailing: task['synced']
                ? Icon(Icons.cloud_done, color: Colors.green)
                : Icon(Icons.cloud_off, color: Colors.red),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String newTaskTitle = '';
              return AlertDialog(
                title: Text('New Task'),
                content: TextField(
                  onChanged: (value) => newTaskTitle = value,
                  decoration: InputDecoration(hintText: 'Task title'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (newTaskTitle.isNotEmpty) {
                        _addTask(newTaskTitle);
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
