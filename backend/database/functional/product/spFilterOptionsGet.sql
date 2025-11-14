/**
 * @summary
 * Retrieves all available filter options (categories, flavors, sizes, bakers)
 * for a given account to populate the product catalog filter UI.
 *
 * @procedure spFilterOptionsGet
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/product/filters
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: The account identifier to fetch filter options for.
 *
 * @output {Categories, n, n}
 * @column {INT} idCategory
 * @column {NVARCHAR(100)} name
 * @column {INT} idParent
 *
 * @output {Flavors, n, n}
 * @column {INT} idFlavor
 * @column {NVARCHAR(100)} name
 *
 * @output {Sizes, n, n}
 * @column {INT} idSize
 * @column {NVARCHAR(100)} name
 * @column {NVARCHAR(200)} description
 *
 * @output {Bakers, n, n}
 * @column {INT} idBaker
 * @column {NVARCHAR(100)} name
 */
CREATE OR ALTER PROCEDURE [functional].[spFilterOptionsGet]
  @idAccount INT
AS
BEGIN
  SET NOCOUNT ON;

  -- Categories
  SELECT
    [cat].[idCategory],
    [cat].[name],
    [cat].[idParent]
  FROM [functional].[category] [cat]
  WHERE [cat].[idAccount] = @idAccount
    AND [cat].[deleted] = 0
  ORDER BY [cat].[name];

  -- Flavors
  SELECT
    [flv].[idFlavor],
    [flv].[name]
  FROM [functional].[flavor] [flv]
  WHERE [flv].[idAccount] = @idAccount
    AND [flv].[deleted] = 0
  ORDER BY [flv].[name];

  -- Sizes
  SELECT
    [siz].[idSize],
    [siz].[name],
    [siz].[description]
  FROM [functional].[size] [siz]
  WHERE [siz].[idAccount] = @idAccount
    AND [siz].[deleted] = 0
  ORDER BY [siz].[name];

  -- Bakers
  SELECT
    [bkr].[idBaker],
    [bkr].[name]
  FROM [functional].[baker] [bkr]
  WHERE [bkr].[idAccount] = @idAccount
    AND [bkr].[deleted] = 0
  ORDER BY [bkr].[name];

END;
GO
