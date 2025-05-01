import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _tasks = [];
  bool _loading = true;
  DateTime _dueDate = DateTime.now().add(Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() => _loading = true);

    final snapshot = await _firestore.collection('tasks').get();
    final List<Map<String, dynamic>> loadedTasks = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'title': data['title'] ?? '',
        'completed': data['completed'] ?? false,

        'dueDate': (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      };
    }).toList();

    setState(() {
      _tasks = loadedTasks;
      _loading = false;
    });
  }

  Future<void> _addTask(String title) async {
    final newTask = {
      'title': title,
      'completed': false,

      'dueDate': _dueDate,
    };

    final docRef = await _firestore.collection('tasks').add(newTask);
    setState(() {
      _tasks.add({...newTask, 'id': docRef.id});
    });
  }

  Future<void> _toggleTaskCompletion(int index) async {
    final task = _tasks[index];
    final newStatus = !task['completed'];

    await _firestore.collection('tasks').doc(task['id']).update({
      'completed': newStatus,
    });

    setState(() {
      _tasks[index]['completed'] = newStatus;
    });
  }

  Future<void> _editTaskTitle(int index, String newTitle) async {
    await _firestore.collection('tasks').doc(_tasks[index]['id']).update({
      'title': newTitle,
    });

    setState(() {
      _tasks[index]['title'] = newTitle;
    });
  }

  Future<void> _deleteTask(int index) async {
    await _firestore.collection('tasks').doc(_tasks[index]['id']).delete();
    setState(() {
      _tasks.removeAt(index);
    });
  }


  Future<void> _pickDateTime(BuildContext context) async {
    // Date picker
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );


    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate),
      );


      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _showEditTaskDialog(int index) {
    String updatedTitle = _tasks[index]['title'];
    DateTime updatedDueDate = _tasks[index]['dueDate'];

    final titleController = TextEditingController(text: updatedTitle);


    Future<void> _pickDateTimeForEdit() async {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: updatedDueDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (pickedDate != null) {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(updatedDueDate),
        );

        if (pickedTime != null) {
          setState(() {
            updatedDueDate = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          });
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Edit Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                TextField(
                  controller: titleController,
                  autofocus: true,
                  onChanged: (value) => updatedTitle = value,
                  decoration: InputDecoration(hintText: 'Task title'),
                ),
                SizedBox(height: 20),

                TextButton(
                  onPressed: _pickDateTimeForEdit,
                  child: Text('Pick Due Date and Time'),
                ),
                SizedBox(height: 10),
                Text(
                  'Due Date: ${updatedDueDate.toLocal().toString().split(
                      ' ')[0]} ${updatedDueDate.toLocal().toString().split(
                      ' ')[1].split('.')[0]}',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (updatedTitle
                      .trim()
                      .isNotEmpty) {
                    _editTask(index, updatedTitle.trim(), updatedDueDate);
                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _editTask(int index, String newTitle,
      DateTime newDueDate) async {
    await _firestore.collection('tasks').doc(_tasks[index]['id']).update({
      'title': newTitle,
      'dueDate': newDueDate,
    });

    setState(() {
      _tasks[index]['title'] = newTitle;
      _tasks[index]['dueDate'] = newDueDate;
    });
  }

  void _showAddTaskDialog() {
    String newTaskTitle = '';
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('New Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                TextField(
                  autofocus: true,
                  onChanged: (value) => newTaskTitle = value,
                  decoration: InputDecoration(hintText: 'Enter task title'),
                ),
                SizedBox(height: 20),

                TextButton(
                  onPressed: () => _pickDateTime(context),
                  child: Text('Pick Due Date and Time'),
                ),
                SizedBox(height: 10),
                // Text(
                //   'Due Date: ${_dueDate.toLocal().toString().split(' ')[0]} ${_dueDate.toLocal().toString().split(' ')[1].split('.')[0]}',
                //   style: TextStyle(fontWeight: FontWeight.w500),
                // ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (newTaskTitle
                      .trim()
                      .isNotEmpty) {
                    _addTask(newTaskTitle.trim());
                    Navigator.pop(context);
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTasks = _tasks.where((t) => !t['completed']).toList();
    final completedTasks = _tasks.where((t) => t['completed']).toList();

    return Scaffold(
      appBar: AppBar(title: Text('My To-Do List')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: EdgeInsets.only(bottom: 80),
        children: [
          ...activeTasks.map((task) => _buildTaskTile(task, false)),
          if (completedTasks.isNotEmpty) ...[
            Divider(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('Completed Tasks',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...completedTasks.map((task) => _buildTaskTile(task, true)),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskTile(Map<String, dynamic> task, bool completed) {
    final index = _tasks.indexWhere((t) => t['id'] == task['id']);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      elevation: 0,

      child: ListTile(
        leading: Checkbox(
          value: task['completed'],
          onChanged: (_) => _toggleTaskCompletion(index),
          activeColor: Colors.teal.shade600,
        ),
        title: Text(
          task['title'],
          style: completed
              ? TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          )
              : TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
           ' Due: ${task['dueDate']
              .toLocal()
              .toString()
              .split(' ')[0]}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.teal.shade600, size: 15.0,),
              onPressed: () => _showEditTaskDialog(index),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red, size: 15.0,),
              onPressed: () => _deleteTask(index),
            ),
          ],
        ),
      ),
    );
  }
}

