import { Router } from 'express';

const router = Router();

// This is a placeholder for internal (authenticated) routes.
// All feature routes that require a user to be logged in will be added here.

// Example for a future 'products' feature:
// import productRoutes from './features/productRoutes';
// router.use('/products', productRoutes);

router.get('/', (req, res) => {
  res.json({ message: 'Internal API endpoint' });
});

export default router;
