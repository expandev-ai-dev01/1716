import { Router } from 'express';
import productRoutes from './productRoutes';

const router = Router();

// This is a placeholder for internal (authenticated) routes.
// All feature routes that require a user to be logged in will be added here.

router.use('/product', productRoutes);

router.get('/', (req, res) => {
  res.json({ message: 'Internal API endpoint' });
});

export default router;
