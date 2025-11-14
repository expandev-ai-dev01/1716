import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { successResponse, errorResponse } from '@/utils/apiResponse';
import * as productRules from '@/services/product/productRules';
import { ProductListParams } from '@/services/product/productTypes';

const listQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  pageSize: z.coerce.number().int().min(1).max(100).default(12),
  orderBy: z
    .enum(['relevance', 'price_asc', 'price_desc', 'best_sellers', 'top_rated', 'newest'])
    .default('relevance'),
  searchTerm: z.string().max(100).optional(),
  categoryIds: z.string().optional(),
  flavorIds: z.string().optional(),
  sizeIds: z.string().optional(),
  bakerIds: z.string().optional(),
  priceRange: z
    .string()
    .regex(/^\d+-\d+$/, { message: 'Price range must be in format min-max' })
    .optional(),
  availability: z.enum(['available', 'unavailable', 'all']).default('available'),
});

const idParamSchema = z.object({
  id: z.coerce.number().int().positive(),
});

export async function listProducts(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const queryParams = listQuerySchema.parse(req.query);

    const [minPrice, maxPrice] = queryParams.priceRange
      ? queryParams.priceRange.split('-').map(Number)
      : [undefined, undefined];

    const params: ProductListParams = {
      // Assuming idAccount comes from auth middleware in a real scenario
      idAccount: 1, // Placeholder
      pageNumber: queryParams.page,
      pageSize: queryParams.pageSize,
      orderBy: queryParams.orderBy,
      searchTerm: queryParams.searchTerm,
      categoryIds: queryParams.categoryIds,
      flavorIds: queryParams.flavorIds,
      sizeIds: queryParams.sizeIds,
      bakerIds: queryParams.bakerIds,
      minPrice,
      maxPrice,
      availability: queryParams.availability,
    };

    const result = await productRules.productList(params);

    res.status(200).json(successResponse(result));
  } catch (error) {
    next(error);
  }
}

export async function getProductDetails(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { id } = idParamSchema.parse(req.params);
    const idAccount = 1; // Placeholder for auth

    const product = await productRules.productGet({ idAccount, idProduct: id });

    if (!product) {
      res.status(404).json(errorResponse('Product not found'));
      return;
    }

    res.status(200).json(successResponse(product));
  } catch (error) {
    next(error);
  }
}

export async function getRelatedProducts(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { id } = idParamSchema.parse(req.params);
    const idAccount = 1; // Placeholder for auth

    const relatedProducts = await productRules.productRelatedList({ idAccount, idProduct: id });

    res.status(200).json(successResponse(relatedProducts));
  } catch (error) {
    next(error);
  }
}

export async function getFilterOptions(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const idAccount = 1; // Placeholder for auth
    const options = await productRules.filterOptionsGet({ idAccount });
    res.status(200).json(successResponse(options));
  } catch (error) {
    next(error);
  }
}
