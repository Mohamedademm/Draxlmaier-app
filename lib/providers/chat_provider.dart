import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../models/chat_group_model.dart';
import '../services/chat_service.dart';
import '../services/socket_service.dart';

/// Chat state management provider
class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final SocketService _socketService = SocketService();

  List<Message> _messages = [];
  List<ChatGroup> _groups = [];
  List<Map<String, dynamic>> _conversations = [];
  Map<String, bool> _typingUsers = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<Message> get messages => _messages;
  List<ChatGroup> get groups => _groups;
  List<Map<String, dynamic>> get conversations => _conversations;
  Map<String, bool> get typingUsers => _typingUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize socket connection and listeners
  Future<void> initializeSocket() async {
    try {
      await _socketService.connect();
      
      // Listen for incoming messages
      _socketService.onMessage((data) {
        final message = Message.fromJson(data);
        _messages.add(message);
        notifyListeners();
      });

      // Listen for typing indicators
      _socketService.onTyping((data) {
        final userId = data['userId'];
        final isTyping = data['isTyping'];
        _typingUsers[userId] = isTyping;
        notifyListeners();
      });

      // Listen for message status updates
      _socketService.onMessageStatus((data) {
        final messageId = data['messageId'];
        final status = data['status'];
        
        final index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(
            status: MessageStatus.values.firstWhere(
              (s) => s.name == status,
              orElse: () => MessageStatus.sent,
            ),
          );
          notifyListeners();
        }
      });
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Disconnect socket
  void disconnectSocket() {
    _socketService.disconnect();
  }

  /// Load chat history
  Future<void> loadChatHistory({
    String? recipientId,
    String? groupId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await _chatService.getChatHistory(
        recipientId: recipientId,
        groupId: groupId,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load conversations
  Future<void> loadConversations() async {
    _isLoading = true;
    notifyListeners();

    try {
      _conversations = await _chatService.getConversations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send message
  void sendMessage({
    required String content,
    String? recipientId,
    String? groupId,
  }) {
    try {
      _socketService.sendMessage({
        'content': content,
        'recipientId': recipientId,
        'groupId': groupId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Join chat room
  void joinRoom(String roomId) {
    _socketService.joinRoom(roomId);
  }

  /// Leave chat room
  void leaveRoom(String roomId) {
    _socketService.leaveRoom(roomId);
  }

  /// Send typing indicator
  void sendTyping(String roomId, bool isTyping) {
    _socketService.sendTyping(roomId, isTyping);
  }

  /// Mark messages as read
  Future<void> markAsRead(String chatId, {bool isGroup = false}) async {
    try {
      await _chatService.markAsRead(chatId, isGroup: isGroup);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Load chat groups
  Future<void> loadGroups() async {
    _isLoading = true;
    notifyListeners();

    try {
      _groups = await _chatService.getChatGroups();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create chat group
  Future<ChatGroup?> createGroup({
    required String name,
    required List<String> memberIds,
  }) async {
    try {
      final group = await _chatService.createChatGroup(
        name: name,
        memberIds: memberIds,
      );
      _groups.add(group);
      notifyListeners();
      return group;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Clear messages
  void clearMessages() {
    _messages = [];
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
