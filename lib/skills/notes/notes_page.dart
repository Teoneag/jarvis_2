import 'package:flutter/material.dart';
import '../../abstracts/page.dart';

class NotesPage extends BasePage {
  @override
  String get title => 'Notes';
  @override
  IconData get icon => Icons.note;

  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
