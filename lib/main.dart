import 'package:flutter/material.dart';

void main() {
  runApp(const LingoQuestApp());
}

class LingoQuestApp extends StatelessWidget {
  const LingoQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LingoQuest',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF10121A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LingoQuest 🦉',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Questy
            const Text(
              '🦉',
              style: TextStyle(fontSize: 80),
            ),

            const Text(
              'Welcome to LingoQuest!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Every Word is an Adventure.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 25),

            // XP and Coins
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    '⭐',
                    'XP',
                    '0',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    '🪙',
                    'Coins',
                    '50',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Start button
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdventureMapScreen(),
                    ),
                  );
                },
                child: const Text(
                  'START MY ADVENTURE 🚀',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Learn English • Have Fun • Earn Rewards',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _statCard(
    String icon,
    String title,
    String value,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class AdventureMapScreen extends StatelessWidget {
  const AdventureMapScreen({super.key});

  static const worlds = [
    ('🏡', 'Welcome Village', 'Greetings & Introductions', true),
    ('🍎', '