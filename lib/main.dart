import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      builder: (context, child) => TodoApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class Todo {
  String title;
  String note;
  bool isCompleted;

  Todo({
    required this.title,
    required this.isCompleted,
    this.note = '',
  });
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Todo List Uygulaması',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.themeMode,
          home: LoginPage(),
        );
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _loggedIn = false;
  String? _registeredUsername;
  String? _registeredPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giriş Yap'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_4),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Şifre',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (usernameController.text == _registeredUsername &&
                    passwordController.text == _registeredPassword) {
                  setState(() {
                    _loggedIn = true;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TodoList()),
                  ).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Giriş yapıldı.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  });
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Hata'),
                        content: Text('Geçersiz kullanıcı adı veya şifre.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Tamam'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Giriş Yap'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                ).then((value) {
                  setState(() {
                    _registeredUsername = value[0];
                    _registeredPassword = value[1];
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Kayıt yapıldı.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                });
              },
              child: Text('Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kayıt Ol'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Şifre',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, [
                  usernameController.text,
                  passwordController.text,
                ]);
              },
              child: Text('Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<Todo> todos = [];

  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  bool _showCompletedTasks = false;

  @override
  Widget build(BuildContext context) {
    List<Todo> filteredTodos = _showCompletedTasks
        ? todos
        : todos.where((todo) => !todo.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () {
              setState(() {
                _showCompletedTasks = !_showCompletedTasks;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredTodos.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      filteredTodos[index].title,
                      style: TextStyle(
                        fontSize: 18,
                        decoration: filteredTodos[index].isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: filteredTodos[index].note.isNotEmpty
                        ? Text(
                            filteredTodos[index].note,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editTodoDialog(filteredTodos[index]);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              todos.remove(filteredTodos[index]);
                            });
                          },
                        ),
                        Checkbox(
                          value: filteredTodos[index].isCompleted,
                          onChanged: (newValue) {
                            setState(() {
                              filteredTodos[index].isCompleted = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Yeni görev ekle',
                  ),
                ),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: 'Not (isteğe bağlı)',
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      todos.add(Todo(
                        title: titleController.text,
                        note: noteController.text,
                        isCompleted: false,
                      ));
                      titleController.clear();
                      noteController.clear();
                    });
                  },
                  child: Text('Ekle'),
                ),
              ],
            ),
          ),],),);}

  void _editTodoDialog(Todo todo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController editTitleController =
            TextEditingController(text: todo.title);
        TextEditingController editNoteController =
            TextEditingController(text: todo.note);

        return AlertDialog(
          title: Text('Görevi Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editTitleController,
                decoration: InputDecoration(
                  hintText: 'Başlık',
                ),
              ),
              TextField(
                controller: editNoteController,
                decoration: InputDecoration(
                  hintText: 'Not (isteğe bağlı)',),),],),
          actions: [TextButton(
            onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  todo.title = editTitleController.text;
                  todo.note = editNoteController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Kaydet'),
            ),
          ],);  },
            );
          }
        }