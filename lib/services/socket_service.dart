import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utils/constants.dart';
import 'api_service.dart';

/// Socket service handling real-time WebSocket communication
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final ApiService _apiService = ApiService();

  /// Check if socket is connected
  bool get isConnected => _socket?.connected ?? false;

  /// Initialize and connect to the socket server
  Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      return;
    }

    final token = await _apiService.getToken();
    
    if (token == null) {
      throw Exception('No authentication token found');
    }

    _socket = IO.io(
      ApiConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('✅ Socket connected to ${ApiConstants.socketUrl}');
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket disconnected');
    });

    _socket!.onError((error) {
      print('⚠️ Socket error: $error');
    });

    _socket!.onConnectError((error) {
      print('⚠️ Socket connect error: $error');
    });
  }

  /// Disconnect from the socket server
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  /// Emit an event to the server
  void emit(String event, dynamic data) {
    if (_socket == null || !_socket!.connected) {
      throw Exception('Socket not connected');
    }
    _socket!.emit(event, data);
  }

  /// Listen to an event from the server
  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  /// Remove listener for an event
  void off(String event) {
    _socket?.off(event);
  }

  /// Join a chat room
  void joinRoom(String roomId) {
    print('🚪 Socket emitting joinRoom: $roomId');
    emit('joinRoom', roomId);
  }

  /// Leave a chat room
  void leaveRoom(String roomId) {
    print('👋 Socket emitting leaveRoom: $roomId');
    emit('leaveRoom', roomId);
  }

  /// Send a message
  void sendMessage(Map<String, dynamic> messageData) {
    print('📤 Socket emitting sendMessage: $messageData');
    emit('sendMessage', messageData);
  }

  /// Send typing indicator
  void sendTyping(String roomId, bool isTyping) {
    emit('typing', {
      'roomId': roomId,
      'isTyping': isTyping,
    });
  }

  /// Listen for incoming messages
  void onMessage(Function(dynamic) callback) {
    on('receiveMessage', callback);
  }

  /// Listen for typing indicators
  void onTyping(Function(dynamic) callback) {
    on('userTyping', callback);
  }

  /// Listen for message status updates
  void onMessageStatus(Function(dynamic) callback) {
    on('messageStatus', callback);
  }
}
