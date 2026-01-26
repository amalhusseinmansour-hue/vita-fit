import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'api_service.dart';

/// Document types for upload
enum DocumentType {
  identity,           // الهوية
  experienceCertificate, // شهادة الخبرة
  professionalLicense,   // رخصة مزاولة المهنة
}

/// Document Upload Service
/// Handles uploading identity documents and certificates
class DocumentUploadService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  static Future<File?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Camera pick error: $e');
      return null;
    }
  }

  /// Pick image from gallery
  static Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Gallery pick error: $e');
      return null;
    }
  }

  /// Upload document to server
  static Future<Map<String, dynamic>> uploadDocument({
    required File file,
    required DocumentType documentType,
    required String userId,
  }) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'يرجى تسجيل الدخول أولاً'};
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/documents/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add fields
      request.fields['user_id'] = userId;
      request.fields['document_type'] = _getDocumentTypeString(documentType);

      // Add file
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final fileName = file.path.split('/').last;

      final multipartFile = http.MultipartFile(
        'document',
        fileStream,
        fileLength,
        filename: fileName,
      );
      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 2),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'تم رفع المستند بنجاح',
          'document_url': data['url'],
          'document_id': data['id'],
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'فشل رفع المستند',
        };
      }
    } catch (e) {
      debugPrint('Document upload error: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال: $e',
      };
    }
  }

  /// Upload trainer documents (all required documents)
  static Future<Map<String, dynamic>> uploadTrainerDocuments({
    required String trainerId,
    required File identityDocument,
    required File experienceCertificate,
    required File professionalLicense,
  }) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'يرجى تسجيل الدخول أولاً'};
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/trainers/documents');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add trainer ID
      request.fields['trainer_id'] = trainerId;

      // Add identity document
      request.files.add(await http.MultipartFile.fromPath(
        'identity_document',
        identityDocument.path,
      ));

      // Add experience certificate
      request.files.add(await http.MultipartFile.fromPath(
        'experience_certificate',
        experienceCertificate.path,
      ));

      // Add professional license
      request.files.add(await http.MultipartFile.fromPath(
        'professional_license',
        professionalLicense.path,
      ));

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 3),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message': 'تم رفع جميع المستندات بنجاح',
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'فشل رفع المستندات',
        };
      }
    } catch (e) {
      debugPrint('Trainer documents upload error: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال: $e',
      };
    }
  }

  /// Upload trainee identity for account activation
  static Future<Map<String, dynamic>> uploadTraineeIdentity({
    required String traineeId,
    required File identityDocument,
  }) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'يرجى تسجيل الدخول أولاً'};
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/trainees/verify-identity');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add trainee ID
      request.fields['trainee_id'] = traineeId;

      // Add identity document
      request.files.add(await http.MultipartFile.fromPath(
        'identity_document',
        identityDocument.path,
      ));

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 2),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message': 'تم رفع الهوية بنجاح. سيتم مراجعة حسابك وتفعيله قريباً',
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'فشل رفع الهوية',
        };
      }
    } catch (e) {
      debugPrint('Trainee identity upload error: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال: $e',
      };
    }
  }

  static String _getDocumentTypeString(DocumentType type) {
    switch (type) {
      case DocumentType.identity:
        return 'identity';
      case DocumentType.experienceCertificate:
        return 'experience_certificate';
      case DocumentType.professionalLicense:
        return 'professional_license';
    }
  }

  /// Get document type name in Arabic
  static String getDocumentTypeName(DocumentType type) {
    switch (type) {
      case DocumentType.identity:
        return 'الهوية';
      case DocumentType.experienceCertificate:
        return 'شهادة الخبرة';
      case DocumentType.professionalLicense:
        return 'رخصة مزاولة المهنة';
    }
  }
}
