-- Migration: Add Apple Sign In fields to users table
-- Date: 2025-01-14
-- Description: Adds apple_id and refresh_token columns for Apple Sign In support

-- Add apple_id column (unique identifier from Apple)
ALTER TABLE users
ADD COLUMN IF NOT EXISTS apple_id VARCHAR(255) UNIQUE COMMENT 'Apple Sign In user identifier';

-- Add refresh_token column
ALTER TABLE users
ADD COLUMN IF NOT EXISTS refresh_token VARCHAR(500) COMMENT 'JWT refresh token for session management';

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_apple_id ON users(apple_id);

-- Verify the migration
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'users'
AND COLUMN_NAME IN ('apple_id', 'refresh_token');
