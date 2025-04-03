import 'package:flutter/material.dart';
import 'package:aima_demo/utils/config.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Future<void> _initializeAppConfig() async {
    await AppConfig().initialize();
  }

  @override
  void initState() {
    super.initState();
    _initializeAppConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AIMA Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to AIMA Demo!'),
            ElevatedButton(
              onPressed: () {
                // Navigate to the next page
              },
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
