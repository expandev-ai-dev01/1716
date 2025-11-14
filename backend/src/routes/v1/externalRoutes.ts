import { Router } from 'express';
import * as healthController from '@/api/v1/external/public/health/controller';

const router = Router();

// This is a sample public route.
// All public routes (e.g., login, register, password recovery) should be defined here.

// Health check route is often public
router.get('/health', healthController.getHandler);

// Add other external routes below
// router.use('/auth', authRoutes);

export default router;
