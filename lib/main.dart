import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(const LingoQuestApp());


dynamic _deferredInstallPrompt;

void configureInstallPrompt() {
  html.window.addEventListener('beforeinstallprompt', (event) {
    event.preventDefault();
    _deferredInstallPrompt = event;
  });
}

Future<void> installLingoQuest(BuildContext context) async {
  final prompt = _deferredInstallPrompt;
  if (prompt != null) {
    await js_util.promiseToFuture(js_util.callMethod(prompt, 'prompt', <Object>[]));
    _deferredInstallPrompt = null;
    return;
  }
  if (!context.mounted) return;
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Install LingoQuest'),
      content: const Text('On your Android phone, open this website in Chrome, tap the three dots (⋮), then choose Install app or Add to Home screen.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('GOT IT')),
      ],
    ),
  );
}

Future<void> speakEnglish(String text) async {
  // flutter_tts cannot reliably select a specific voice in the web build.
  // Use the browser's Web Speech API directly so the English voice is selected.
  try {
    final synthesis = html.window.speechSynthesis;

    var voices = synthesis.getVoices();
    // Some browsers populate their voice list shortly after page load.
    if (voices.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      voices = synthesis.getVoices();
    }

    final englishVoices = voices.where((voice) {
      final locale = voice.lang.toLowerCase().replaceAll('_', '-');
      return locale == 'en' || locale.startsWith('en-');
    }).toList();

    final maleNamePattern = RegExp(
      r'\b(david|guy|mark|christopher|roger|eric|brian|daniel|james|aaron|tom|alex|male|andrew|ryan|liam)\b',
      caseSensitive: false,
    );

    final maleVoices = englishVoices.where((voice) {
      return maleNamePattern.hasMatch(voice.name);
    }).toList();

    // Prefer a clearly male English voice, especially US English.
    html.SpeechSynthesisVoice? preferredVoice;
    if (maleVoices.isNotEmpty) {
      final usMaleVoices = maleVoices.where((voice) {
        return voice.lang.toLowerCase().replaceAll('_', '-') == 'en-us';
      }).toList();
      preferredVoice = usMaleVoices.isNotEmpty ? usMaleVoices.first : maleVoices.first;
    } else if (englishVoices.isNotEmpty) {
      // At least force the correct language if this device has no identifiable
      // male English voice installed. The actual voice depends on the device.
      final usEnglishVoices = englishVoices.where((voice) {
        return voice.lang.toLowerCase().replaceAll('_', '-') == 'en-us';
      }).toList();
      preferredVoice = usEnglishVoices.isNotEmpty ? usEnglishVoices.first : englishVoices.first;
    }

    final utterance = html.SpeechSynthesisUtterance(text)
      ..lang = 'en-US'
      ..rate = 0.88
      ..pitch = 0.88;

    if (preferredVoice != null) {
      utterance.voice = preferredVoice;
      utterance.lang = preferredVoice.lang;
    }

    synthesis.cancel();
    synthesis.speak(utterance);
  } catch (_) {
    // Last-resort fallback: request US English through the Flutter plugin.
    final tts = FlutterTts();
    await tts.setLanguage('en-US');
    await tts.setSpeechRate(0.42);
    await tts.speak(text);
  }
}
class NordicLandscapePainter extends CustomPainter {
  const NordicLandscapePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF102A50), Color(0xFF276E91), Color(0xFF102A35)],
    ).createShader(rect));
    canvas.drawCircle(Offset(size.width * .78, size.height * .18), size.width * .075,
      Paint()..color = const Color(0xFFFFD78A).withOpacity(.82));
    final far = Path()
      ..moveTo(0, size.height * .48)..lineTo(size.width * .16, size.height * .20)
      ..lineTo(size.width * .27, size.height * .43)..lineTo(size.width * .42, size.height * .14)
      ..lineTo(size.width * .58, size.height * .43)..lineTo(size.width * .72, size.height * .22)
      ..lineTo(size.width * .90, size.height * .44)..lineTo(size.width, size.height * .29)
      ..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(far, Paint()..color = const Color(0xFF6B9DB5).withOpacity(.8));
    final snow = Paint()..color = const Color(0xFFE3F4F5).withOpacity(.8);
    for (final p in [[size.width*.16,size.height*.20,size.width*.105],[size.width*.42,size.height*.14,size.width*.12],[size.width*.72,size.height*.22,size.width*.10]]) {
      final x=p[0], y=p[1], w=p[2];
      final cap=Path()..moveTo(x-w*.35,y+w*.55)..lineTo(x,y-w*.18)..lineTo(x+w*.34,y+w*.52)..lineTo(x+w*.08,y+w*.38)..lineTo(x,y+w*.50)..lineTo(x-w*.12,y+w*.37)..close();
      canvas.drawPath(cap,snow);
    }
    final near=Path()..moveTo(0,size.height*.68)..quadraticBezierTo(size.width*.18,size.height*.42,size.width*.36,size.height*.68)
      ..quadraticBezierTo(size.width*.63,size.height*.88,size.width,size.height*.58)..lineTo(size.width,size.height)..lineTo(0,size.height)..close();
    canvas.drawPath(near,Paint()..color=const Color(0xFF102F39).withOpacity(.94));
    final water=Path()..moveTo(size.width*.52,size.height*.48)..lineTo(size.width*.57,size.height*.48)
      ..lineTo(size.width*.66,size.height*.91)..lineTo(size.width*.45,size.height*.91)..close();
    canvas.drawPath(water,Paint()..color=const Color(0xFF52C7E8).withOpacity(.48));
    final castle=Paint()..color=const Color(0xFFFFD18A).withOpacity(.8);
    final cx=size.width*.78, cy=size.height*.43;
    canvas.drawRect(Rect.fromLTWH(cx-22,cy-30,44,34),castle);
    canvas.drawRect(Rect.fromLTWH(cx-35,cy-45,13,49),castle);
    canvas.drawRect(Rect.fromLTWH(cx+22,cy-43,13,47),castle);
    for(final x in [cx-28,cx+28]) {
      final roof=Path()..moveTo(x-11,cy-44)..lineTo(x,cy-59)..lineTo(x+11,cy-44)..close();
      canvas.drawPath(roof,castle);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QuestyAvatar extends StatelessWidget {
  final double size;
  const QuestyAvatar({super.key, this.size = 88});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * .045),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD77A), Color(0xFF9B6829), Color(0xFF1C9BCB)],
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF28BDEB).withOpacity(.28), blurRadius: 18, spreadRadius: 2),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [Color(0xFF17365D), Color(0xFF08182D)]),
        ),
        child: Center(child: Text('🦉', style: TextStyle(fontSize: size * .58))),
      ),
    );
  }
}

class LingoQuestApp extends StatefulWidget {
  const LingoQuestApp({super.key});

  @override
  State<LingoQuestApp> createState() => _LingoQuestAppState();
}

class _LingoQuestAppState extends State<LingoQuestApp> {
  @override
  void initState() {
    super.initState();
    configureInstallPrompt();
  }

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
        scaffoldBackgroundColor: const Color(0xFF0B1628),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16A9E8),
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
      body: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: NordicLandscapePainter())),
          ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(child: QuestyAvatar(size: 108)),
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
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => installLingoQuest(context),
              icon: const Icon(Icons.install_mobile),
              label: const Text('INSTALAR EN ANDROID'),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Learn English • Have Fun • Earn Rewards', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 6),
          const Text('By Mr. Arias', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
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
          Card(
            color: const Color(0xFF17365D),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📘 PRIMERO, APRENDE', style: TextStyle(color: Color(0xFFFFD78A), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('En esta misión aprenderás a saludar, preguntar cómo está alguien y despedirte en inglés.', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  const _GreetingPhrase(english: 'Hello!', spanish: '¡Hola!'),
                  const _GreetingPhrase(english: 'Good morning!', spanish: '¡Buenos días!'),
                  const _GreetingPhrase(english: 'How are you?', spanish: '¿Cómo estás?'),
                  const _GreetingPhrase(english: 'Goodbye!', spanish: '¡Adiós!'),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () => speakEnglish('Hello! Good morning! How are you?'),
                      icon: const Icon(Icons.volume_up),
                      label: const Text('Escuchar los saludos'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Color(0xFFFFD78A), size: 28),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('INSTRUCCIONES: lee la pregunta en inglés, escucha el audio si lo necesitas y selecciona la respuesta correcta.', style: TextStyle(fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('🦉 Questy says:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Let’s practice greetings!', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    item.question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _spanishHint(item.question),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
                    onPressed: () => speakEnglish(item.question),
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Listen in English'),
                  ),
                ],
              ),
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

String _spanishHint(String question) {
  switch (question) {
    case 'What do you say when you meet someone?':
      return '¿Qué dices cuando conoces a alguien?';
    case 'What is the best answer to “How are you?”':
      return '¿Cuál es la mejor respuesta a “¿Cómo estás?”';
    case 'Which expression means “Adiós”?':
      return '¿Qué expresión significa “Adiós”?';
    case 'Complete: “Nice to ___ you.”':
      return 'Completa: “Mucho gusto en ___ contigo”.';
    default:
      return 'Lee la pregunta y elige la mejor respuesta.';
  }
}

class _GreetingPhrase extends StatelessWidget {
  final String english;
  final String spanish;

  const _GreetingPhrase({required this.english, required this.spanish});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.chat_bubble_outline, color: Color(0xFFFFD78A), size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(english, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
          Expanded(child: Text(spanish, textAlign: TextAlign.end, style: const TextStyle(color: Colors.white70, fontSize: 14))),
          IconButton(
            tooltip: 'Escuchar $english',
            onPressed: () => speakEnglish(english),
            icon: const Icon(Icons.volume_up, size: 20),
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
                  const QuestyAvatar(size: 86),
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
