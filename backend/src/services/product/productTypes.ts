export interface ProductSummary {
  idProduct: number;
  name: string;
  basePrice: number;
  imageUrl: string | null;
  averageRating: number | null;
  reviewCount: number;
  bakerName: string;
  stockQuantity: number;
}

export interface ProductListResponse {
  data: ProductSummary[];
  metadata: {
    page: number;
    pageSize: number;
    total: number;
    totalPages: number;
  };
}

export interface ProductListParams {
  idAccount: number;
  pageNumber: number;
  pageSize: number;
  orderBy: string;
  searchTerm?: string;
  categoryIds?: string;
  flavorIds?: string;
  sizeIds?: string;
  bakerIds?: string;
  minPrice?: number;
  maxPrice?: number;
  availability: string;
}

export interface ProductGetParams {
  idAccount: number;
  idProduct: number;
}

export interface ProductRelatedListParams extends ProductGetParams {}

export interface ProductImage {
  imageUrl: string;
  sortOrder: number;
}

export interface ProductFlavor {
  idFlavor: number;
  name: string;
}

export interface ProductSize {
  idSize: number;
  name: string;
  description: string;
  priceModifier: number;
}

export interface ProductReview {
  customerName: string;
  rating: number;
  comment: string | null;
  dateCreated: Date;
}

export interface ProductDetails {
  idProduct: number;
  name: string;
  description: string;
  basePrice: number;
  preparationTime: string;
  nutritionalInfo: any | null;
  stockQuantity: number;
  active: boolean;
  idCategory: number;
  categoryName: string;
  idBaker: number;
  bakerName: string;
  bakerPhotoUrl: string | null;
  averageRating: number | null;
  reviewCount: number;
  images: ProductImage[];
  availableFlavors: ProductFlavor[];
  availableSizes: ProductSize[];
  ingredients: string[];
  reviews: ProductReview[];
}

export interface FilterOptions {
  categories: { idCategory: number; name: string; idParent: number | null }[];
  flavors: { idFlavor: number; name: string }[];
  sizes: { idSize: number; name: string; description: string }[];
  bakers: { idBaker: number; name: string }[];
}
