import 'package:asg_module_5/task_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'db_helper.dart';
import 'model.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _refreshTaskList();
  }

  _refreshTaskList() async {
    List<Task> x = await dbHelper.getTasks();
    DateFormat dateFormat = DateFormat('yyyy-MM-dd h:mm a');

    x.sort((a, b) {
      try {
        String aFormattedDate = a.date.replaceAll('/', '-');
        String bFormattedDate = b.date.replaceAll('/', '-');
        DateTime aDateTime = dateFormat.parse('$aFormattedDate ${a.time}');
        DateTime bDateTime = dateFormat.parse('$bFormattedDate ${b.time}');
        return aDateTime.compareTo(bDateTime);
      } catch (e) {
        print('Error parsing date/time for task: $e');
        return 0;
      }
    });

    setState(() {
      tasks = x;
    });
  }

  _deleteTask(int id) async {
    await dbHelper.deleteTask(id);
    _refreshTaskList();
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.white;
      case 2:
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 0:
        return 'Low';
      case 1:
        return 'Average';
      case 2:
        return 'High';
      default:
        return 'Unknown';
    }
  }

  Color _getTaskColor(Task task) {
    try {
      String formattedDate = task.date.replaceAll('/', '-');
      String dateTimeString = '$formattedDate ${task.time}';
      DateFormat dateFormat = DateFormat('yyyy-MM-dd h:mm a');
      DateTime taskDateTime = dateFormat.parse(dateTimeString);

      if (task.isCompleted) {
        return Colors.grey;
      }

      if (taskDateTime.isBefore(DateTime.now()) && !task.isCompleted) {
        return Colors.blue;
      }

      return Colors.white;
    } catch (e) {
      print('Error parsing date/time for task: $e');
      return Colors.red;
    }
  }

  void _markTaskAsCompleted(Task task) async {
    task.isCompleted = true;
    await dbHelper.updateTask(task);
    _refreshTaskList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CupertinoColors.systemPurple,
        title: Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: TaskSearchDelegate(tasks));
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          Task task = tasks[index];
          return Card(
            color: _getTaskColor(task),
            child: ListTile(
              title: Row(
                children: [
                  Text('Name: '),
                  Text(
                    task.name,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description: ${task.description}'),
                  Text('Date: ${task.date}'),
                  Text('Time: ${task.time}'),
                  Text('Priority: ${_getPriorityText(task.priority)}',
                      style:
                          TextStyle(color: _getPriorityColor(task.priority))),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskScreen(
                            onSave: (updatedTask) {
                              dbHelper.updateTask(updatedTask);
                              _refreshTaskList();
                            },
                            task: task,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete Task'),
                            content: Text(
                                'Are you sure you want to delete this task?'),
                            actions: [
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Delete'),
                                onPressed: () {
                                  _deleteTask(task.id!);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Complete the Task'),
                      content: Text('Mark this task as completed?'),
                      actions: [
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Complete'),
                          onPressed: () {
                            _markTaskAsCompleted(task);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskScreen(
                onSave: (task) {
                  dbHelper.insertTask(task);
                  _refreshTaskList();
                },
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskSearchDelegate extends SearchDelegate {
  final List<Task> tasks;

  TaskSearchDelegate(this.tasks);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = tasks.where((task) {
      final taskNameLower = task.name.toLowerCase();
      final taskDate = task.date;
      final queryLower = query.toLowerCase();

      return taskNameLower.contains(queryLower) || taskDate.contains(query);
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index].name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(results[index].description),
              Text(results[index].date),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = tasks.where((task) {
      final taskNameLower = task.name.toLowerCase();
      final taskDate = task.date;
      final queryLower = query.toLowerCase();

      return taskNameLower.contains(queryLower) || taskDate.contains(query);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index].name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(suggestions[index].description),
              Text(suggestions[index].date),
            ],
          ),
        );
      },
    );
  }
}


