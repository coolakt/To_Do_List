import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmanagerapp/models/tasks.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _taskController;
  late List<Tasks> _tasks = [];
  late List<bool> _taskDone = [];

  void saveData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Tasks task = Tasks.fromString(_taskController.text);

    // Retrieve existing tasks (if any)
    String? tasksString = pref.getString('tasks');
    List<dynamic> tasksList =
        (tasksString == null) ? [] : json.decode(tasksString);

    // Add the new task
    tasksList.add(task.getMap());

    // Save the updated task list
    await pref.setString('tasks', json.encode(tasksList));

    _taskController.text = '';
    _getTask(); // Update the UI after saving
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  void _getTask() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    // Retrieve the tasks list
    String? tasksString = pref.getString('tasks');
    List<dynamic> tasksList =
        (tasksString == null) ? [] : json.decode(tasksString);

    setState(() {
      _tasks = tasksList.map((task) => Tasks.fromMap(task)).toList();
      _taskDone = List.generate(_tasks.length, (index) => false);
    });
  }

  void saveCompletedTasks() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<Tasks> pendingTasks = [];
    for (int i = 0; i < _tasks.length; i++) {
      if (!_taskDone[i]) {
        pendingTasks.add(_tasks[i]);
      }
    }

    // Save updated task list to SharedPreferences
    List<Map<String, dynamic>> tasksToSave =
        pendingTasks.map((task) => task.getMap()).toList();
    await pref.setString('tasks', json.encode(tasksToSave));

    // Update state to reflect the changes
    setState(() {
      _tasks = pendingTasks;
      _taskDone =
          List.generate(_tasks.length, (index) => false); // Reset done list
    });

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Completed tasks saved and removed!',
        ),
        backgroundColor: Color.fromARGB(255, 87, 79, 8),
      ),
    );
  }

  void toggleTaskDone(int index, bool? value) {
    setState(() {
      _taskDone[index] = value ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController();
    _getTask();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Task Manager",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color.fromARGB(255, 87, 79, 8),
          toolbarHeight: 75,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.save,
                color: Colors.white,
              ),
              onPressed: saveCompletedTasks,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: () async {
                SharedPreferences pref = await SharedPreferences.getInstance();
                await pref
                    .remove('tasks'); // Clear all tasks from SharedPreferences
                setState(() {
                  _tasks = []; // Clear tasks from the UI
                  _taskDone = []; // Reset the completion states
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All tasks have been deleted!'),
                    backgroundColor: Color.fromARGB(255, 87, 79, 8),
                  ),
                );
              },
            ),
          ],
        ),
        body: (_tasks.isEmpty)
            ? const Center(
                child: Text('No task assigned'),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: _tasks.length,
                itemBuilder: (ctx, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 87, 79, 8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _tasks[index]
                              .task, // Assuming `Tasks` model has a `task` field
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                        Checkbox(
                            value: _taskDone[index],
                            key: GlobalKey(),
                            onChanged: (value) => toggleTaskDone(index, value),
                            activeColor: const Color.fromARGB(255, 87, 79, 8),
                            checkColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            )),
                      ],
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 87, 79, 8),
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (BuildContext context) => Container(
              color: const Color.fromARGB(255, 87, 79, 8),
              height: 210,
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add Task",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.close_rounded,
                              color: Color.fromARGB(255, 87, 79, 8),
                              size: 30,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Divider(
                      thickness: 1.2,
                      color: Color.fromARGB(255, 39, 35, 3),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 87, 79, 8),
                          ),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Enter Task",
                        hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 87, 79, 8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _taskController.text = '';
                            },
                            child: const Text(
                              "RESET",
                              style: TextStyle(
                                color: Color.fromARGB(255, 87, 79, 8),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              saveData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 207, 187, 10),
                            ),
                            child: const Text(
                              "ADD",
                              style: TextStyle(
                                color: Color.fromARGB(255, 87, 79, 8),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 50,
          ),
        ),
      ),
    );
  }
}
