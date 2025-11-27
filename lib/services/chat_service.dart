import '../models/message_model.dart';
import '../models/chat_group_model.dart';
import 'api_service.dart';

/// Chat service handling chat-related API calls
class ChatService {
  final ApiService _apiService = ApiService();

  /// Get chat history for a specific chat
  Future<List<Message>> getChatHistory({
    String? recipientId,
    String? groupId,
    int limit = 50,
    int skip = 0,
  }) async {
    try {
      String endpoint = '/messages/history?limit=$limit&skip=$skip';
      
      if (recipientId != null) {
        endpoint += '&recipientId=$recipientId';
      }
      
      if (groupId != null) {
        endpoint += '&groupId=$groupId';
      }

      final response = await _apiService.get(endpoint);
      final data = _apiService.handleResponse(response);
      
      final List<dynamic> messagesJson = data['messages'];
      return messagesJson.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get chat history: $e');
    }
  }

  /// Get all chat conversations
  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final response = await _apiService.get('/messages/conversations');
      final data = _apiService.handleResponse(response);
      return List<Map<String, dynamic>>.from(data['conversations']);
    } catch (e) {
      throw Exception('Failed to get conversations: $e');
    }
  }

  /// Mark messages as read
  Future<void> markAsRead(String chatId, {bool isGroup = false}) async {
    try {
      await _apiService.post('/messages/mark-read', {
        'chatId': chatId,
        'isGroup': isGroup,
      });
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  /// Get all chat groups
  Future<List<ChatGroup>> getChatGroups() async {
    try {
      final response = await _apiService.get('/groups');
      final data = _apiService.handleResponse(response);
      
      final List<dynamic> groupsJson = data['groups'];
      return groupsJson.map((json) => ChatGroup.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get chat groups: $e');
    }
  }

  /// Create chat group
  Future<ChatGroup> createChatGroup({
    required String name,
    required List<String> memberIds,
  }) async {
    try {
      final response = await _apiService.post('/groups', {
        'name': name,
        'members': memberIds,
      });
      
      final data = _apiService.handleResponse(response);
      return ChatGroup.fromJson(data['group']);
    } catch (e) {
      throw Exception('Failed to create chat group: $e');
    }
  }

  /// Add members to chat group
  Future<ChatGroup> addGroupMembers({
    required String groupId,
    required List<String> memberIds,
  }) async {
    try {
      final response = await _apiService.post('/groups/$groupId/members', {
        'members': memberIds,
      });
      
      final data = _apiService.handleResponse(response);
      return ChatGroup.fromJson(data['group']);
    } catch (e) {
      throw Exception('Failed to add group members: $e');
    }
  }

  /// Remove member from chat group
  Future<ChatGroup> removeGroupMember({
    required String groupId,
    required String memberId,
  }) async {
    try {
      final response = await _apiService.delete('/groups/$groupId/members/$memberId');
      final data = _apiService.handleResponse(response);
      return ChatGroup.fromJson(data['group']);
    } catch (e) {
      throw Exception('Failed to remove group member: $e');
    }
  }
}
