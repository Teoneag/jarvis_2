import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'abstracts/page.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'skills/notes/notes_page.dart';
import 'skills/to_do/to_do_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jarvis 2',
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

final List<BasePage> _pages = <BasePage>[
  const ToDoPage(),
  const HomePage(),
  const NotesPage(),
];

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    print('mere');
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jarvis 2'),
      ),
      body: CallbackShortcuts(
        bindings: {
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit1):
              () => _onItemTapped(0),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit2):
              () => _onItemTapped(1),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit3):
              () => _onItemTapped(2),
        },
        child: Focus(
          autofocus: true,
          child: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        items: _pages
            .map((page) => BottomNavigationBarItem(
                icon: Icon(page.icon), label: page.title))
            .toList(),
      ),
    );
  }
}
