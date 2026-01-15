<?php
/**
 * API Proxy - Forwards requests to Node.js backend
 */

// Enable CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, PATCH, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Max-Age: 86400');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Node.js server configuration
$nodeHost = '127.0.0.1';
$nodePort = 5000;

// Get the request path
$requestUri = $_SERVER['REQUEST_URI'];
$path = parse_url($requestUri, PHP_URL_PATH);

// Remove /api.php from path if present
$path = preg_replace('#^/api\.php#', '', $path);

// Build the target URL
$targetUrl = "http://{$nodeHost}:{$nodePort}{$path}";

// Add query string if present
if (!empty($_SERVER['QUERY_STRING'])) {
    $targetUrl .= '?' . $_SERVER['QUERY_STRING'];
}

// Initialize cURL
$ch = curl_init();

// Set cURL options
curl_setopt($ch, CURLOPT_URL, $targetUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 30);
curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 10);

// Forward the request method
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $_SERVER['REQUEST_METHOD']);

// Forward headers
$headers = [];
foreach (getallheaders() as $key => $value) {
    // Skip host header
    if (strtolower($key) === 'host') continue;
    $headers[] = "{$key}: {$value}";
}
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

// Forward request body for POST/PUT/PATCH
if (in_array($_SERVER['REQUEST_METHOD'], ['POST', 'PUT', 'PATCH'])) {
    $body = file_get_contents('php://input');
    curl_setopt($ch, CURLOPT_POSTFIELDS, $body);
}

// Include response headers
curl_setopt($ch, CURLOPT_HEADER, true);

// Execute request
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$headerSize = curl_getinfo($ch, CURLINFO_HEADER_SIZE);

// Check for errors
if (curl_errno($ch)) {
    http_response_code(502);
    header('Content-Type: application/json');
    echo json_encode([
        'success' => false,
        'message' => 'Backend server unavailable',
        'error' => curl_error($ch)
    ]);
    curl_close($ch);
    exit();
}

curl_close($ch);

// Separate headers and body
$responseHeaders = substr($response, 0, $headerSize);
$responseBody = substr($response, $headerSize);

// Forward response headers
$headerLines = explode("\r\n", $responseHeaders);
foreach ($headerLines as $line) {
    // Skip status line and some headers
    if (empty($line) || preg_match('/^HTTP\//', $line)) continue;
    if (preg_match('/^(Transfer-Encoding|Connection):/i', $line)) continue;
    header($line);
}

// Set HTTP status code
http_response_code($httpCode);

// Output response body
echo $responseBody;
