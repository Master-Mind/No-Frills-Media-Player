import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MusicAppState(),
      child: MaterialApp(
        title: 'No Frills Media Player',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('No Frills Media Player');
  }
}

class MusicAppState extends ChangeNotifier {}
