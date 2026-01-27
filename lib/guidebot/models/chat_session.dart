import 'package:isar/isar.dart';

part 'chat_session.g.dart';

@collection
class ChatSession {
  Id id = Isar.autoIncrement;
  late DateTime createdAt;
  late List<ChatMessage> messages;
}

@embedded
class ChatMessage {
  late String sender;
  late String content;
  late DateTime timestamp;
}