import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utils/constants.dart';
import 'api_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final ApiService _apiService = ApiService();

  bool get isConnected => _socket?.connected ?? false;

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

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void emit(String event, dynamic data) {
    if (_socket == null || !_socket!.connected) {
      throw Exception('Socket not connected');
    }
    _socket!.emit(event, data);
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void joinRoom(String roomId) {
    print('🚪 Socket emitting joinRoom: $roomId');
    emit('joinRoom', roomId);
  }

  void leaveRoom(String roomId) {
    print('👋 Socket emitting leaveRoom: $roomId');
    emit('leaveRoom', roomId);
  }

  void sendMessage(Map<String, dynamic> messageData) {
    print('📤 Socket emitting sendMessage: $messageData');
    emit('sendMessage', messageData);
  }

  void sendTyping(String roomId, bool isTyping) {
    emit('typing', {
      'roomId': roomId,
      'isTyping': isTyping,
    });
  }

  void onMessage(Function(dynamic) callback) {
    on('receiveMessage', callback);
  }

  void onTyping(Function(dynamic) callback) {
    on('userTyping', callback);
  }

  void onMessageStatus(Function(dynamic) callback) {
    on('messageStatus', callback);
  }
}
