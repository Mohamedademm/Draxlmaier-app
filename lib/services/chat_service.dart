import '../models/message_model.dart';
import '../models/chat_group_model.dart';
import 'api_service.dart';

class ChatService {
  final ApiService _apiService = ApiService();

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
      return messagesJson.map((json) {
        if (json['senderId'] is Map) {
          final sender = json['senderId'];
          json['senderName'] = '${sender['firstname']} ${sender['lastname']}';
          json['senderId'] = sender['_id'] ?? sender['id'];
        }
        return Message.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get chat history: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final response = await _apiService.get('/messages/conversations');
      final data = _apiService.handleResponse(response);
      return List<Map<String, dynamic>>.from(data['conversations']);
    } catch (e) {
      throw Exception('Failed to get conversations: $e');
    }
  }

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

  Future<ChatGroup> getDepartmentGroup() async {
    try {
      final response = await _apiService.get('/groups/department/my-group');
      final data = _apiService.handleResponse(response);
      return ChatGroup.fromJson(data['group']);
    } catch (e) {
      throw Exception('Failed to get department group: $e');
    }
  }

  Future<Message> sendGroupMessage({
    required String groupId,
    required String content,
  }) async {
    try {
      final response = await _apiService.post('/messages', {
        'groupId': groupId,
        'content': content,
        'type': 'group',
      });
      
      final data = _apiService.handleResponse(response);
      final messageJson = data['message'];
      
      if (messageJson['senderId'] is Map) {
        final sender = messageJson['senderId'];
        messageJson['senderName'] = '${sender['firstname']} ${sender['lastname']}';
        messageJson['senderId'] = sender['_id'] ?? sender['id'];
      }
      
      return Message.fromJson(messageJson);
    } catch (e) {
      throw Exception('Failed to send group message: $e');
    }
  }

  Future<List<ChatGroup>> getDepartmentGroups() async {
    try {
      final response = await _apiService.get('/groups/department/all');
      final data = _apiService.handleResponse(response);
      
      final List<dynamic> groupsJson = data['groups'];
      return groupsJson.map((json) => ChatGroup.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get department groups: $e');
    }
  }

  Future<ChatGroup> createDepartmentGroup({
    required String name,
    required String department,
    String? description,
  }) async {
    try {
      final response = await _apiService.post('/groups/department/create', {
        'name': name,
        'department': department,
        'description': description,
      });
      
      final data = _apiService.handleResponse(response);
      return ChatGroup.fromJson(data['group']);
    } catch (e) {
      throw Exception('Failed to create department group: $e');
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await _apiService.delete('/groups/$groupId');
    } catch (e) {
      throw Exception('Failed to delete group: $e');
    }
  }

  Future<void> clearGroupMessages(String groupId) async {
    try {
      await _apiService.delete('/groups/$groupId/messages');
    } catch (e) {
      throw Exception('Failed to clear group messages: $e');
    }
  }
}
