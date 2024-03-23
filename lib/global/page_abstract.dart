import 'package:flutter/material.dart';

abstract class BasePage extends StatefulWidget {
  String get title;
  IconData get icon;

  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
