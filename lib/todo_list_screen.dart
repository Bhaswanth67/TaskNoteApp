import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskNote App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  int _currentTabIndex = 0;

  List<TaskItem> _todoItems = [];
  List<TaskItem> _completedItems = [];
  List<NoteItem> _notes = [];
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _noteTitleController = TextEditingController();
  final TextEditingController _noteDescController = TextEditingController();


  void _addTodoItem(String task) {
    setState(() {
      final newTask = TaskItem(task: task, time: DateTime.now());
      _todoItems.add(newTask);
      _controller.clear();
    });
  }

  void _completeTodoItem(int index) {
    setState(() {
      final completedTask = _todoItems[index];
      completedTask.completed = true;
      completedTask.completedTime = DateTime.now();
      _completedItems.add(completedTask);
      _todoItems.removeAt(index);
    });
  }

  void _removeTask(int index, bool isCompletedList) {
    setState(() {
      if (isCompletedList) {
        _completedItems.removeAt(index);
      } else {
        _todoItems.removeAt(index);
      }
    });
  }

  void _promptRemoveTodoItem(int index, bool isCompletedList) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('DELETE'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _removeTask(index, isCompletedList);
              },
            ),
          ],
        );
      },
    );
  }

  void _addNoteItem(String title, String description) {
    setState(() {
      final newNote = NoteItem(
        title: title,
        description: description,
        time: DateTime.now(),
      );
      _notes.add(newNote);
      _noteTitleController.clear();
      _noteDescController.clear();
    });
  }

  void _promptRemoveNoteItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Note'),
          content: Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('DELETE'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _removeNoteItem(index);
              },
            ),
          ],
        );
      },
    );
  }

  void _removeNoteItem(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  void _editNoteItem(int index) {
    _noteTitleController.text = _notes[index].title;
    _noteDescController.text = _notes[index].description;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _noteTitleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _noteDescController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('SAVE'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _saveEditedNoteItem(index);
              },
            ),
          ],
        );
      },
    );
  }

  void _saveEditedNoteItem(int index) {
    setState(() {
      _notes[index].title = _noteTitleController.text;
      _notes[index].description = _noteDescController.text;
      _noteTitleController.clear();
      _noteDescController.clear();
    });
  }

  void _revertToTodoItem(int index) {
    setState(() {
      final revertedTask = _completedItems[index];
      revertedTask.completed = false;
      _todoItems.add(revertedTask);
      _completedItems.removeAt(index);
    });
  }

  void _pushAddTodoScreen(BuildContext context) async {
    final newTask = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return AddTodoScreen(controller: _controller);
        },
      ),
    );

    if (newTask != null && newTask.isNotEmpty) {
      _addTodoItem(newTask);
    }
  }

  void _pushAddNoteScreen(BuildContext context) async {
    final newNote = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return AddNoteScreen();
        },
      ),
    );

    if (newNote != null && newNote.isNotEmpty) {
      _addNoteItem(newNote[0], newNote[1]);
    }
  }

  Widget _buildTaskList(List<TaskItem> tasks, bool isCompletedList) {
    if (_searchText.isNotEmpty) {
      tasks = tasks.where((task) => task.task.contains(_searchText)).toList();
    }

    if (tasks.isEmpty) {
      return Center(child: Text(isCompletedList ? 'No completed tasks.' : 'No tasks available.'));
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        final task = tasks[index];
        return Container(
          decoration: BoxDecoration(
            color: task.completed ? Colors.greenAccent : Colors.orangeAccent,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.task,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  isCompletedList
                      ? 'Completed on ${task.completedTime!.toLocal()}'
                      : 'Added on ${task.time.toLocal()}',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isCompletedList && !task.completed)
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () => _completeTodoItem(index),
                  ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _promptRemoveTodoItem(index, isCompletedList),
                ),
                if (isCompletedList)
                  IconButton(
                    icon: Icon(Icons.undo),
                    onPressed: () {
                      _revertToTodoItem(index);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesList() {
    List<NoteItem> filteredNotes = _notes.where((note) => note.title.contains(_searchText)).toList();

    if (filteredNotes.isEmpty) {
      return Center(child: Text('Notes not added yet.'));
    }

    return ListView.builder(
      itemCount: filteredNotes.length,
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          key: Key(filteredNotes[index].title + filteredNotes[index].time.toString()),
          onDismissed: (direction) {
            _removeNoteItem(_notes.indexOf(filteredNotes[index]));
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
          ),
          secondaryBackground: Container(
            color: Colors.blue,
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.edit, color: Colors.white),
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              return true;
            } else if (direction == DismissDirection.startToEnd) {
              _editNoteItem(_notes.indexOf(filteredNotes[index]));
              return false;
            }
            return false;
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: EdgeInsets.all(8.0),
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filteredNotes[index].title,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text(
                  filteredNotes[index].description,
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Added on ${filteredNotes[index].time.toLocal()}',
                  style: TextStyle(fontSize: 12.0, color: Colors.grey[700]),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _promptRemoveNoteItem(_notes.indexOf(filteredNotes[index])),
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                    SizedBox(width: 8.0),
                    TextButton.icon(
                      onPressed: () => _editNoteItem(_notes.indexOf(filteredNotes[index])),
                      icon: Icon(Icons.edit, color: Colors.blue),
                      label: Text('Edit', style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
        appBar: AppBar(
        title: Text('TaskNote App'),
    bottom: TabBar(
    tabs: [
    Tab(
    text: 'Tasks',
    icon: Icon(Icons.list, color: _currentTabIndex == 0 ? Colors.white : Colors.grey),
    ),
    Tab(
    text: 'Completed',
    icon: Icon(Icons.done_all, color: _currentTabIndex == 1 ? Colors.white : Colors.grey),
    ),
    Tab(
    text: 'Notes',
    icon: Icon(Icons.note, color: _currentTabIndex == 2 ? Colors.white : Colors.grey),
    ),
    ],
    onTap: (index) {
    setState(() {
    _currentTabIndex = index;
    });
    },
    ),
    ),

        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildTaskList(_todoItems, false),
                ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildTaskList(_completedItems, true),
                ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildNotesList(),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: _currentTabIndex == 2
            ? FloatingActionButton(
          onPressed: () {
            _pushAddNoteScreen(context);
          },
          tooltip: 'Add note',
          child: Icon(Icons.add),
        )
            : FloatingActionButton(
          onPressed: () {
            _pushAddTodoScreen(context);
          },
          tooltip: 'Add task',
          child: Icon(Icons.add),
        ),
      ),
    );
  }

}

class TaskItem {
  String task;
  DateTime time;
  bool completed;
  DateTime? completedTime;

  TaskItem({
    required this.task,
    required this.time,
    this.completed = false,
    this.completedTime,
  });
}

class NoteItem {
  String title;
  String description;
  DateTime time;

  NoteItem({
    required this.title,
    required this.description,
    required this.time,
  });
}

class AddTodoScreen extends StatelessWidget {
  final TextEditingController controller;

  AddTodoScreen({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: 'Task'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddNoteScreen extends StatelessWidget {
  final TextEditingController _noteTitleController = TextEditingController();
  final TextEditingController _noteDescController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _noteTitleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _noteDescController,
              maxLines: 3,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop([
                  _noteTitleController.text,
                  _noteDescController.text,
                ]);
              },
              child: Text('Add Note'),
            ),
          ],
        ),
      ),
    );
  }
}
