import { Router } from 'express';
import * as productController from '@/api/v1/internal/product/controller';

const router = Router();

/**
 * @api {get} /api/v1/internal/product List Products
 * @apiName ListProducts
 * @apiGroup Product
 * @apiVersion 1.0.0
 * @apiDescription Retrieves a list of products with filtering, sorting, and pagination.
 */
router.get('/', productController.listProducts);

/**
 * @api {get} /api/v1/internal/product/filters Get Filter Options
 * @apiName GetFilterOptions
 * @apiGroup Product
 * @apiVersion 1.0.0
 * @apiDescription Retrieves all available options for filtering the product catalog.
 */
router.get('/filters', productController.getFilterOptions);

/**
 * @api {get} /api/v1/internal/product/:id Get Product Details
 * @apiName GetProductDetails
 * @apiGroup Product
 * @apiVersion 1.0.0
 * @apiDescription Retrieves detailed information for a single product.
 */
router.get('/:id', productController.getProductDetails);

/**
 * @api {get} /api/v1/internal/product/:id/related Get Related Products
 * @apiName GetRelatedProducts
 * @apiGroup Product
 * @apiVersion 1.0.0
 * @apiDescription Retrieves a list of products related to the specified product.
 */
router.get('/:id/related', productController.getRelatedProducts);

export default router;
