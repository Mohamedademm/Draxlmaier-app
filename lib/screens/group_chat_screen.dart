import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../models/chat_group_model.dart';
import '../models/message_model.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:http_parser/http_parser.dart';
import '../utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';


class GroupChatScreen extends StatefulWidget {
  final ChatGroup group;

  const GroupChatScreen({
    super.key,
    required this.group,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final ChatService _chatService = ChatService();
  final SocketService _socketService = SocketService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  Timer? _connectionStatusTimer;
  
  List<int>? _selectedFileBytes;
  String? _selectedFileName;
  String? _selectedFileType;

  late final AudioRecorder _audioRecorder;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  
  String? _playingUrl;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  
  

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _initializeChat();
    
    _connectionStatusTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {});
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (state == PlayerState.completed) {
            _playingUrl = null;
            _currentPosition = Duration.zero;
          }
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() => _currentPosition = position);
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() => _totalDuration = duration);
      }
    });
  }

  @override
  void dispose() {
    _connectionStatusTimer?.cancel();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _socketService.leaveRoom(widget.group.id);
    _socketService.off('receiveMessage');
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    await _loadMessages();
    
    await _connectSocket();
  }

  Future<void> _connectSocket() async {
    try {
      if (!_socketService.isConnected) {
        debugPrint('🔌 Connecting to Socket.IO...');
        await _socketService.connect();
        debugPrint('✅ Socket.IO connected');
      }

      debugPrint('🚪 Joining room: ${widget.group.id}');
      _socketService.joinRoom(widget.group.id);
      debugPrint('✅ Joined room: ${widget.group.id}');

      _socketService.on('receiveMessage', (data) {
        debugPrint('📩 Received message data: $data');
        
        if (!mounted) return;

        try {
          final message = Message.fromJson(data);
          debugPrint('📧 Parsed message: id=${message.id}, content="${message.content}", groupId=${message.groupId}');
          
          if (message.groupId == widget.group.id) {
            final authProvider = context.read<AuthProvider>();
            final currentUserId = authProvider.currentUser?.id;
            
            message.isMe = message.senderId == currentUserId;
            debugPrint('👤 Message isMe: ${message.isMe}, currentUserId: $currentUserId');
            
            setState(() {
              _messages.removeWhere((m) => m.id.startsWith('temp_') && m.content == message.content);
            });
            
            final exists = _messages.any((m) => m.id == message.id);
            
            if (!exists) {
              debugPrint('➕ Adding message to list');
              setState(() {
                _messages.add(message);
              });
              
              _scrollToBottom();
            } else {
              debugPrint('⚠️ Message already exists, skipping');
            }
          } else {
            debugPrint('⚠️ Message for different group: ${message.groupId} vs ${widget.group.id}');
          }
        } catch (e) {
          debugPrint('❌ Error processing received message: $e');
        }
      });
      
      debugPrint('✅ Socket listeners configured for group ${widget.group.name}');
    } catch (e) {
      debugPrint('❌ Error connecting socket: $e');
    }
  }

  Future<void> _loadMessages() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final currentUserId = authProvider.currentUser?.id;
      
      final messages = await _chatService.getChatHistory(
        groupId: widget.group.id,
        limit: 50,
      );

      for (var message in messages) {
        message.isMe = message.senderId == currentUserId;
      }

      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });

        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom({bool immediate = false}) {
    if (_scrollController.hasClients) {
      if (immediate) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } else {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        
        setState(() {
          _selectedFileBytes = bytes;
          _selectedFileName = image.name;
          _selectedFileType = 'image';
        });
        
        await _sendMessageWithFile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'jpg', 'jpeg', 'png'],
        withData: true, // Important pour le web: charge les bytes
      );

      if (result != null) {
        final file = result.files.single;
        String? ext = file.extension?.toLowerCase();
        
        if (ext == null) {
           final name = file.name.toLowerCase();
           if (name.endsWith('.jpg') || name.endsWith('.jpeg')) {
             ext = 'jpg';
           } else if (name.endsWith('.png')) {
             ext = 'png';
           } else if (name.endsWith('.gif')) {
             ext = 'gif';
           } else if (name.endsWith('.webp')) {
             ext = 'webp';
           } else if (name.endsWith('.pdf')) {
             ext = 'pdf';
           }
        }

        String type;
        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
          type = 'image';
        } else if (ext == 'pdf') {
          type = 'pdf';
        } else {
          type = 'document';
        }

        List<int> bytes;
        if (file.bytes != null) {
          bytes = file.bytes!;
        } else if (file.path != null) {
          
          
          
          if (file.path != null && file.bytes == null) {
             return; 
          }
          bytes = file.bytes!;
        } else {
           return;
        }
        
        if (file.bytes == null && file.path != null && !kIsWeb) {
           try {
             bytes = file.bytes!;
           } catch (e) {
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Impossible de lire le fichier")));
             }
             return;
           }
        } else {
           bytes = file.bytes!;
        }

        setState(() {
          _selectedFileBytes = bytes;
          _selectedFileName = file.name;
          _selectedFileType = type;

        });
        
        await _sendMessageWithFile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection du fichier: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Joindre un fichier',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt, color: Color(0xFF0EA5E9)),
              ),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library, color: Color(0xFF06B6D4)),
              ),
              title: const Text('Choisir une image'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.picture_as_pdf, color: Colors.red),
              ),
              title: const Text('Choisir un document (PDF, DOC, etc.)'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessageWithFile() async {
    if (_selectedFileBytes == null) return;

    setState(() => _isSending = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final currentUserId = authProvider.currentUser?.id;
      final currentUser = authProvider.currentUser;
      final currentUserName = currentUser != null 
          ? '${currentUser.firstname} ${currentUser.lastname}'
          : 'Unknown';

      String? fileUrl = await _uploadFile(_selectedFileBytes!, _selectedFileName!, _selectedFileType!);

      if (fileUrl != null) {
        final content = _selectedFileType == 'image' 
            ? '📷 Image' 
            : '📄 ${_selectedFileName ?? 'Document'}';

        final tempMessage = Message(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          content: content,
          senderId: currentUserId ?? '',
          senderName: currentUserName,
          groupId: widget.group.id,
          timestamp: DateTime.now(),
          fileUrl: fileUrl,
          fileName: _selectedFileName,
          fileType: _selectedFileType,
          isMe: true,
        );

        setState(() {
          _messages.add(tempMessage);
          _selectedFileBytes = null;
          _selectedFileName = null;
          _selectedFileType = null;
        });

        _scrollToBottom();

        _socketService.sendMessage({
          'content': content,
          'groupId': widget.group.id,
          'senderId': currentUserId,
          'senderName': currentUserName,
          'fileUrl': fileUrl,
          'fileName': _selectedFileName,
          'fileType': _selectedFileType,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      setState(() => _isSending = false);
      
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi du fichier: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadFile(List<int> fileBytes, String fileName, String fileType) async {
    try {
      final apiService = ApiService();
      final token = await apiService.getToken();

      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/upload'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
        contentType: _getMediaType(fileName),
      ));
      request.fields['fileType'] = fileType;

      debugPrint('📤 Uploading file to: ${ApiConstants.baseUrl}/upload');
      debugPrint('📄 File: $fileName, Type: $fileType, Size: ${fileBytes.length} bytes');

      var response = await request.send().timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          throw Exception('Le téléchargement a pris trop de temps. Vérifiez votre connexion.');
        },
      );
      
      var responseBody = await response.stream.bytesToString();
      
      debugPrint('📥 Upload response: $responseBody (status: ${response.statusCode})');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        final fileUrl = jsonResponse['fileUrl'];
        
        if (fileUrl == null) {
          throw Exception('fileUrl manquant dans la réponse du serveur');
        }
        
        debugPrint('✅ File uploaded successfully: $fileUrl');
        return fileUrl;
      } else {
        throw Exception('Upload failed with status: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      debugPrint('❌ Error uploading file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'upload: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return null;
    }
  }

  MediaType _getMediaType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'doc':
        return MediaType('application', 'msword');
      case 'docx':
        return MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document');
      case 'xls':
        return MediaType('application', 'vnd.ms-excel');
      case 'xlsx':
        return MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      case 'txt':
        return MediaType('text', 'plain');
      case 'mp3':
        return MediaType('audio', 'mpeg');
      case 'm4a':
        return MediaType('audio', 'mp4');
      case 'wav':
        return MediaType('audio', 'wav');
      case 'aac':
        return MediaType('audio', 'aac');
      case 'webm':
        return MediaType('audio', 'webm');
      case 'ogg':
        return MediaType('audio', 'ogg');
      default:
        return MediaType('application', 'octet-stream');
    }
  }


  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        String path = '';
        
        if (!kIsWeb) {
           try {
             final dir = await getTemporaryDirectory();
             path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
           } catch (e) {
             debugPrint('Error getting temp dir: $e');
           }
        }

        await _audioRecorder.start(const RecordConfig(), path: path);
        
        setState(() {
          _isRecording = true;
          _recordingPath = path;
          _recordingDuration = Duration.zero;
        });

        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingDuration += const Duration(seconds: 1);
          });
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });
      
      if (path != null) {
        _sendVoiceMessage(path);
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> _cancelRecording() async {
    _recordingTimer?.cancel();
    await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _recordingPath = null;
      _recordingDuration = Duration.zero;
    });
  }

  Future<void> _sendVoiceMessage(String path) async {
    try {
      List<int> bytes;
      String fileName;
      
      if (kIsWeb) {
        final response = await http.get(Uri.parse(path));
        bytes = response.bodyBytes;
        fileName = 'Voice_${DateTime.now().millisecondsSinceEpoch}.webm';
      } else {
        final file = XFile(path);
        bytes = await file.readAsBytes();
        fileName = 'Voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }
      
      setState(() => _isSending = true);

      final fileUrl = await _uploadFile(bytes, fileName, 'audio');
      
      if (fileUrl != null && mounted) {
        final authProvider = context.read<AuthProvider>();
        final currentUserId = authProvider.currentUser?.id;
        final currentUserName = authProvider.currentUser != null 
            ? '${authProvider.currentUser!.firstname} ${authProvider.currentUser!.lastname}'
            : 'Unknown';

        final content = '🎤 Message vocal';

        _socketService.sendMessage({
          'content': content,
          'groupId': widget.group.id,
          'senderId': currentUserId,
          'senderName': currentUserName,
          'fileUrl': fileUrl,
          'fileName': fileName,
          'fileType': 'audio',
          'timestamp': DateTime.now().toIso8601String(),
        });
        
         final tempMessage = Message(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          content: content,
          senderId: currentUserId ?? '',
          senderName: currentUserName,
          groupId: widget.group.id,
          timestamp: DateTime.now(),
          fileUrl: fileUrl,
          fileName: fileName,
          fileType: 'audio',
          isMe: true,
        );

        setState(() {
          _messages.add(tempMessage);
        });
        _scrollToBottom();
      }
      
      setState(() => _isSending = false);
    } catch (e) {
      setState(() => _isSending = false);
      debugPrint('Error sending voice message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Erreur envoi vocal: $e')),
        );
      }
    }
  }

  Future<void> _playAudio(String url) async {
    try {
      if (_playingUrl == url && _isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(url));
        setState(() {
          _playingUrl = url;
        });
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }
  
  Future<void> _launchURL(String url) async {
    final sanitizedUrl = _sanitizeUrl(url);
    
    final fileName = sanitizedUrl.split('/').last.split('?').first;
    final extension = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    
    if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].contains(extension)) {
      await _downloadAndOpenFile(sanitizedUrl, fileName);
      return;
    }
    
    final Uri uri = Uri.parse(sanitizedUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await _downloadAndOpenFile(sanitizedUrl, fileName.isNotEmpty ? fileName : 'file');
    }
  }
  
  Future<void> _downloadAndOpenFile(String url, String fileName) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Téléchargement en cours...'),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/$fileName';
        final file = File(filePath);
        
        await file.writeAsBytes(response.bodyBytes);
        
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
        
        try {
          final result = await OpenFilex.open(filePath);
          debugPrint('Open result: ${result.message}');
          
          if (result.type != ResultType.done) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fichier sauvegardé: $filePath')),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fichier téléchargé: $filePath')),
            );
          }
        }
      } else {
        throw Exception('Erreur de téléchargement: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error downloading file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    final content = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isSending = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final currentUserId = authProvider.currentUser?.id;
      final currentUser = authProvider.currentUser;
      final currentUserName = currentUser != null 
          ? '${currentUser.firstname} ${currentUser.lastname}'
          : 'Unknown';

      final tempMessage = Message(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        content: content,
        senderId: currentUserId ?? '',
        senderName: currentUserName,
        groupId: widget.group.id,
        timestamp: DateTime.now(),
        isMe: true,
      );

      setState(() {
        _messages.add(tempMessage);
      });

      _scrollToBottom();

      _socketService.sendMessage({
        'content': content,
        'groupId': widget.group.id,
        'senderId': currentUserId,
        'senderName': currentUserName,
        'timestamp': DateTime.now().toIso8601String(),
      });

      setState(() => _isSending = false);
      
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildModernMessageBubble(Message message, bool isMe) {
    final time = DateFormat('HH:mm').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0EA5E9),
                    Color(0xFF06B6D4),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0EA5E9).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.transparent,
                child: Text(
                  message.senderName?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe && message.senderName != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 4),
                    child: Text(
                      message.senderName!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0EA5E9),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isMe
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF0EA5E9),
                              Color(0xFF0891B2),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.grey.shade50,
                            ],
                          ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    border: isMe
                        ? null
                        : Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: isMe
                            ? const Color(0xFF0EA5E9).withOpacity(0.3)
                            : Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.fileUrl != null) ...[
                        if (message.fileType == 'image')
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              message.fileUrl!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 200,
                                  height: 200,
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 200,
                                  height: 200,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.broken_image, size: 50),
                                );
                              },
                            ),
                          )
                        else if (message.fileType == 'pdf')
                          InkWell(
                            onTap: () => _launchURL(message.fileUrl!),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.white.withOpacity(0.2) : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isMe ? Colors.white.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    color: isMe ? Colors.white : Colors.red,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message.fileName ?? 'Document PDF',
                                          style: TextStyle(
                                            color: isMe ? Colors.white : Colors.black87,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'PDF • Cliquez pour télécharger',
                                          style: TextStyle(
                                            color: isMe ? Colors.white.withOpacity(0.7) : Colors.black54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.download_rounded,
                                    color: isMe ? Colors.white : Colors.black54,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (message.fileType == 'audio')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            width: 200,
                            decoration: BoxDecoration(
                              color: isMe ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _playingUrl == message.fileUrl && _isPlaying 
                                        ? Icons.pause_circle_filled 
                                        : Icons.play_circle_filled,
                                    color: isMe ? Colors.white : const Color(0xFF0EA5E9),
                                    size: 36,
                                  ),
                                  onPressed: () => _playAudio(message.fileUrl!),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                                          trackHeight: 2,
                                          activeTrackColor: isMe ? Colors.white : const Color(0xFF0EA5E9),
                                          inactiveTrackColor: isMe ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                                          thumbColor: isMe ? Colors.white : const Color(0xFF0EA5E9),
                                        ),
                                        child: Slider(
                                          value: (_playingUrl == message.fileUrl) 
                                              ? _currentPosition.inSeconds.toDouble()
                                              : 0.0,
                                          max: (_playingUrl == message.fileUrl && _totalDuration.inSeconds > 0)
                                              ? _totalDuration.inSeconds.toDouble()
                                              : 1.0,
                                          onChanged: (value) async {
                                            if (_playingUrl == message.fileUrl) {
                                              await _audioPlayer.seek(Duration(seconds: value.toInt()));
                                            }
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          _playingUrl == message.fileUrl
                                            ? '${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')}'
                                            : 'Message vocal',
                                          style: TextStyle(
                                            color: isMe ? Colors.white.withOpacity(0.8) : Colors.grey[600],
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          InkWell(
                            onTap: () => _launchURL(message.fileUrl!),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.white.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isMe ? Colors.white.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.insert_drive_file,
                                    color: isMe ? Colors.white : Colors.blue,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message.fileName ?? 'Document',
                                          style: TextStyle(
                                            color: isMe ? Colors.white : Colors.black87,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Document • Cliquez pour télécharger',
                                          style: TextStyle(
                                            color: isMe ? Colors.white.withOpacity(0.7) : Colors.black54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 15,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isMe && message.id.startsWith('temp_')) ...[
                            SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                          ] else ...[
                            Icon(
                              Icons.access_time,
                              size: 10,
                              color: isMe ? Colors.white.withOpacity(0.8) : Colors.black45,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            message.id.startsWith('temp_') ? 'Envoi...' : time,
                            style: TextStyle(
                              fontSize: 10,
                              color: isMe ? Colors.white.withOpacity(0.8) : Colors.black45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0EA5E9),
                Color(0xFF06B6D4),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.group,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.group.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${widget.group.memberCount} membres',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _socketService.isConnected 
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _socketService.isConnected 
                        ? Colors.green.shade300
                        : Colors.orange.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _socketService.isConnected 
                            ? Colors.green
                            : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _socketService.isConnected ? 'En ligne' : 'Connexion...',
                      style: TextStyle(
                        fontSize: 11,
                        color: _socketService.isConnected 
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () => _showGroupInfo(),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0EA5E9),
                          Color(0xFF06B6D4),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0EA5E9).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Chargement des messages...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0EA5E9).withOpacity(0.08),
                        const Color(0xFF06B6D4).withOpacity(0.04),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFF0EA5E9).withOpacity(0.15),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0EA5E9).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Color(0xFF0EA5E9),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.group.description ?? 'Chat de groupe pour le département ${widget.group.department}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF0891B2),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF0EA5E9).withOpacity(0.1),
                                      const Color(0xFF06B6D4).withOpacity(0.05),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Aucun message',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Soyez le premier à envoyer un message',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(8),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isMe = message.senderId == currentUserId;
                            return _buildModernMessageBubble(message, isMe);
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.attach_file, color: Color(0xFF0EA5E9)),
                          onPressed: _showAttachmentOptions,
                          tooltip: 'Joindre un fichier',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _isRecording 
                            ? Row(
                                children: [
                                  const SizedBox(width: 16),
                                  const Icon(Icons.mic, color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_recordingDuration.inMinutes}:${(_recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.grey),
                                    onPressed: _cancelRecording,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.send, color: Color(0xFF0EA5E9)),
                                    onPressed: _stopRecording,
                                  ),
                                ],
                              )
                            : TextField(
                                controller: _messageController,
                                decoration: const InputDecoration(
                                  hintText: 'Écrivez votre message...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                maxLines: null,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _sendMessage(),
                              ),
                        ),
                      const SizedBox(width: 10),
                      if (!_isRecording && _messageController.text.isEmpty)
                         Container(
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.mic, color: Color(0xFF0EA5E9)),
                            onPressed: _startRecording,
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0EA5E9),
                              Color(0xFF06B6D4),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0EA5E9).withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isSending ? null : _sendMessage,
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: _isSending
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showGroupInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.group.name.isNotEmpty ? widget.group.name.substring(0, 1).toUpperCase() : 'G',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.group.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.group.isDepartmentGroup 
                                ? Colors.purple.withOpacity(0.1) 
                                : Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.group.isDepartmentGroup ? 'Département' : 'Groupe Personnalisé',
                            style: TextStyle(
                              color: widget.group.isDepartmentGroup ? Colors.purple : Colors.blue,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  if (widget.group.description != null && widget.group.description!.isNotEmpty) ...[
                    const Text(
                      'DESCRIPTION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        widget.group.description!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  const Text(
                    'DÉTAILS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        if (widget.group.department != null)
                          ListTile(
                            leading: const Icon(Icons.business, color: Colors.blueGrey),
                            title: const Text('Département'),
                            subtitle: Text(widget.group.department!),
                          ),
                        ListTile(
                          leading: const Icon(Icons.people_outline, color: Colors.blueGrey),
                          title: const Text('Membres'),
                          subtitle: Text('${widget.group.memberCount} participants'),
                        ),
                        if (widget.group.admins != null)
                          ListTile(
                            leading: const Icon(Icons.admin_panel_settings_outlined, color: Colors.blueGrey),
                            title: const Text('Administrateurs'),
                            subtitle: Text('${widget.group.admins!.length} admins'),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Fermer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sanitizeUrl(String url) {
    if (url.startsWith('/')) {
       return '${ApiConstants.socketUrl}$url';
    }

    if (url.contains('localhost:10000')) {
       return url.replaceFirst('http://localhost:10000', ApiConstants.socketUrl);
    }
    if (url.contains('http://')) {
        return url.replaceFirst('http://', 'https://');
    }
    return url;
  }

  Widget _buildModernMessageBubble(Message message, bool isMe) {

    final time = DateFormat('HH:mm').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
             CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE0F2FE),
                child: Text(
                  message.senderName?.substring(0, 1).toUpperCase() ?? '?',
                  style: const TextStyle(
                    color: Color(0xFF0284C7),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe && message.senderName != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      message.senderName!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF0EA5E9) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.fileUrl != null) ...[
                        if (message.fileType == 'image')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: () {
                                     showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            InteractiveViewer(
                                              child: Image.network(_sanitizeUrl(message.fileUrl!)),
                                            ),
                                            Positioned(
                                              top: 10,
                                              right: 10,
                                              child: IconButton(
                                                icon: const Icon(Icons.close, color: Colors.white),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.network(
                                    _sanitizeUrl(message.fileUrl!),
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 150,
                                        width: double.infinity,
                                        color: Colors.grey[100],
                                        child: const Center(child: CircularProgressIndicator()),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const SizedBox(
                                          height: 100, 
                                          child: Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                        );
                                    },
                                  ),
                                ),
                              ),
                              if (message.content.isNotEmpty && message.content != '📷 Image') 
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    message.content,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                            ],
                          )
                        else if (message.fileType == 'audio')
                           Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => _playAudio(_sanitizeUrl(message.fileUrl!)),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isMe ? Colors.white.withOpacity(0.2) : const Color(0xFFF0F9FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _playingUrl == _sanitizeUrl(message.fileUrl!) && _isPlaying 
                                          ? Icons.pause_rounded 
                                          : Icons.play_arrow_rounded,
                                      color: isMe ? Colors.white : const Color(0xFF0EA5E9),
                                      size: 30,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                       Container(
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: isMe ? Colors.white.withOpacity(0.3) : Colors.grey[200],
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            final percent = (_playingUrl == _sanitizeUrl(message.fileUrl!) && _totalDuration.inSeconds > 0)
                                                ? (_currentPosition.inSeconds / _totalDuration.inSeconds).clamp(0.0, 1.0)
                                                : 0.0;
                                            return Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                width: constraints.maxWidth * percent,
                                                decoration: BoxDecoration(
                                                  color: isMe ? Colors.white : const Color(0xFF0EA5E9),
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _playingUrl == _sanitizeUrl(message.fileUrl!)
                                            ? '${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')}'
                                            : 'Message vocal',
                                        style: TextStyle(
                                          color: isMe ? Colors.white.withOpacity(0.9) : Colors.grey[600],
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                        else
                          InkWell(
                            onTap: () => _launchURL(_sanitizeUrl(message.fileUrl!)),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.white.withOpacity(0.15) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isMe ? Colors.white.withOpacity(0.2) : Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isMe ? Colors.white.withOpacity(0.2) : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      message.fileType == 'pdf' ? Icons.picture_as_pdf_rounded : Icons.description_rounded,
                                      color: isMe ? Colors.white : (message.fileType == 'pdf' ? Colors.red : const Color(0xFF0EA5E9)),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message.fileName ?? 'Fichier',
                                          style: TextStyle(
                                            color: isMe ? Colors.white : Colors.black87,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Cliquez pour ouvrir',
                                          style: TextStyle(
                                            color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey[500],
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ] else ...[
                        Text(
                          message.content,
                          style: TextStyle(
                            color: isMe ? Colors.white : const Color(0xFF1E293B),
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                           Text(
                            time,
                            style: TextStyle(
                              color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey[400],
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isMe && message.id.startsWith('temp_')) ...[
                              const SizedBox(width: 4),
                              const SizedBox(
                                width: 8, 
                                height: 8, 
                                child: CircularProgressIndicator(strokeWidth: 1, color: Colors.white)
                              ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
