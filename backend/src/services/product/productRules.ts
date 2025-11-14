import { dbRequest, ExpectedReturn } from '@/utils/database';
import { IRecordSet } from 'mssql';
import {
  ProductListParams,
  ProductListResponse,
  ProductDetails,
  ProductGetParams,
  FilterOptions,
  ProductRelatedListParams,
  ProductSummary,
} from './productTypes';

export async function productList(params: ProductListParams): Promise<ProductListResponse> {
  const result = (await dbRequest(
    '[functional].[spProductList]',
    params,
    ExpectedReturn.Multi
  )) as IRecordSet<any>[];

  const products = result[0];
  const totalCount = products.length > 0 ? products[0].totalCount : 0;

  // Remove totalCount from each product object
  const cleanedProducts = products.map(({ totalCount, ...rest }) => rest);

  return {
    data: cleanedProducts,
    metadata: {
      page: params.pageNumber,
      pageSize: params.pageSize,
      total: totalCount,
      totalPages: Math.ceil(totalCount / params.pageSize),
    },
  };
}

export async function productGet(params: ProductGetParams): Promise<ProductDetails | null> {
  const results = (await dbRequest('[functional].[spProductGet]', params, ExpectedReturn.Multi, [
    'product',
    'images',
    'flavors',
    'sizes',
    'ingredients',
    'reviews',
  ])) as {
    product: IRecordSet<any>;
    images: IRecordSet<any>;
    flavors: IRecordSet<any>;
    sizes: IRecordSet<any>;
    ingredients: IRecordSet<any>;
    reviews: IRecordSet<any>;
  };

  if (!results.product || results.product.length === 0) {
    return null;
  }

  const productDetail = results.product[0];

  return {
    ...productDetail,
    nutritionalInfo: productDetail.nutritionalInfoJson
      ? JSON.parse(productDetail.nutritionalInfoJson)
      : null,
    images: results.images || [],
    availableFlavors: results.flavors || [],
    availableSizes: results.sizes || [],
    ingredients: results.ingredients.map((i) => i.name) || [],
    reviews: results.reviews || [],
  };
}

export async function productRelatedList(
  params: ProductRelatedListParams
): Promise<ProductSummary[]> {
  const result = (await dbRequest(
    '[functional].[spProductRelatedList]',
    params,
    ExpectedReturn.Multi
  )) as IRecordSet<any>[];

  return result[0] || [];
}

export async function filterOptionsGet(params: { idAccount: number }): Promise<FilterOptions> {
  const results = (await dbRequest(
    '[functional].[spFilterOptionsGet]',
    params,
    ExpectedReturn.Multi,
    ['categories', 'flavors', 'sizes', 'bakers']
  )) as {
    categories: IRecordSet<any>;
    flavors: IRecordSet<any>;
    sizes: IRecordSet<any>;
    bakers: IRecordSet<any>;
  };

  return {
    categories: results.categories || [],
    flavors: results.flavors || [],
    sizes: results.sizes || [],
    bakers: results.bakers || [],
  };
}
