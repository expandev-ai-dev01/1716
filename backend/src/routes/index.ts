import { Router } from 'express';
import v1Routes from './v1';

const router = Router();

// Register V1 routes under /v1 prefix
router.use('/v1', v1Routes);

// Future versions can be added here
// import v2Routes from './v2';
// router.use('/v2', v2Routes);

export default router;
