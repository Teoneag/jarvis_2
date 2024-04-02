import 'package:flutter/material.dart';

import 'global/page_abstract.dart';
import 'skills/to_do/methods/import_tasks_todoist.dart';

class HomePage extends BasePage {
  @override
  String get title => 'Home';
  @override
  IconData get icon => Icons.home;

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Welcome to Jarvis!'),
          const Text('This is a personal assistant app.'),
          TextButton(
            onPressed: () async {
              await printFirst10Tasks();
            },
            child: const Text('Import tasks from Todoist'),
          ),
        ],
      ),
    );
  }
}
