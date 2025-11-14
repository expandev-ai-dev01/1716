/**
 * @schema security
 * Contains tables for managing authentication, authorization, users, and roles.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'security')
BEGIN
    EXEC('CREATE SCHEMA security');
END
GO

-- Add security-related tables (e.g., users, roles, permissions) below as needed.
