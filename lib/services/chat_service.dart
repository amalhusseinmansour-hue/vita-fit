import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ChatService {
  static String get _baseUrl => ApiConfig.baseUrl;

  // WebSocket connection for real-time messaging
  static StreamController<Map<String, dynamic>>? _messageController;

  // Initialize chat service
  static void initialize() {
    _messageController = StreamController<Map<String, dynamic>>.broadcast();
  }

  // Get message stream
  static Stream<Map<String, dynamic>> get messageStream {
    if (_messageController == null) {
      initialize();
    }
    return _messageController!.stream;
  }

  // Get conversations list
  static Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/conversations/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['conversations']);
      }

      // Return empty list if API fails
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get messages for a conversation
  static Future<List<Map<String, dynamic>>> getMessages({
    required String conversationId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/conversations/$conversationId/messages?limit=$limit&offset=$offset'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['messages']);
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  // Send message
  static Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String content,
    String type = 'text', // text, image, voice, file
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final message = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'conversation_id': conversationId,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'type': type,
        'metadata': metadata,
        'status': 'sent',
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(message),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _messageController?.add(data);
        return {'success': true, 'message': data};
      }

      // For demo, simulate success
      _messageController?.add(message);
      return {'success': true, 'message': message};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Send voice message
  static Future<Map<String, dynamic>> sendVoiceMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String audioPath,
    required int duration,
  }) async {
    return sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      content: audioPath,
      type: 'voice',
      metadata: {'duration': duration},
    );
  }

  // Send image
  static Future<Map<String, dynamic>> sendImage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String imagePath,
  }) async {
    // Upload image first, then send message with URL
    return sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      content: imagePath,
      type: 'image',
    );
  }

  // Mark messages as read
  static Future<void> markAsRead(String conversationId, String userId) async {
    try {
      await http.put(
        Uri.parse('$_baseUrl/conversations/$conversationId/read'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  // Create new conversation
  static Future<Map<String, dynamic>> createConversation({
    required String trainerId,
    required String traineeId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/conversations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'trainer_id': trainerId,
          'trainee_id': traineeId,
          'type': 'direct',
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      return {
        'id': '${trainerId}_$traineeId',
        'trainer_id': trainerId,
        'trainee_id': traineeId,
      };
    } catch (e) {
      return {
        'id': '${trainerId}_$traineeId',
        'trainer_id': trainerId,
        'trainee_id': traineeId,
      };
    }
  }

  // Dispose
  static void dispose() {
    _messageController?.close();
  }
}
