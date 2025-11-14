import { Request, Response, NextFunction } from 'express';
import { successResponse } from '@/utils/apiResponse';
import { getDbPool } from '@/instances/database';

/**
 * @summary
 * Checks the health of the API and its database connection.
 *
 * @api {get} /api/v1/external/health Health Check
 * @apiName GetHealth
 * @apiGroup Health
 * @apiVersion 1.0.0
 *
 * @apiSuccess {Boolean} success Indicates if the request was successful.
 * @apiSuccess {Object} data Contains the health status.
 * @apiSuccess {String} data.status API status.
 * @apiSuccess {String} data.dbStatus Database connection status.
 * @apiSuccess {String} data.timestamp Current server timestamp.
 */
export async function getHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const pool = await getDbPool();
    await pool.query('SELECT 1');
    const healthStatus = {
      status: 'ok',
      dbStatus: 'connected',
      timestamp: new Date().toISOString(),
    };
    res.status(200).json(successResponse(healthStatus));
  } catch (error) {
    const healthStatus = {
      status: 'error',
      dbStatus: 'disconnected',
      timestamp: new Date().toISOString(),
      error: error instanceof Error ? error.message : 'Unknown DB error',
    };
    // Even on error, we return 200 to provide status, but could be 503 Service Unavailable
    res.status(503).json(successResponse(healthStatus));
  }
}
