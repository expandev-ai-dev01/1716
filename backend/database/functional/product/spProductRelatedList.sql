/**
 * @summary
 * Retrieves a list of related products based on the category and baker of a given product.
 *
 * @procedure spProductRelatedList
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/product/{id}/related
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: The account identifier for data scoping.
 * @param {INT} idProduct
 *   - Required: Yes
 *   - Description: The identifier of the product to find related items for.
 *
 * @output {RelatedProducts, n, n}
 */
CREATE OR ALTER PROCEDURE [functional].[spProductRelatedList]
  @idAccount INT,
  @idProduct INT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @idCategory INT;
  DECLARE @idBaker INT;

  -- Get the category and baker of the source product
  SELECT
    @idCategory = [prd].[idCategory],
    @idBaker = [prd].[idBaker]
  FROM [functional].[product] [prd]
  WHERE [prd].[idProduct] = @idProduct
    AND [prd].[idAccount] = @idAccount;

  -- Find related products
  SELECT TOP 4
    [prd].[idProduct],
    [prd].[name],
    [prd].[basePrice],
    (SELECT TOP 1 [imageUrl] FROM [functional].[productImage] WHERE [idProduct] = [prd].[idProduct] ORDER BY [sortOrder]) AS [imageUrl],
    (SELECT AVG(CAST([rating] AS DECIMAL(3,2))) FROM [functional].[productReview] WHERE [idProduct] = [prd].[idProduct]) AS [averageRating]
  FROM [functional].[product] [prd]
  WHERE [prd].[idAccount] = @idAccount
    AND [prd].[idProduct] <> @idProduct -- Exclude the product itself
    AND [prd].[deleted] = 0
    AND [prd].[active] = 1
    AND [prd].[stockQuantity] > 0
    AND ([prd].[idCategory] = @idCategory OR [prd].[idBaker] = @idBaker)
  ORDER BY
    -- Prioritize products that match both category and baker
    CASE WHEN [prd].[idCategory] = @idCategory AND [prd].[idBaker] = @idBaker THEN 0 ELSE 1 END,
    -- Then by category
    CASE WHEN [prd].[idCategory] = @idCategory THEN 0 ELSE 1 END,
    -- Then by baker
    CASE WHEN [prd].[idBaker] = @idBaker THEN 0 ELSE 1 END,
    -- Finally, by creation date to get varied results
    [prd].[dateCreated] DESC;

END;
GO
