import 'package:flutter/material.dart';

void main() => runApp(const LingoQuestApp());

class LingoQuestApp extends StatefulWidget {
  const LingoQuestApp({super.key});

  @override
  State<LingoQuestApp> createState() => _LingoQuestAppState();
}

class _LingoQuestAppState extends State<LingoQuestApp> {
  int xp = 0;
  int coins = 50;
  int streak = 1;
  final Set<int> completedWorlds = <int>{};

  void reward(int addXp, int addCoins) {
    setState(() {
      xp += addXp;
      coins += addCoins;
    });
  }

  void completeWorld(int id) {
    setState(() => completedWorlds.add(id));
  }

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
      home: MainScreen(
        xp: xp,
        coins: coins,
        streak: streak,
        completedWorlds: completedWorlds,
        onReward: reward,
        onCompleteWorld: completeWorld,
      ),
    );
  }
}

class World {
  final int id;
  final String icon;
  final String name;
  final String subtitle;

  const World(this.id, this.icon, this.name, this.subtitle);
}

const worlds = <World>[
  World(1, '🏡', 'Welcome Village', 'Greetings & Introductions'),
  World(2, '🍎', 'Food Forest', 'Food & Drinks'),
  World(3, '🏠', 'Home Hills', 'Home & Family'),
  World(4, '🏫', 'School City', 'School & Education'),
  World(5, '🛒', 'Shopping Town', 'Shopping & Money'),
  World(6, '✈️', 'Travel Island', 'Travel & Directions'),
  World(7, '💼', 'Business City', 'English for Work'),
  World(8, '🏰', 'Grammar Castle', 'Grammar Challenges'),
  World(9, '🎬', 'Movie Town', 'Real-world English'),
  World(10, '🎓', 'Master Mountain', 'Advanced English'),
];

class MainScreen extends StatefulWidget {
  final int xp;
  final int coins;
  final int streak;
  final Set<int> completedWorlds;
  final void Function(int, int) onReward;
  final void Function(int) onCompleteWorld;

  const MainScreen({
    super.key,
    required this.xp,
    required this.coins,
    required this.streak,
    required this.completedWorlds,
    required this.onReward,
    required this.onCompleteWorld,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        xp: widget.xp,
        coins: widget.coins,
        streak: widget.streak,
        onStart: () => setState(() => tab = 1),
      ),
      MapPage(
        xp: widget.xp,
        coins: widget.coins,
        completedWorlds: widget.completedWorlds,
        onReward: widget.onReward,
        onCompleteWorld: widget.onCompleteWorld,
      ),
      RewardsPage(
        xp: widget.xp,
        coins: widget.coins,
        streak: widget.streak,
        completedWorlds: widget.completedWorlds,
      ),
    ];

    return Scaffold(
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Adventure'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'Rewards'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final int xp;
  final int coins;
  final int streak;
  final VoidCallback onStart;

  const HomePage({
    super.key,
    required this.xp,
    required this.coins,
    required this.streak,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LingoQuest 🦉', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('🦉', textAlign: TextAlign.center, style: TextStyle(fontSize: 88)),
          const SizedBox(height: 8),
          const Text(
            'Welcome to LingoQuest!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Every Word is an Adventure.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: StatCard('⭐', xp.toString(), 'XP')),
              const SizedBox(width: 8),
              Expanded(child: StatCard('🪙', coins.toString(), 'Coins')),
              const SizedBox(width: 8),
              Expanded(child: StatCard('🔥', streak.toString(), 'Streak')),
            ],
          ),
          const SizedBox(height: 22),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Adventure', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Begin in Welcome Village and learn your first English greetings.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: onStart,
                      icon: const Icon(Icons.rocket_launch),
                      label: const Text('START MY ADVENTURE'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Learn English • Have Fun • Earn Rewards', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 6),
          const Text('By Mr. Arias', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const StatCard(this.icon, this.value, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 25)),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class MapPage extends StatelessWidget {
  final int xp;
  final int coins;
  final Set<int> completedWorlds;
  final void Function(int, int) onReward;
  final void Function(int) onCompleteWorld;

  const MapPage({
    super.key,
    required this.xp,
    required this.coins,
    required this.completedWorlds,
    required this.onReward,
    required this.onCompleteWorld,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adventure Map 🗺️', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(child: Text('⭐ ' + xp.toString() + '  🪙 ' + coins.toString())),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
        itemCount: worlds.length,
        itemBuilder: (context, index) {
          final world = worlds[index];
          final completed = completedWorlds.contains(world.id);
          final unlocked = world.id == 1 || completedWorlds.contains(world.id - 1);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: unlocked
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorldPage(
                              world: world,
                              completed: completed,
                              onReward: onReward,
                              onCompleteWorld: onCompleteWorld,
                            ),
                          ),
                        )
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: unlocked ? Theme.of(context).colorScheme.primaryContainer : Colors.white10,
                        ),
                        child: Text(unlocked ? world.icon : '🔒', style: const TextStyle(fontSize: 29)),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(world.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 3),
                            Text(world.subtitle, style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(value: completed ? 1 : (unlocked ? .15 : 0)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(completed ? Icons.check_circle : unlocked ? Icons.arrow_forward_ios : Icons.lock, size: 19),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class WorldPage extends StatelessWidget {
  final World world;
  final bool completed;
  final void Function(int, int) onReward;
  final void Function(int) onCompleteWorld;

  const WorldPage({
    super.key,
    required this.world,
    required this.completed,
    required this.onReward,
    required this.onCompleteWorld,
  });

  @override
  Widget build(BuildContext context) {
    final first = world.id == 1;

    return Scaffold(
      appBar: AppBar(title: Text(world.icon + ' ' + world.name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(world.subtitle, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(world.icon, style: const TextStyle(fontSize: 72)),
                  Text(
                    first ? 'Your first English mission!' : 'New adventures are coming!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    first
                        ? 'Practice greetings and introductions, then complete the challenge to earn XP and coins.'
                        : 'This world is prepared in the Adventure Map and will receive its lessons as we build LingoQuest.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  if (first)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GreetingsLesson(
                              onReward: onReward,
                              onComplete: () => onCompleteWorld(world.id),
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: Text(completed ? 'PLAY AGAIN' : 'START LESSON'),
                      ),
                    )
                  else
                    const Text('🔒 Coming soon', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Question {
  final String question;
  final List<String> options;
  final int correct;

  const Question(this.question, this.options, this.correct);
}

const greetingQuestions = <Question>[
  Question('What do you say when you meet someone?', ['Hello!', 'Good night!', 'Goodbye!', 'See you tomorrow!'], 0),
  Question('What is the best answer to “How are you?”', ['I am fine, thank you.', 'My name is Ana.', 'Good night.', 'See you!'], 0),
  Question('Which expression means “Adiós”?', ['Hello', 'Good morning', 'Goodbye', 'Nice to meet you'], 2),
  Question('Complete: “Nice to ___ you.”', ['meet', 'eat', 'play', 'sleep'], 0),
];

class GreetingsLesson extends StatefulWidget {
  final void Function(int, int) onReward;
  final VoidCallback onComplete;

  const GreetingsLesson({super.key, required this.onReward, required this.onComplete});

  @override
  State<GreetingsLesson> createState() => _GreetingsLessonState();
}

class _GreetingsLessonState extends State<GreetingsLesson> {
  int question = 0;
  int correct = 0;
  int? selected;
  bool answered = false;

  void choose(int index) {
    if (answered) return;
    setState(() {
      selected = index;
      answered = true;
      if (index == greetingQuestions[question].correct) correct++;
    });
  }

  void next() {
    if (!answered) return;
    if (question < greetingQuestions.length - 1) {
      setState(() {
        question++;
        selected = null;
        answered = false;
      });
      return;
    }

    final earned = correct * 20;
    widget.onReward(earned, 50);
    widget.onComplete();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CompletionPage(correct: correct, total: greetingQuestions.length, earned: earned),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = greetingQuestions[question];

    return Scaffold(
      appBar: AppBar(title: const Text('Greetings Mission')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('🏡 Welcome Village', style: TextStyle(fontWeight: FontWeight.bold)),
              Text((question + 1).toString() + '/' + greetingQuestions.length.toString()),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: (question + 1) / greetingQuestions.length),
          const SizedBox(height: 24),
          const Text('🦉 Questy says:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Let’s practice greetings!', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(item.question, textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(item.options.length, (index) {
            final picked = selected == index;
            final right = index == item.correct;
            String suffix = '';
            if (answered && picked) suffix = right ? '  ✓' : '  ✗';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: OutlinedButton(
                onPressed: () => choose(index),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16), alignment: Alignment.centerLeft),
                child: Text(
                  String.fromCharCode(65 + index) + '. ' + item.options[index] + suffix,
                  style: TextStyle(fontSize: 16, fontWeight: picked ? FontWeight.bold : FontWeight.normal),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          if (answered)
            Text(
              selected == item.correct
                  ? '🎉 Correct! Great job!'
                  : '💡 Keep going! Correct answer: ' + item.options[item.correct],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 14),
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: answered ? next : null,
              child: Text(question == greetingQuestions.length - 1 ? 'FINISH MISSION 🏆' : 'NEXT QUESTION ➜'),
            ),
          ),
        ],
      ),
    );
  }
}

class CompletionPage extends StatelessWidget {
  final int correct;
  final int total;
  final int earned;

  const CompletionPage({super.key, required this.correct, required this.total, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mission Complete')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 90)),
              const Text('Mission Complete!', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('First Greeting Badge unlocked!', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: Colors.white70)),
              const SizedBox(height: 22),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(correct.toString() + ' / ' + total.toString() + ' correct', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('⭐ +' + earned.toString() + ' XP    🪙 +50 Coins', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.map),
                  label: const Text('BACK TO ADVENTURE MAP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RewardsPage extends StatelessWidget {
  final int xp;
  final int coins;
  final int streak;
  final Set<int> completedWorlds;

  const RewardsPage({
    super.key,
    required this.xp,
    required this.coins,
    required this.streak,
    required this.completedWorlds,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (xp % 100) / 100;

    return Scaffold(
      appBar: AppBar(title: const Text('Rewards 🏆', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('🦉', style: TextStyle(fontSize: 70)),
                  const Text('Questy Rewards', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      StatCard('⭐', xp.toString(), 'XP'),
                      StatCard('🪙', coins.toString(), 'Coins'),
                      StatCard('🔥', streak.toString(), 'Streak'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Next Level', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: progress == 0 ? .05 : progress),
                  const SizedBox(height: 8),
                  Text((xp % 100).toString() + '/100 XP toward the next level'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Text('🏅', style: TextStyle(fontSize: 30)),
              title: const Text('First Greeting Badge', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                completedWorlds.contains(1)
                    ? 'Unlocked — Welcome Village completed!'
                    : 'Complete Welcome Village to unlock this badge.',
              ),
              trailing: Icon(completedWorlds.contains(1) ? Icons.check_circle : Icons.lock),
            ),
          ),
        ],
      ),
    );
  }
}
