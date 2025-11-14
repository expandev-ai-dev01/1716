import { Request, Response, NextFunction } from 'express';
import { AnyZodObject, ZodError } from 'zod';

/**
 * @summary
 * Middleware to validate request body, params, or query against a Zod schema.
 *
 * @param schema The Zod schema to validate against.
 * @returns An Express middleware function.
 */
export const validate =
  (schema: AnyZodObject) => async (req: Request, res: Response, next: NextFunction) => {
    try {
      await schema.parseAsync({
        body: req.body,
        query: req.query,
        params: req.params,
      });
      return next();
    } catch (error) {
      if (error instanceof ZodError) {
        return next(error); // Pass to the centralized error handler
      }
      return next(new Error('Internal validation error'));
    }
  };
