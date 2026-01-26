<?php
/**
 * VitaFit Contact Form Handler
 * Handles contact form submissions including trainer document uploads
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only accept POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit();
}

// Configuration
$upload_dir = __DIR__ . '/uploads/documents/';
$admin_email = 'info@vitafit.online';
$max_file_size = 10 * 1024 * 1024; // 10MB
$allowed_types = ['image/jpeg', 'image/png', 'image/jpg', 'application/pdf'];

// Create upload directory if not exists
if (!file_exists($upload_dir)) {
    mkdir($upload_dir, 0755, true);
}

// Get form data
$name = trim($_POST['name'] ?? '');
$email = trim($_POST['email'] ?? '');
$phone = trim($_POST['phone'] ?? '');
$subject = trim($_POST['subject'] ?? '');
$message = trim($_POST['message'] ?? '');

// Validate required fields
if (empty($name) || empty($email) || empty($subject) || empty($message)) {
    echo json_encode(['success' => false, 'message' => 'جميع الحقول المطلوبة يجب ملؤها']);
    exit();
}

// Validate email
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(['success' => false, 'message' => 'البريد الإلكتروني غير صحيح']);
    exit();
}

// Handle trainer documents
$uploaded_files = [];
$is_trainer_request = ($subject === 'trainer');

if ($is_trainer_request) {
    $required_docs = ['identity', 'experience_certificate', 'professional_license'];

    foreach ($required_docs as $doc_name) {
        if (!isset($_FILES[$doc_name]) || $_FILES[$doc_name]['error'] === UPLOAD_ERR_NO_FILE) {
            echo json_encode(['success' => false, 'message' => 'يرجى رفع جميع المستندات المطلوبة']);
            exit();
        }

        $file = $_FILES[$doc_name];

        // Check for upload errors
        if ($file['error'] !== UPLOAD_ERR_OK) {
            echo json_encode(['success' => false, 'message' => 'خطأ في رفع الملف: ' . $doc_name]);
            exit();
        }

        // Check file size
        if ($file['size'] > $max_file_size) {
            echo json_encode(['success' => false, 'message' => 'حجم الملف كبير جداً (الحد الأقصى 10MB)']);
            exit();
        }

        // Check file type
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mime_type = finfo_file($finfo, $file['tmp_name']);
        finfo_close($finfo);

        if (!in_array($mime_type, $allowed_types)) {
            echo json_encode(['success' => false, 'message' => 'نوع الملف غير مسموح. يرجى رفع صور أو PDF فقط']);
            exit();
        }

        // Generate unique filename
        $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
        $safe_name = preg_replace('/[^a-zA-Z0-9]/', '_', $name);
        $filename = date('Y-m-d_H-i-s') . '_' . $safe_name . '_' . $doc_name . '.' . $ext;
        $filepath = $upload_dir . $filename;

        // Move uploaded file
        if (move_uploaded_file($file['tmp_name'], $filepath)) {
            $uploaded_files[$doc_name] = $filename;
        } else {
            echo json_encode(['success' => false, 'message' => 'فشل في حفظ الملف']);
            exit();
        }
    }
}

// Prepare email content
$subject_labels = [
    'general' => 'استفسار عام',
    'technical' => 'مشكلة تقنية',
    'subscription' => 'الاشتراكات والدفع',
    'trainer' => 'طلب انضمام كمدربة',
    'partnership' => 'شراكات تجارية',
    'other' => 'أخرى'
];

$subject_label = $subject_labels[$subject] ?? $subject;

$email_subject = "VitaFit - {$subject_label} - {$name}";

$email_body = "
<!DOCTYPE html>
<html dir='rtl'>
<head>
    <meta charset='UTF-8'>
    <style>
        body { font-family: 'Segoe UI', Tahoma, sans-serif; background: #f5f5f5; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background: #fff; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #FF69B4, #BA55D3); color: white; padding: 30px; text-align: center; }
        .header h1 { margin: 0; font-size: 24px; }
        .content { padding: 30px; }
        .field { margin-bottom: 20px; padding: 15px; background: #f9f9f9; border-radius: 8px; }
        .field-label { font-weight: bold; color: #FF69B4; margin-bottom: 5px; }
        .field-value { color: #333; }
        .message-box { background: #fff5f9; border-right: 4px solid #FF69B4; padding: 15px; margin-top: 20px; }
        .docs-section { background: #f0fff0; border: 1px solid #90EE90; border-radius: 8px; padding: 15px; margin-top: 20px; }
        .docs-title { color: #228B22; font-weight: bold; margin-bottom: 10px; }
        .footer { background: #333; color: #999; padding: 20px; text-align: center; font-size: 12px; }
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>رسالة جديدة من VitaFit</h1>
        </div>
        <div class='content'>
            <div class='field'>
                <div class='field-label'>الاسم:</div>
                <div class='field-value'>{$name}</div>
            </div>
            <div class='field'>
                <div class='field-label'>البريد الإلكتروني:</div>
                <div class='field-value'><a href='mailto:{$email}'>{$email}</a></div>
            </div>";

if (!empty($phone)) {
    $email_body .= "
            <div class='field'>
                <div class='field-label'>رقم الجوال:</div>
                <div class='field-value'><a href='tel:{$phone}'>{$phone}</a></div>
            </div>";
}

$email_body .= "
            <div class='field'>
                <div class='field-label'>الموضوع:</div>
                <div class='field-value'>{$subject_label}</div>
            </div>
            <div class='message-box'>
                <div class='field-label'>الرسالة:</div>
                <div class='field-value'>" . nl2br(htmlspecialchars($message)) . "</div>
            </div>";

if ($is_trainer_request && !empty($uploaded_files)) {
    $email_body .= "
            <div class='docs-section'>
                <div class='docs-title'>المستندات المرفقة:</div>
                <ul>
                    <li><strong>الهوية:</strong> {$uploaded_files['identity']}</li>
                    <li><strong>شهادة الخبرة:</strong> {$uploaded_files['experience_certificate']}</li>
                    <li><strong>رخصة المهنة:</strong> {$uploaded_files['professional_license']}</li>
                </ul>
                <p><small>المستندات محفوظة في مجلد: uploads/documents/</small></p>
            </div>";
}

$email_body .= "
        </div>
        <div class='footer'>
            <p>تم الإرسال من نموذج التواصل في موقع VitaFit</p>
            <p>" . date('Y-m-d H:i:s') . "</p>
        </div>
    </div>
</body>
</html>
";

// Email headers
$headers = [
    'MIME-Version: 1.0',
    'Content-type: text/html; charset=UTF-8',
    'From: VitaFit <noreply@vitafit.online>',
    'Reply-To: ' . $email,
    'X-Mailer: PHP/' . phpversion()
];

// Send email
$mail_sent = @mail($admin_email, $email_subject, $email_body, implode("\r\n", $headers));

// Save to database/file as backup
$log_file = __DIR__ . '/uploads/contact_log.json';
$log_data = [
    'timestamp' => date('Y-m-d H:i:s'),
    'name' => $name,
    'email' => $email,
    'phone' => $phone,
    'subject' => $subject,
    'message' => $message,
    'documents' => $uploaded_files,
    'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown'
];

$existing_log = [];
if (file_exists($log_file)) {
    $existing_log = json_decode(file_get_contents($log_file), true) ?: [];
}
$existing_log[] = $log_data;
file_put_contents($log_file, json_encode($existing_log, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));

// Response
if ($mail_sent) {
    echo json_encode([
        'success' => true,
        'message' => $is_trainer_request
            ? 'تم إرسال طلبك بنجاح! سنراجع مستنداتك ونتواصل معك قريباً'
            : 'تم إرسال رسالتك بنجاح! سنرد عليك قريباً'
    ]);
} else {
    // Even if mail fails, data is saved
    echo json_encode([
        'success' => true,
        'message' => 'تم استلام رسالتك بنجاح! سنتواصل معك قريباً'
    ]);
}
