import 'package:flutter/material.dart';

import 'global/page_abstract.dart';

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
    return const Placeholder();
  }
}
