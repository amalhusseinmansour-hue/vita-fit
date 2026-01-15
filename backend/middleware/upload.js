const multer = require('multer');
const path = require('path');

// Configure storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    let folder = 'uploads/';

    // Determine folder based on file field name or route
    if (file.fieldname === 'profileImage' || file.fieldname === 'avatar') {
      folder += 'profiles/';
    } else if (file.fieldname === 'trainerImage') {
      folder += 'trainers/';
    } else if (file.fieldname === 'workshopImage') {
      folder += 'workshops/';
    } else if (file.fieldname === 'progressPhoto') {
      folder += 'progress/';
    } else if (file.fieldname === 'image') {
      folder += 'products/';
    } else {
      folder += 'others/';
    }

    cb(null, folder);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// File filter - only images
const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|webp/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);

  if (mimetype && extname) {
    return cb(null, true);
  } else {
    cb(new Error('Only image files are allowed (jpeg, jpg, png, gif, webp)'));
  }
};

// Configure multer
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit
  },
  fileFilter: fileFilter
});

// Export multer instance for direct use (upload.single, upload.array, etc.)
module.exports = upload;

// Also export named helper functions
module.exports.uploadSingle = (fieldName) => upload.single(fieldName);
module.exports.uploadMultiple = (fieldName, maxCount = 5) => upload.array(fieldName, maxCount);
module.exports.uploadFields = (fields) => upload.fields(fields);

// Error handling middleware for multer
module.exports.handleUploadError = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        success: false,
        message: 'File size too large. Maximum size is 5MB'
      });
    }
    if (err.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({
        success: false,
        message: 'Too many files uploaded'
      });
    }
    return res.status(400).json({
      success: false,
      message: err.message
    });
  } else if (err) {
    return res.status(400).json({
      success: false,
      message: err.message
    });
  }
  next();
};
