/**
 * @schema subscription
 * Contains tables for managing accounts, subscriptions, and multi-tenancy.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'subscription')
BEGIN
    EXEC('CREATE SCHEMA subscription');
END
GO

/**
 * @table account Manages tenant accounts for data isolation.
 * @multitenancy false (This table defines the tenants)
 * @softDelete true
 * @alias acc
 */
CREATE TABLE [subscription].[account] (
    [idAccount] INTEGER IDENTITY(1,1) NOT NULL,
    [name] NVARCHAR(100) NOT NULL,
    [dateCreated] DATETIME2 NOT NULL,
    [dateModified] DATETIME2 NOT NULL,
    [deleted] BIT NOT NULL
);
GO

/**
 * @primaryKey pkAccount
 * @keyType Object
 */
ALTER TABLE [subscription].[account]
ADD CONSTRAINT [pkAccount] PRIMARY KEY CLUSTERED ([idAccount]);
GO

/**
 * @default dfAccount_dateCreated
 */
ALTER TABLE [subscription].[account]
ADD CONSTRAINT [dfAccount_dateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
GO

/**
 * @default dfAccount_dateModified
 */
ALTER TABLE [subscription].[account]
ADD CONSTRAINT [dfAccount_dateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
GO

/**
 * @default dfAccount_deleted
 */
ALTER TABLE [subscription].[account]
ADD CONSTRAINT [dfAccount_deleted] DEFAULT (0) FOR [deleted];
GO

/**
 * @index uqAccount_Name
 * @type Search
 * @unique true
 * @filter Ensures account names are unique among active accounts.
 */
CREATE UNIQUE NONCLUSTERED INDEX [uqAccount_Name]
ON [subscription].[account]([name])
WHERE [deleted] = 0;
GO
