import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../models/chat_group_model.dart';
import '../services/chat_service.dart';
import '../services/socket_service.dart';
import '../services/cache_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final SocketService _socketService = SocketService();
  final CacheService _cacheService = CacheService();

  List<Message> _messages = [];
  List<ChatGroup> _groups = [];
  List<Map<String, dynamic>> _conversations = [];
  final Map<String, bool> _typingUsers = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<Message> get messages => _messages;
  List<ChatGroup> get groups => _groups;
  List<Map<String, dynamic>> get conversations => _conversations;
  Map<String, bool> get typingUsers => _typingUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initializeSocket() async {
    try {
      await _socketService.connect();
      
      _socketService.onMessage((data) {
        final message = Message.fromJson(data);
        _messages.add(message);
        notifyListeners();
      });

      _socketService.onTyping((data) {
        final userId = data['userId'];
        final isTyping = data['isTyping'];
        _typingUsers[userId] = isTyping;
        notifyListeners();
      });

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

  void disconnectSocket() {
    _socketService.disconnect();
  }

  Future<void> loadChatHistory({
    String? recipientId,
    String? groupId,
  }) async {
    _isLoading = true;
    notifyListeners();

    final String cacheKey = groupId != null 
        ? CacheService.chatHistoryKey(groupId) 
        : CacheService.chatHistoryKey(recipientId ?? 'unknown');

    try {
      final cachedData = _cacheService.getData(cacheKey);
      if (cachedData != null && cachedData is List && cachedData.isNotEmpty) {
        try {
          _messages = cachedData
              .where((item) => item != null)
              .map((json) => Message.fromJson(json as Map<String, dynamic>))
              .toList();
          notifyListeners();
        } catch (parseError) {
          debugPrint('Error parsing cached messages: $parseError');
          _messages = [];
        }
      }
    } catch (e) {
      debugPrint('Error loading from cache: $e');
    }

    try {
      final messages = await _chatService.getChatHistory(
        recipientId: recipientId,
        groupId: groupId,
      );
      
      _messages = messages;
      
      try {
        final messagesJson = messages.map((m) => m.toJson()).toList();
        await _cacheService.saveData(cacheKey, messagesJson);
      } catch (e) {
        debugPrint('Error saving to cache: $e');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

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

  void joinRoom(String roomId) {
    _socketService.joinRoom(roomId);
  }

  void leaveRoom(String roomId) {
    _socketService.leaveRoom(roomId);
  }

  void sendTyping(String roomId, bool isTyping) {
    _socketService.sendTyping(roomId, isTyping);
  }

  Future<void> markAsRead(String chatId, {bool isGroup = false}) async {
    try {
      await _chatService.markAsRead(chatId, isGroup: isGroup);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

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

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
