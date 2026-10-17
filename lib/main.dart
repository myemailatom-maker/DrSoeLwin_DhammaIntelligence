import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // import လုပ်ရန်

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gmiugowuyzpzezshrkse.supabase.co',
    anonKey: 'sb_publishable_yqYIBYJvSVuBi33UyHp58A_okcU0--P',
  );
	// .env ဖိုင်ကို ဖတ်ရှုရန်
  //await dotenv.load(fileName: ".env");
  // .env ဖိုင် မရှိပါက Error မတက်စေရန် try-catch အုပ်ထားပါ

  runApp(const DrSoeLwinApp());
}

class DhammaItem {
  final String? id;
  final String title;
  final String category;
  final String date;
  final String url;
  final String audioUrl;

  const DhammaItem({
    this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.url,
    required this.audioUrl,
  });

  factory DhammaItem.fromMap(Map<String, dynamic> map) {
    return DhammaItem(
      id: map['id']?.toString(),
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      date: map['date'] ?? '',
      url: map['url'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
    );
  }
}

class DrSoeLwinApp extends StatefulWidget {
  const DrSoeLwinApp({super.key});

  @override
  State<DrSoeLwinApp> createState() => _DrSoeLwinAppState();
}

class _DrSoeLwinAppState extends State<DrSoeLwinApp> {
  // Dark Mode / Light Mode ထိန်းချုပ်ရန် State
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ဆရာကြီး ဒေါက်တာစိုးလွင်',
      themeMode: _themeMode,
      // Light Theme (Day Mode)
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695C),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // Dark Theme (Night Mode)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF80CBC4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: MainHomeScreen(toggleTheme: toggleTheme, currentThemeMode: _themeMode),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Desktop အတွက် NavigationRail သုံးထားသော ပင်မ Screen
class MainHomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode currentThemeMode;

  const MainHomeScreen({super.key, required this.toggleTheme, required this.currentThemeMode});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const TapesHomePage(),
      const DhammaAiChatPage(),
      const SocialLinksPage(),
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
            selectedLabelTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.library_books_rounded),
                label: Text('တရားတော်များ'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.psychology_rounded),
                label: Text('AI ဓမ္မမိတ်ဆွေ'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.link_rounded),
                label: Text('Web & Social'),
              ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: IconButton(
                    icon: Icon(
                      widget.currentThemeMode == ThemeMode.dark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                    ),
                    onPressed: widget.toggleTheme,
                    tooltip: 'Theme ပြောင်းရန်',
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: pages[_currentIndex],
          ),
        ],
      ),
    );
  }
}

// ၁။ တရားတော်များ Page (Modern Material 3 Card Design)
class TapesHomePage extends StatefulWidget {
  const TapesHomePage({super.key});

  @override
  State<TapesHomePage> createState() => _TapesPageState();
}

class _TapesPageState extends State<TapesHomePage> {
  late Future<List<DhammaItem>> _futureTapes;
  String _selectedCategory = 'အားလုံး';

  @override
  void initState() {
    super.initState();
    _futureTapes = _fetchTapes();
  }

  Future<List<DhammaItem>> _fetchTapes() async {
    try {
      final response = await Supabase.instance.client.from('tapes').select();
      final dataList = response as List<dynamic>;
      return dataList.map((json) => DhammaItem.fromMap(json)).toList();
    } catch (e) {
      debugPrint('Error fetching tapes: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ဆရာကြီး ဒေါက်တာစိုးလွင်', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildCategoryChip('အားလုံး'),
                const SizedBox(width: 8),
                _buildCategoryChip('ဝိပဿနာ'),
                const SizedBox(width: 8),
                _buildCategoryChip('သတိပဋ္ဌာန်'),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<DhammaItem>>(
              future: _futureTapes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('အမှားရှိပါသည်: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('တရားတော်များ မရှိသေးပါ။'));
                }

                final allTapes = snapshot.data!;
                final filteredTapes = _selectedCategory == 'အားလုံး'
                    ? allTapes
                    : allTapes.where((t) => t.category == _selectedCategory).toList();

                if (filteredTapes.isEmpty) {
                  return const Center(child: Text('ဤအမျိုးအစားအတွက် တရားတော် မရှိသေးပါ။'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredTapes.length,
                  itemBuilder: (context, index) {
                    final tape = filteredTapes[index];
                    return Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            FilledButton.tonal(
                              onPressed: () => _openAudioPlayer(context, tape.title, tape.audioUrl),
                              style: FilledButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(16),
                              ),
                              child: const Icon(Icons.headphones_rounded, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tape.title,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${tape.category} • ${tape.date}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton.filledTonal(
                              icon: const Icon(Icons.play_arrow_rounded),
                              onPressed: () async {
                                final uri = Uri.parse(tape.url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String categoryName) {
    final isSelected = _selectedCategory == categoryName;
    return ChoiceChip(
      label: Text(categoryName),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = categoryName;
        });
      },
    );
  }

  void _openAudioPlayer(BuildContext context, String title, String audioUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: SizedBox(
          width: 400,
          height: 300,
          child: AudioPlayerWidget(title: title, audioUrl: audioUrl),
        ),
      ),
    );
  }
}

// ၂. AI ဓမ္မမိတ်ဆွေ Chat Box Screen (Modern UI)
class DhammaAiChatPage extends StatefulWidget {
  const DhammaAiChatPage({super.key});

  @override
  State<DhammaAiChatPage> createState() => _DhammaAiChatPageState();
}

class _DhammaAiChatPageState extends State<DhammaAiChatPage> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'ai',
      'text': 'မင်္ဂလာပါ။ ဘဝရဲ့ အမောအပန်းများ၊ စိတ်ပင်ပန်းမှုများနှင့် ပတ်သက်၍ ဓမ္မသဘောဖြင့် မေးမြန်းဆွေးနွေးနိုင်ပါတယ်ခင်ဗျာ။'
    }
  ];
  bool _isLoading = false;

  
  
// API Key ယူသည့်နေရာတွင် Env မရှိပါက Environment variable မှ ယူရန်:
 // final String _geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? 
 static const String _geminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: '',
);

  final String _systemPrompt = '''
သင်သည် ဗုဒ္ဓဘာသာ တရားဓမ္မများနှင့် ဆရာကြီး ဒေါက်တာစိုးလွင်၏ ဟောပြောဆုံးမမှု အခြေခံများကို အပြည့်အဝ နှလုံးသွင်းထားသော "ဓမ္မမိတ်ဆွေ AI Assistant" ဖြစ်သည်။
သင်၏ အဓိက တာဝန်မှာ စီးပွားရေး၊ လူမှုရေး၊ နိုင်ငံရေးနှင့် သဘာဝဘေးဒဏ်များကြောင့် ဘဝအမောများနှင့် စိတ်ပင်ပန်းဆင်းရဲမှုကို ခံစားနေရသော လူသားများ၏ ခံစားချက်ကို နားလည်စာနာပေးရန် (Empathy) နှင့် တရားသဘောဖြင့် စိတ်ကို နှစ်သိမ့်ကုစားပေးရန် ဖြစ်သည်။
''';

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    _textController.clear();

    final List<String> models = ['gemini-3.8-flash', 'gemini-3.6-flash', 'gemini-3.5-flash', 'gemini-3.5-flash-lite'];
    String? aiReply;

    for (String modelName in models) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$_geminiApiKey',
        );

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "system_instruction": {
              "parts": [{"text": _systemPrompt}]
            },
            "contents": [
              {
                "parts": [{"text": text}]
              }
            ]
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          aiReply = data['candidates'][0]['content']['parts'][0]['text'];
          if (aiReply != null && aiReply.isNotEmpty) break;
        }
      } catch (e) {
        debugPrint('Model $modelName failed: $e');
      }
    }

    setState(() {
      if (aiReply != null && aiReply.isNotEmpty) {
        _messages.add({'sender': 'ai', 'text': aiReply});
      } else {
        _messages.add({
          'sender': 'ai',
          'text': 'လက်ရှိတွင် AI ဆာဗာများ အလုပ်များနေပါ၍ ခဏအကြာမှ ထပ်မံကြိုးစားပေးပါခင်ဗျာ။'
        });
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI ဓမ္မမိတ်ဆွေ', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: const BoxConstraints(maxWidth: 600),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        color: isUser
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 10),
                  Text('ဓမ္မမိတ်ဆွေမှ စာစဉ်းစားနေပါသည်...'),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'စိတ်ထဲရှိသော စိုးရိမ်မှု သို့မဟုတ် ဓမ္မမေးခွန်းများကို ရေးသားပါ...',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ၃. Web & Social Links Screen
class SocialLinksPage extends StatelessWidget {
  const SocialLinksPage({super.key});

  final List<Map<String, dynamic>> socialLinks = const [
    {
      'title': 'YouTube Channel',
      'subtitle': 'တရားတော် ဗီဒီယိုများ ကြည့်ရှုရန်',
      'icon': Icons.video_library_rounded,
      'url': 'https://www.youtube.com/@Drsoelwinmandalayofficial',
      'color': Colors.red
    },
    {
      'title': 'TikTok Tapes',
      'subtitle': 'တရားစကား တိုတိုများ',
      'icon': Icons.music_note_rounded,
      'url': 'https://www.tiktok.com/@dr.soelwinmandalay',
      'color': Colors.grey
    },
    {
      'title': 'Official Web Page',
      'subtitle': 'စာစောင်များနှင့် အခြားအချက်အလက်များ',
      'icon': Icons.web_rounded,
      'url': 'https://drsoelwin.com/',
      'color': Colors.blue
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web & Social Links', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: socialLinks.length,
        itemBuilder: (context, index) {
          final link = socialLinks[index];
          return Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: link['color'],
                child: Icon(link['icon'], color: Colors.white),
              ),
              title: Text(link['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(link['subtitle']),
              ),
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: () async {
                final uri = Uri.parse(link['url']);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

// ၄. Audio Player Widget
class AudioPlayerWidget extends StatefulWidget {
  final String title;
  final String audioUrl;

  const AudioPlayerWidget({super.key, required this.title, required this.audioUrl});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setUrl(widget.audioUrl);
      _audioPlayer.durationStream.listen((d) => setState(() => _duration = d ?? Duration.zero));
      _audioPlayer.positionStream.listen((p) => setState(() => _position = p));
      _audioPlayer.playerStateStream.listen((s) => setState(() => _isPlaying = s.playing));
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Icon(Icons.music_note_rounded, size: 50, color: Colors.teal),
          const SizedBox(height: 10),
          Text(
            widget.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Slider(
            min: 0,
            max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0,
            value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0),
            onChanged: (v) async => await _audioPlayer.seek(Duration(seconds: v.toInt())),
          ),
          IconButton.filled(
            iconSize: 40,
            icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
            onPressed: () async => _isPlaying ? await _audioPlayer.pause() : await _audioPlayer.play(),
          ),
        ],
      ),
    );
  }
}
