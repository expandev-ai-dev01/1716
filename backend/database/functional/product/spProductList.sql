/**
 * @summary
 * Retrieves a paginated, filtered, and sorted list of products for the catalog.
 *
 * @procedure spProductList
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/product
 *
 * @parameters
 * @param {INT} idAccount - Required. Account identifier.
 * @param {INT} pageNumber - Required. The page number to retrieve.
 * @param {INT} pageSize - Required. The number of items per page.
 * @param {NVARCHAR(50)} orderBy - Required. Sort order criteria.
 * @param {NVARCHAR(100)} searchTerm - Optional. Text to search in name/description.
 * @param {NVARCHAR(MAX)} categoryIds - Optional. Comma-separated string of category IDs.
 * @param {NVARCHAR(MAX)} flavorIds - Optional. Comma-separated string of flavor IDs.
 * @param {NVARCHAR(MAX)} sizeIds - Optional. Comma-separated string of size IDs.
 * @param {NVARCHAR(MAX)} bakerIds - Optional. Comma-separated string of baker IDs.
 * @param {NUMERIC(18,6)} minPrice - Optional. Minimum price filter.
 * @param {NUMERIC(18,6)} maxPrice - Optional. Maximum price filter.
 * @param {NVARCHAR(20)} availability - Optional. 'available', 'unavailable', or 'all'.
 *
 * @output {ProductList, n, n}
 * @output {TotalCount, 1, 1}
 */
CREATE OR ALTER PROCEDURE [functional].[spProductList]
    @idAccount INT,
    @pageNumber INT = 1,
    @pageSize INT = 12,
    @orderBy NVARCHAR(50) = 'relevance',
    @searchTerm NVARCHAR(100) = NULL,
    @categoryIds NVARCHAR(MAX) = NULL,
    @flavorIds NVARCHAR(MAX) = NULL,
    @sizeIds NVARCHAR(MAX) = NULL,
    @bakerIds NVARCHAR(MAX) = NULL,
    @minPrice NUMERIC(18, 6) = NULL,
    @maxPrice NUMERIC(18, 6) = NULL,
    @availability NVARCHAR(20) = 'available'
AS
BEGIN
    SET NOCOUNT ON;

    WITH [ProductBase] AS (
        SELECT
            [prd].[idProduct],
            [prd].[name],
            [prd].[basePrice],
            [prd].[stockQuantity],
            [prd].[dateCreated],
            [bkr].[idBaker],
            [bkr].[name] AS [bakerName],
            (SELECT TOP 1 [imageUrl] FROM [functional].[productImage] WHERE [idProduct] = [prd].[idProduct] ORDER BY [sortOrder]) AS [imageUrl],
            (SELECT AVG(CAST([rating] AS DECIMAL(3,2))) FROM [functional].[productReview] WHERE [idProduct] = [prd].[idProduct]) AS [averageRating],
            (SELECT COUNT(*) FROM [functional].[productReview] WHERE [idProduct] = [prd].[idProduct]) AS [reviewCount]
        FROM [functional].[product] [prd]
        JOIN [functional].[baker] [bkr] ON [bkr].[idBaker] = [prd].[idBaker]
        WHERE [prd].[idAccount] = @idAccount
          AND [prd].[deleted] = 0
          AND [prd].[active] = 1
    ),
    [FilteredProducts] AS (
        SELECT *
        FROM [ProductBase] [pb]
        WHERE
            -- Availability Filter
            ( (@availability = 'available' AND [pb].[stockQuantity] > 0) OR
              (@availability = 'unavailable' AND [pb].[stockQuantity] <= 0) OR
              (@availability = 'all') )
            -- Search Term Filter
            AND (@searchTerm IS NULL OR [pb].[name] LIKE '%' + @searchTerm + '%')
            -- Price Filter
            AND (@minPrice IS NULL OR [pb].[basePrice] >= @minPrice)
            AND (@maxPrice IS NULL OR [pb].[basePrice] <= @maxPrice)
            -- Baker Filter
            AND (@bakerIds IS NULL OR [pb].[idBaker] IN (SELECT value FROM STRING_SPLIT(@bakerIds, ',')))
            -- Category Filter
            AND (@categoryIds IS NULL OR EXISTS (
                SELECT 1 FROM [functional].[product] p WHERE p.idProduct = pb.idProduct AND p.idCategory IN (SELECT value FROM STRING_SPLIT(@categoryIds, ','))
            ))
            -- Flavor Filter
            AND (@flavorIds IS NULL OR EXISTS (
                SELECT 1 FROM [functional].[productFlavor] pf WHERE pf.idProduct = pb.idProduct AND pf.idFlavor IN (SELECT value FROM STRING_SPLIT(@flavorIds, ','))
            ))
            -- Size Filter
            AND (@sizeIds IS NULL OR EXISTS (
                SELECT 1 FROM [functional].[productSize] ps WHERE ps.idProduct = pb.idProduct AND ps.idSize IN (SELECT value FROM STRING_SPLIT(@sizeIds, ','))
            ))
    )
    -- Final Result Set
    SELECT
        [fp].*,
        (SELECT COUNT(*) FROM [FilteredProducts]) AS [totalCount]
    FROM [FilteredProducts] [fp]
    ORDER BY
        CASE WHEN @orderBy = 'relevance' THEN [fp].[averageRating] END DESC,
        CASE WHEN @orderBy = 'price_asc' THEN [fp].[basePrice] END ASC,
        CASE WHEN @orderBy = 'price_desc' THEN [fp].[basePrice] END DESC,
        CASE WHEN @orderBy = 'top_rated' THEN [fp].[averageRating] END DESC,
        CASE WHEN @orderBy = 'newest' THEN [fp].[dateCreated] END DESC,
        -- best_sellers would require sales data, using reviewCount as a proxy
        CASE WHEN @orderBy = 'best_sellers' THEN [fp].[reviewCount] END DESC
    OFFSET (@pageNumber - 1) * @pageSize ROWS
    FETCH NEXT @pageSize ROWS ONLY;

END;
GO
