import { Request, Response, NextFunction } from 'express';
import { errorResponse } from '@/utils/apiResponse';

export function notFoundMiddleware(req: Request, res: Response, next: NextFunction): void {
  res.status(404).json(errorResponse(`Not Found - ${req.method} ${req.originalUrl}`));
}
