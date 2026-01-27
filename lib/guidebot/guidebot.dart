import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/chat_session.dart';
//import 'chat_database_service.dart';
import 'package:hydra_cal/database.dart';
import 'package:hydra_cal/calorie-tracker/constants/app_colors.dart';

const String huggingFaceApiKey = "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";

class GuideBotScreen extends StatelessWidget {
  const GuideBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GuideBot(title: 'GuideBot');
  }
}

class GuideBot extends StatefulWidget {
  const GuideBot({super.key, required this.title});
  final String title;

  @override
  State<GuideBot> createState() => _GuideBotState();
}

class _GuideBotState extends State<GuideBot> {
  final AppDatabaseService _db = AppDatabaseService();
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  bool isLoading = false;
  ChatSession? currentSession;

  final Map<String, dynamic> userDescription = {
    "name": "John Doe",
    "age": 25,
    "interests": ["programming", "AI", "flutter"],
    "location": "New York",
    "experience_level": "intermediate",
  };

  @override
  void initState() {
    super.initState();
    _createNewSession();
  }

  Future<void> _createNewSession() async {
    final session = await _db.createSession();

    setState(() {
      currentSession = session;
      messages = [];
    });
  }


  Future<void> _saveMessage(String sender, String content) async {
    if (currentSession == null) return;

    await _db.saveMessage(currentSession!, sender, content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatHistoryPage()),
              );
            },
          ),
        ],
        iconTheme: const IconThemeData(
          color: Colors.white, // ensures back button is white
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              reverse: true,
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: messages.map((msg) {
                        final isUser = msg['sender'] == 'user';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[400],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg['text']!,
                                style: TextStyle(
                                  color: isUser
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      labelText: 'Enter your message',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: isLoading ? null : updateChat,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: isLoading ? null : () => updateChat(_controller.text),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void updateChat(String message) async {
    final msg = message.trim();
    if (msg.isEmpty) return;

    setState(() {
      messages.add({'sender': 'user', 'text': msg});
      _controller.clear();
      FocusScope.of(context).unfocus();
      isLoading = true;
    });

    await _saveMessage('user', msg);

    setState(() {
      messages.add({'sender': 'bot', 'text': 'GuideBot is typing...'});
    });

    final response = await fetchBotResponse(msg, userDescription);

    setState(() {
      messages.removeLast();
      messages.add({'sender': 'bot', 'text': response});
      isLoading = false;
    });

    await _saveMessage('bot', response);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ChatHistoryPage extends StatefulWidget {

  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  final AppDatabaseService _db = AppDatabaseService();
  
  late List<ChatSession> sessions = [];
  bool isDeleteMode = false;
  Set<int> selectedSessions = {};

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final loadedSessions = await _db.getAllSessions();
    setState(() {
      sessions = loadedSessions;
    });
  }


  Future<void> _deleteSessions(Set<int> sessionIds) async {
    await _db.deleteSessions(sessionIds.toList());
    await _loadSessions();

    setState(() {
      isDeleteMode = false;
      selectedSessions.clear();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: sessions.isEmpty
          ? const Center(
              child: Text('No chat sessions yet'),
            )
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final isSelected = selectedSessions.contains(session.id);
                return ListTile(
                  leading: isDeleteMode
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedSessions.add(session.id);
                              } else {
                                selectedSessions.remove(session.id);
                              }
                            });
                          },
                        )
                      : null,
                  title: Text('Session ${session.id}'),
                  subtitle: Text(
                    '${session.messages.length} messages - ${session.createdAt.toString().split('.')[0]}',
                  ),
                  onTap: isDeleteMode
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailPage(session: session),
                            ),
                          );
                        },
                );
              },
            ),
      floatingActionButton: isDeleteMode
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'select-all',
                  onPressed: () {
                    setState(() {
                      if (selectedSessions.length == sessions.length) {
                        selectedSessions.clear();
                      } else {
                        selectedSessions = sessions.map((s) => s.id).toSet();
                      }
                    });
                  },
                  child: const Icon(Icons.select_all),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'delete',
                  backgroundColor: Colors.red,
                  onPressed: selectedSessions.isEmpty
                      ? null
                      : () {
                          _deleteSessions(selectedSessions);
                        },
                  child: const Icon(Icons.delete),
                ),
              ],
            )
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  isDeleteMode = !isDeleteMode;
                  selectedSessions.clear();
                });
              },
              child: const Icon(Icons.delete),
            ),
    );
  }
}

class ChatDetailPage extends StatelessWidget {
  final ChatSession session;
  const ChatDetailPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Session ${session.id}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: session.messages.isEmpty
          ? const Center(
              child: Text('No messages in this session'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: session.messages.length,
              itemBuilder: (context, index) {
                final message = session.messages[index];
                final isUser = message.sender == 'user';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.deepPurple : Colors.grey[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message.content,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
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

Future<String> fetchBotResponse(
    String userMessage, Map<String, dynamic> userDescription) async {
  const String apiUrl = "https://router.huggingface.co/v1/chat/completions";

  try {
    print('Sending request to HF API with message: $userMessage');

    final systemPrompt = '''
You are a helpful guide for an app called HydroCal. HydroCal is a hydration, food and calorie monitoring app. You will assist users with questions about hydration, calorie tracking, food scanning, or any general health and wellness topics only.
''';

    final response = await http
        .post(
          Uri.parse(apiUrl),
          headers: {
            "Authorization": "Bearer $huggingFaceApiKey",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "messages": [
              {"role": "system", "content": systemPrompt},
              {"role": "user", "content": userMessage}
            ],
            "model": "mistralai/Mistral-7B-Instruct-v0.2:featherless-ai",
          }),
        )
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            print('Request timeout');
            throw Exception('Request timeout');
          },
        );

    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final message = data["choices"][0]["message"]["content"] ?? "No response";
      return message;
    } else if (response.statusCode == 503) {
      return "Model is loading. Please wait and try again.";
    } else {
      return "Error ${response.statusCode}";
    }
  } catch (e) {
    print('Error: $e');
    return "Error: $e";
  }
}
