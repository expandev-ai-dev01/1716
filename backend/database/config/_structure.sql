/**
 * @schema config
 * Contains system-wide configuration, settings, and utility tables.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'config')
BEGIN
    EXEC('CREATE SCHEMA config');
END
GO

-- Add configuration tables below as needed.
-- Example:
/*
CREATE TABLE [config].[systemSettings] (
  [idSetting] INTEGER IDENTITY(1,1) NOT NULL,
  [key] NVARCHAR(100) NOT NULL,
  [value] NVARCHAR(MAX) NOT NULL,
  [description] NVARCHAR(500) NULL
);
*/
