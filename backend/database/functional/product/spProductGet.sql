/**
 * @summary
 * Retrieves the complete details for a single product, including its images,
 * available options (flavors, sizes), ingredients, reviews, and baker information.
 *
 * @procedure spProductGet
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/product/{id}
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: The account identifier for data scoping.
 * @param {INT} idProduct
 *   - Required: Yes
 *   - Description: The identifier of the product to retrieve.
 *
 * @output {ProductDetails, 1, n}
 * @output {Images, n, n}
 * @output {Flavors, n, n}
 * @output {Sizes, n, n}
 * @output {Ingredients, n, n}
 * @output {Reviews, n, n}
 */
CREATE OR ALTER PROCEDURE [functional].[spProductGet]
  @idAccount INT,
  @idProduct INT
AS
BEGIN
  SET NOCOUNT ON;

  -- 1. Product Details
  SELECT
    [prd].[idProduct],
    [prd].[name],
    [prd].[description],
    [prd].[basePrice],
    [prd].[preparationTime],
    [prd].[nutritionalInfoJson],
    [prd].[stockQuantity],
    [prd].[active],
    [cat].[idCategory],
    [cat].[name] AS [categoryName],
    [bkr].[idBaker],
    [bkr].[name] AS [bakerName],
    [bkr].[photoUrl] AS [bakerPhotoUrl],
    (SELECT AVG(CAST([rating] AS DECIMAL(3,2))) FROM [functional].[productReview] WHERE [idProduct] = [prd].[idProduct]) AS [averageRating],
    (SELECT COUNT(*) FROM [functional].[productReview] WHERE [idProduct] = [prd].[idProduct]) AS [reviewCount]
  FROM [functional].[product] [prd]
  JOIN [functional].[baker] [bkr] ON ([bkr].[idAccount] = [prd].[idAccount] AND [bkr].[idBaker] = [prd].[idBaker])
  JOIN [functional].[category] [cat] ON ([cat].[idAccount] = [prd].[idAccount] AND [cat].[idCategory] = [prd].[idCategory])
  WHERE [prd].[idAccount] = @idAccount
    AND [prd].[idProduct] = @idProduct
    AND [prd].[deleted] = 0;

  -- 2. Images
  SELECT
    [prdImg].[imageUrl],
    [prdImg].[sortOrder]
  FROM [functional].[productImage] [prdImg]
  WHERE [prdImg].[idProduct] = @idProduct
  ORDER BY [prdImg].[sortOrder];

  -- 3. Flavors
  SELECT
    [flv].[idFlavor],
    [flv].[name]
  FROM [functional].[flavor] [flv]
  JOIN [functional].[productFlavor] [prdFlv] ON ([prdFlv].[idFlavor] = [flv].[idFlavor])
  WHERE [prdFlv].[idProduct] = @idProduct
    AND [flv].[deleted] = 0;

  -- 4. Sizes
  SELECT
    [siz].[idSize],
    [siz].[name],
    [siz].[description],
    [prdSiz].[priceModifier]
  FROM [functional].[size] [siz]
  JOIN [functional].[productSize] [prdSiz] ON ([prdSiz].[idSize] = [siz].[idSize])
  WHERE [prdSiz].[idProduct] = @idProduct
    AND [siz].[deleted] = 0;

  -- 5. Ingredients
  SELECT
    [ing].[name]
  FROM [functional].[ingredient] [ing]
  JOIN [functional].[productIngredient] [prdIng] ON ([prdIng].[idIngredient] = [ing].[idIngredient])
  WHERE [prdIng].[idProduct] = @idProduct
    AND [ing].[deleted] = 0;

  -- 6. Reviews
  SELECT
    [prdRev].[customerName],
    [prdRev].[rating],
    [prdRev].[comment],
    [prdRev].[dateCreated]
  FROM [functional].[productReview] [prdRev]
  WHERE [prdRev].[idProduct] = @idProduct
  ORDER BY [prdRev].[dateCreated] DESC;

END;
GO
