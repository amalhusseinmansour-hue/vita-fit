import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class VideoSessionService {
  static String get _baseUrl => ApiConfig.baseUrl;

  // Zoom API credentials (set from backend)
  static String? _zoomApiKey;
  static String? _zoomApiSecret;

  // Initialize with credentials from backend
  static void initialize({
    String? zoomApiKey,
    String? zoomApiSecret,
  }) {
    _zoomApiKey = zoomApiKey;
    _zoomApiSecret = zoomApiSecret;
  }

  // ==================== SESSION MANAGEMENT ====================

  // Create a new training session
  static Future<Map<String, dynamic>> createSession({
    required String trainerId,
    required String traineeId,
    required DateTime scheduledAt,
    required int durationMinutes,
    required String sessionType, // 'private', 'group'
    String? title,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sessions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'trainer_id': trainerId,
          'trainee_id': traineeId,
          'scheduled_at': scheduledAt.toIso8601String(),
          'duration_minutes': durationMinutes,
          'session_type': sessionType,
          'title': title ?? 'جلسة تدريبية',
          'description': description,
          'status': 'scheduled',
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      // Demo response
      return _createDemoSession(
        trainerId: trainerId,
        traineeId: traineeId,
        scheduledAt: scheduledAt,
        durationMinutes: durationMinutes,
        sessionType: sessionType,
        title: title,
      );
    } catch (e) {
      return _createDemoSession(
        trainerId: trainerId,
        traineeId: traineeId,
        scheduledAt: scheduledAt,
        durationMinutes: durationMinutes,
        sessionType: sessionType,
        title: title,
      );
    }
  }

  // Get upcoming sessions for user
  static Future<List<Map<String, dynamic>>> getUpcomingSessions(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sessions/upcoming/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['sessions']);
      }

      return _getDemoUpcomingSessions();
    } catch (e) {
      return _getDemoUpcomingSessions();
    }
  }

  // Get session history
  static Future<List<Map<String, dynamic>>> getSessionHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sessions/history/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['sessions']);
      }

      return _getDemoSessionHistory();
    } catch (e) {
      return _getDemoSessionHistory();
    }
  }

  // ==================== ZOOM INTEGRATION ====================

  // Create Zoom meeting
  static Future<Map<String, dynamic>> createZoomMeeting({
    required String topic,
    required DateTime startTime,
    required int duration,
    String? agenda,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/zoom/meetings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'topic': topic,
          'type': 2, // Scheduled meeting
          'start_time': startTime.toUtc().toIso8601String(),
          'duration': duration,
          'timezone': 'Asia/Riyadh',
          'agenda': agenda,
          'settings': {
            'host_video': true,
            'participant_video': true,
            'join_before_host': false,
            'mute_upon_entry': true,
            'waiting_room': true,
            'audio': 'both',
            'auto_recording': 'cloud',
          },
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      // Demo Zoom meeting
      return _createDemoZoomMeeting(topic, startTime, duration);
    } catch (e) {
      return _createDemoZoomMeeting(topic, startTime, duration);
    }
  }

  // Get Zoom meeting details
  static Future<Map<String, dynamic>?> getZoomMeeting(String meetingId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/zoom/meetings/$meetingId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Generate Zoom join URL for participant
  static String getZoomJoinUrl(String meetingId, String password) {
    return 'https://zoom.us/j/$meetingId?pwd=$password';
  }

  // ==================== VIDEO CALL (WEBRTC/AGORA) ====================

  // Get video call token (for Agora or similar)
  static Future<Map<String, dynamic>> getVideoCallToken({
    required String channelName,
    required String odentifier,
    required int role, // 1 = host, 2 = audience
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/video/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'channel_name': channelName,
          'uid': odentifier,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      // Demo token
      return {
        'token': 'demo_token_${DateTime.now().millisecondsSinceEpoch}',
        'channel': channelName,
        'uid': odentifier,
      };
    } catch (e) {
      return {
        'token': 'demo_token_${DateTime.now().millisecondsSinceEpoch}',
        'channel': channelName,
        'uid': odentifier,
      };
    }
  }

  // ==================== SESSION ACTIONS ====================

  // Start session
  static Future<Map<String, dynamic>> startSession(String sessionId) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/sessions/$sessionId/start'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': true,
        'session_id': sessionId,
        'status': 'in_progress',
        'started_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'success': true,
        'session_id': sessionId,
        'status': 'in_progress',
        'started_at': DateTime.now().toIso8601String(),
      };
    }
  }

  // End session
  static Future<Map<String, dynamic>> endSession(String sessionId) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/sessions/$sessionId/end'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': true,
        'session_id': sessionId,
        'status': 'completed',
        'ended_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'success': true,
        'session_id': sessionId,
        'status': 'completed',
        'ended_at': DateTime.now().toIso8601String(),
      };
    }
  }

  // Cancel session
  static Future<Map<String, dynamic>> cancelSession(String sessionId, String reason) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/sessions/$sessionId/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': true,
        'session_id': sessionId,
        'status': 'cancelled',
        'reason': reason,
      };
    } catch (e) {
      return {
        'success': true,
        'session_id': sessionId,
        'status': 'cancelled',
        'reason': reason,
      };
    }
  }

  // Reschedule session
  static Future<Map<String, dynamic>> rescheduleSession(
    String sessionId,
    DateTime newTime,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/sessions/$sessionId/reschedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'new_time': newTime.toIso8601String()}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': true,
        'session_id': sessionId,
        'new_scheduled_at': newTime.toIso8601String(),
      };
    } catch (e) {
      return {
        'success': true,
        'session_id': sessionId,
        'new_scheduled_at': newTime.toIso8601String(),
      };
    }
  }

  // ==================== DEMO DATA ====================

  static Map<String, dynamic> _createDemoSession({
    required String trainerId,
    required String traineeId,
    required DateTime scheduledAt,
    required int durationMinutes,
    required String sessionType,
    String? title,
  }) {
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    return {
      'id': sessionId,
      'trainer_id': trainerId,
      'trainee_id': traineeId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'session_type': sessionType,
      'title': title ?? 'جلسة تدريبية',
      'status': 'scheduled',
      'meeting_platform': 'zoom',
      'meeting_link': 'https://zoom.us/j/demo',
      'meeting_id': '${800000000 + int.parse(sessionId.substring(sessionId.length - 8))}',
      'meeting_password': 'VitaFit123',
      'zoom_meeting': {
        'meeting_id': '${800000000 + int.parse(sessionId.substring(sessionId.length - 8))}',
        'password': 'VitaFit123',
        'join_url': 'https://zoom.us/j/demo',
        'host_url': 'https://zoom.us/s/demo',
      },
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> _createDemoZoomMeeting(
    String topic,
    DateTime startTime,
    int duration,
  ) {
    final meetingId = '${800000000 + DateTime.now().millisecondsSinceEpoch % 100000000}';
    return {
      'id': meetingId,
      'topic': topic,
      'start_time': startTime.toIso8601String(),
      'duration': duration,
      'password': 'VitaFit123',
      'join_url': 'https://zoom.us/j/$meetingId?pwd=VitaFit123',
      'host_url': 'https://zoom.us/s/$meetingId?zak=demo_host_key',
    };
  }

  static List<Map<String, dynamic>> _getDemoUpcomingSessions() {
    return [
      {
        'id': '1',
        'title': 'تدريب القوة',
        'trainer': {
          'id': 't1',
          'name': 'كوتش سارة',
          'avatar': '',
        },
        'trainee': {
          'id': 'u1',
          'name': 'نورة أحمد',
        },
        'scheduled_at': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
        'duration_minutes': 45,
        'session_type': 'private',
        'status': 'scheduled',
        'meeting_platform': 'zoom',
        'meeting_link': 'https://zoom.us/j/851234567890',
        'meeting_id': '851234567890',
        'meeting_password': 'VitaFit123',
        'zoom_meeting': {
          'meeting_id': '851234567890',
          'password': 'VitaFit123',
          'join_url': 'https://zoom.us/j/851234567890',
        },
      },
      {
        'id': '2',
        'title': 'يوغا صباحية',
        'trainer': {
          'id': 't2',
          'name': 'كوتش منى',
          'avatar': '',
        },
        'trainee': {
          'id': 'u1',
          'name': 'نورة أحمد',
        },
        'scheduled_at': DateTime.now().add(const Duration(days: 1, hours: 8)).toIso8601String(),
        'duration_minutes': 60,
        'session_type': 'group',
        'status': 'scheduled',
        'meeting_platform': 'google_meet',
        'meeting_link': 'https://meet.google.com/abc-defg-hij',
        'meeting_id': 'abc-defg-hij',
      },
    ];
  }

  static List<Map<String, dynamic>> _getDemoSessionHistory() {
    return [
      {
        'id': 'h1',
        'title': 'تدريب كارديو',
        'trainer': {
          'id': 't1',
          'name': 'كوتش سارة',
        },
        'scheduled_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'duration_minutes': 30,
        'actual_duration': 32,
        'session_type': 'private',
        'status': 'completed',
        'rating': 5,
        'notes': 'أداء ممتاز!',
      },
      {
        'id': 'h2',
        'title': 'تمارين المقاومة',
        'trainer': {
          'id': 't1',
          'name': 'كوتش سارة',
        },
        'scheduled_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'duration_minutes': 45,
        'actual_duration': 48,
        'session_type': 'private',
        'status': 'completed',
        'rating': 4,
        'notes': 'تحسن ملحوظ في الأداء',
      },
    ];
  }
}
