/**
 * @schema functional
 * Contains tables related to the core business logic and entities of the application.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'functional')
BEGIN
    EXEC('CREATE SCHEMA functional');
END
GO

-- #region Entity Tables

/**
 * @table baker Manages bakers (confectioners) who create and sell products.
 * @multitenancy true
 * @softDelete true
 * @alias bkr
 */
CREATE TABLE [functional].[baker] (
  [idBaker] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [photoUrl] NVARCHAR(2048) NULL,
  [dateCreated] DATETIME2 NOT NULL,
  [dateModified] DATETIME2 NOT NULL,
  [deleted] BIT NOT NULL
);
GO

/**
 * @table category Organizes products into a hierarchical structure.
 * @multitenancy true
 * @softDelete true
 * @alias cat
 */
CREATE TABLE [functional].[category] (
  [idCategory] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idParent] INTEGER NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(500) NULL,
  [node] HIERARCHYID NULL,
  [dateCreated] DATETIME2 NOT NULL,
  [dateModified] DATETIME2 NOT NULL,
  [deleted] BIT NOT NULL
);
GO

/**
 * @table product Core table for all cake products offered.
 * @multitenancy true
 * @softDelete true
 * @alias prd
 */
CREATE TABLE [functional].[product] (
  [idProduct] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idBaker] INTEGER NOT NULL,
  [idCategory] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(1000) NOT NULL,
  [basePrice] NUMERIC(18, 6) NOT NULL,
  [preparationTime] NVARCHAR(50) NOT NULL, -- e.g., '2 horas', '1 dia'
  [nutritionalInfoJson] NVARCHAR(MAX) NULL,
  [active] BIT NOT NULL,
  [stockQuantity] INTEGER NOT NULL,
  [dateCreated] DATETIME2 NOT NULL,
  [dateModified] DATETIME2 NOT NULL,
  [deleted] BIT NOT NULL
);
GO

/**
 * @table productImage Stores multiple images for each product.
 * @multitenancy false
 * @softDelete false
 * @alias prdImg
 */
CREATE TABLE [functional].[productImage] (
  [idProductImage] INTEGER IDENTITY(1, 1) NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [imageUrl] NVARCHAR(2048) NOT NULL,
  [sortOrder] INTEGER NOT NULL
);
GO

/**
 * @table flavor Master table for available flavors.
 * @multitenancy true
 * @softDelete true
 * @alias flv
 */
CREATE TABLE [functional].[flavor] (
  [idFlavor] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [deleted] BIT NOT NULL
);
GO

/**
 * @table size Master table for available product sizes.
 * @multitenancy true
 * @softDelete true
 * @alias siz
 */
CREATE TABLE [functional].[size] (
  [idSize] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL, -- e.g., 'Pequeno', 'Médio'
  [description] NVARCHAR(200) NOT NULL, -- e.g., '15cm - serve 10 pessoas'
  [deleted] BIT NOT NULL
);
GO

/**
 * @table ingredient Master table for ingredients.
 * @multitenancy true
 * @softDelete true
 * @alias ing
 */
CREATE TABLE [functional].[ingredient] (
  [idIngredient] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [deleted] BIT NOT NULL
);
GO

/**
 * @table productReview Stores customer reviews for products.
 * @multitenancy false
 * @softDelete false
 * @alias prdRev
 */
CREATE TABLE [functional].[productReview] (
  [idProductReview] INTEGER IDENTITY(1, 1) NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [customerName] NVARCHAR(100) NOT NULL, -- Simplified until a customer entity exists
  [rating] TINYINT NOT NULL, -- 1 to 5
  [comment] NVARCHAR(1000) NULL,
  [dateCreated] DATETIME2 NOT NULL
);
GO

-- #endregion

-- #region Relationship Tables

/**
 * @table productFlavor Links products to available flavors.
 * @multitenancy false
 * @softDelete false
 * @alias prdFlv
 */
CREATE TABLE [functional].[productFlavor] (
  [idProduct] INTEGER NOT NULL,
  [idFlavor] INTEGER NOT NULL
);
GO

/**
 * @table productSize Links products to available sizes with price adjustments.
 * @multitenancy false
 * @softDelete false
 * @alias prdSiz
 */
CREATE TABLE [functional].[productSize] (
  [idProduct] INTEGER NOT NULL,
  [idSize] INTEGER NOT NULL,
  [priceModifier] NUMERIC(18, 6) NOT NULL -- Added to product base price
);
GO

/**
 * @table productIngredient Links products to their ingredients.
 * @multitenancy false
 * @softDelete false
 * @alias prdIng
 */
CREATE TABLE [functional].[productIngredient] (
  [idProduct] INTEGER NOT NULL,
  [idIngredient] INTEGER NOT NULL
);
GO

-- #endregion

-- #region Constraints and Indexes

-- Baker Table
ALTER TABLE [functional].[baker] ADD CONSTRAINT [pkBaker] PRIMARY KEY CLUSTERED ([idBaker]);
ALTER TABLE [functional].[baker] ADD CONSTRAINT [dfBaker_dateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
ALTER TABLE [functional].[baker] ADD CONSTRAINT [dfBaker_dateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
ALTER TABLE [functional].[baker] ADD CONSTRAINT [dfBaker_deleted] DEFAULT (0) FOR [deleted];
ALTER TABLE [functional].[baker] ADD CONSTRAINT [fkBaker_Account] FOREIGN KEY ([idAccount]) REFERENCES [subscription].[account]([idAccount]);
CREATE UNIQUE NONCLUSTERED INDEX [uqBaker_Account_Name] ON [functional].[baker]([idAccount], [name]) WHERE [deleted] = 0;

-- Category Table
ALTER TABLE [functional].[category] ADD CONSTRAINT [pkCategory] PRIMARY KEY CLUSTERED ([idCategory]);
ALTER TABLE [functional].[category] ADD CONSTRAINT [dfCategory_dateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
ALTER TABLE [functional].[category] ADD CONSTRAINT [dfCategory_dateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
ALTER TABLE [functional].[category] ADD CONSTRAINT [dfCategory_deleted] DEFAULT (0) FOR [deleted];
ALTER TABLE [functional].[category] ADD CONSTRAINT [fkCategory_Account] FOREIGN KEY ([idAccount]) REFERENCES [subscription].[account]([idAccount]);
ALTER TABLE [functional].[category] ADD CONSTRAINT [fkCategory_ParentCategory] FOREIGN KEY ([idParent]) REFERENCES [functional].[category]([idCategory]);
CREATE UNIQUE NONCLUSTERED INDEX [uqCategory_Account_Name] ON [functional].[category]([idAccount], [name]) WHERE [deleted] = 0;
CREATE NONCLUSTERED INDEX [ixCategory_Account_Parent] ON [functional].[category]([idAccount], [idParent]) WHERE [deleted] = 0;

-- Product Table
ALTER TABLE [functional].[product] ADD CONSTRAINT [pkProduct] PRIMARY KEY CLUSTERED ([idProduct]);
ALTER TABLE [functional].[product] ADD CONSTRAINT [dfProduct_active] DEFAULT (1) FOR [active];
ALTER TABLE [functional].[product] ADD CONSTRAINT [dfProduct_stockQuantity] DEFAULT (0) FOR [stockQuantity];
ALTER TABLE [functional].[product] ADD CONSTRAINT [dfProduct_dateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
ALTER TABLE [functional].[product] ADD CONSTRAINT [dfProduct_dateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
ALTER TABLE [functional].[product] ADD CONSTRAINT [dfProduct_deleted] DEFAULT (0) FOR [deleted];
ALTER TABLE [functional].[product] ADD CONSTRAINT [fkProduct_Account] FOREIGN KEY ([idAccount]) REFERENCES [subscription].[account]([idAccount]);
ALTER TABLE [functional].[product] ADD CONSTRAINT [fkProduct_Baker] FOREIGN KEY ([idBaker]) REFERENCES [functional].[baker]([idBaker]);
ALTER TABLE [functional].[product] ADD CONSTRAINT [fkProduct_Category] FOREIGN KEY ([idCategory]) REFERENCES [functional].[category]([idCategory]);
CREATE NONCLUSTERED INDEX [ixProduct_Account] ON [functional].[product]([idAccount]) WHERE [deleted] = 0;
CREATE NONCLUSTERED INDEX [ixProduct_Account_Baker] ON [functional].[product]([idAccount], [idBaker]) WHERE [deleted] = 0;
CREATE NONCLUSTERED INDEX [ixProduct_Account_Category] ON [functional].[product]([idAccount], [idCategory]) WHERE [deleted] = 0;

-- ProductImage Table
ALTER TABLE [functional].[productImage] ADD CONSTRAINT [pkProductImage] PRIMARY KEY CLUSTERED ([idProductImage]);
ALTER TABLE [functional].[productImage] ADD CONSTRAINT [fkProductImage_Product] FOREIGN KEY ([idProduct]) REFERENCES [functional].[product]([idProduct]);
CREATE NONCLUSTERED INDEX [ixProductImage_Product] ON [functional].[productImage]([idProduct]);

-- Flavor Table
ALTER TABLE [functional].[flavor] ADD CONSTRAINT [pkFlavor] PRIMARY KEY CLUSTERED ([idFlavor]);
ALTER TABLE [functional].[flavor] ADD CONSTRAINT [dfFlavor_deleted] DEFAULT (0) FOR [deleted];
ALTER TABLE [functional].[flavor] ADD CONSTRAINT [fkFlavor_Account] FOREIGN KEY ([idAccount]) REFERENCES [subscription].[account]([idAccount]);
CREATE UNIQUE NONCLUSTERED INDEX [uqFlavor_Account_Name] ON [functional].[flavor]([idAccount], [name]) WHERE [deleted] = 0;

-- Size Table
ALTER TABLE [functional].[size] ADD CONSTRAINT [pkSize] PRIMARY KEY CLUSTERED ([idSize]);
ALTER TABLE [functional].[size] ADD CONSTRAINT [dfSize_deleted] DEFAULT (0) FOR [deleted];
ALTER TABLE [functional].[size] ADD CONSTRAINT [fkSize_Account] FOREIGN KEY ([idAccount]) REFERENCES [subscription].[account]([idAccount]);
CREATE UNIQUE NONCLUSTERED INDEX [uqSize_Account_Name] ON [functional].[size]([idAccount], [name]) WHERE [deleted] = 0;

-- Ingredient Table
ALTER TABLE [functional].[ingredient] ADD CONSTRAINT [pkIngredient] PRIMARY KEY CLUSTERED ([idIngredient]);
ALTER TABLE [functional].[ingredient] ADD CONSTRAINT [dfIngredient_deleted] DEFAULT (0) FOR [deleted];
ALTER TABLE [functional].[ingredient] ADD CONSTRAINT [fkIngredient_Account] FOREIGN KEY ([idAccount]) REFERENCES [subscription].[account]([idAccount]);
CREATE UNIQUE NONCLUSTERED INDEX [uqIngredient_Account_Name] ON [functional].[ingredient]([idAccount], [name]) WHERE [deleted] = 0;

-- ProductReview Table
ALTER TABLE [functional].[productReview] ADD CONSTRAINT [pkProductReview] PRIMARY KEY CLUSTERED ([idProductReview]);
ALTER TABLE [functional].[productReview] ADD CONSTRAINT [dfProductReview_dateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
ALTER TABLE [functional].[productReview] ADD CONSTRAINT [chkProductReview_Rating] CHECK ([rating] BETWEEN 1 AND 5);
ALTER TABLE [functional].[productReview] ADD CONSTRAINT [fkProductReview_Product] FOREIGN KEY ([idProduct]) REFERENCES [functional].[product]([idProduct]);
CREATE NONCLUSTERED INDEX [ixProductReview_Product] ON [functional].[productReview]([idProduct]);

-- ProductFlavor Table
ALTER TABLE [functional].[productFlavor] ADD CONSTRAINT [pkProductFlavor] PRIMARY KEY CLUSTERED ([idProduct], [idFlavor]);
ALTER TABLE [functional].[productFlavor] ADD CONSTRAINT [fkProductFlavor_Product] FOREIGN KEY ([idProduct]) REFERENCES [functional].[product]([idProduct]);
ALTER TABLE [functional].[productFlavor] ADD CONSTRAINT [fkProductFlavor_Flavor] FOREIGN KEY ([idFlavor]) REFERENCES [functional].[flavor]([idFlavor]);

-- ProductSize Table
ALTER TABLE [functional].[productSize] ADD CONSTRAINT [pkProductSize] PRIMARY KEY CLUSTERED ([idProduct], [idSize]);
ALTER TABLE [functional].[productSize] ADD CONSTRAINT [fkProductSize_Product] FOREIGN KEY ([idProduct]) REFERENCES [functional].[product]([idProduct]);
ALTER TABLE [functional].[productSize] ADD CONSTRAINT [fkProductSize_Size] FOREIGN KEY ([idSize]) REFERENCES [functional].[size]([idSize]);

-- ProductIngredient Table
ALTER TABLE [functional].[productIngredient] ADD CONSTRAINT [pkProductIngredient] PRIMARY KEY CLUSTERED ([idProduct], [idIngredient]);
ALTER TABLE [functional].[productIngredient] ADD CONSTRAINT [fkProductIngredient_Product] FOREIGN KEY ([idProduct]) REFERENCES [functional].[product]([idProduct]);
ALTER TABLE [functional].[productIngredient] ADD CONSTRAINT [fkProductIngredient_Ingredient] FOREIGN KEY ([idIngredient]) REFERENCES [functional].[ingredient]([idIngredient]);

-- #endregion
