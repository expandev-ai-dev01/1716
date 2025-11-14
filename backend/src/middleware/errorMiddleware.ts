import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { errorResponse } from '@/utils/apiResponse';
import { config } from '@/config';

interface AppError extends Error {
  statusCode?: number;
  isOperational?: boolean;
}

export function errorMiddleware(
  err: AppError,
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const statusCode = err.statusCode || 500;
  let message = err.isOperational ? err.message : 'An unexpected error occurred on the server.';

  // Handle Zod validation errors
  if (err instanceof ZodError) {
    res.status(400).json(errorResponse('Validation Error', { details: err.flatten().fieldErrors }));
    return;
  }

  // For developers: log the full error in development mode
  if (config.env === 'development') {
    console.error('ERROR 💥', err);
  }

  // Do not expose stack trace in production
  if (config.env === 'production' && !err.isOperational) {
    message = 'Internal Server Error';
  }

  res.status(statusCode).json(errorResponse(message));
}
