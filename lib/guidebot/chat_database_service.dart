import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/chat_session.dart';

class ChatDatabaseService {
  static final ChatDatabaseService _instance = ChatDatabaseService._internal();
  factory ChatDatabaseService() => _instance;
  ChatDatabaseService._internal();

  Isar? _isar;

  Future<void> initialize() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [ChatSessionSchema],
      directory: dir.path,
    );
  }

  Isar get isar {
    if (_isar == null) {
      throw Exception('Chat database not initialized. Call initialize() first.');
    }
    return _isar!;
  }

  // Create a new chat session
  Future<ChatSession> createSession() async {
    final session = ChatSession()
      ..createdAt = DateTime.now()
      ..messages = [];
    await isar.writeTxn(() async {
      await isar.chatSessions.put(session);
    });
    return session;
  }

  // Save a message to the current session
  Future<void> saveMessage(ChatSession session, String sender, String content) async {
    final message = ChatMessage()
      ..sender = sender
      ..content = content
      ..timestamp = DateTime.now();
    session.messages.add(message);

    await isar.writeTxn(() async {
      await isar.chatSessions.put(session);
    });
  }

  // Get all sessions sorted by creation date (desc)
  Future<List<ChatSession>> getAllSessions() async {
    return await isar.chatSessions.where().sortByCreatedAtDesc().findAll();
  }

  // Delete selected sessions
  Future<void> deleteSessions(List<int> sessionIds) async {
    await isar.writeTxn(() async {
      await isar.chatSessions.deleteAll(sessionIds);
    });
  }
}
