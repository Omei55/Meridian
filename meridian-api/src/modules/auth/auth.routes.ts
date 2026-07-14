import { Router } from 'express'
import * as authController from './auth.controller'

const router = Router()

router.post('/register', authController.register)
router.post('/login', authController.login)

// POST /auth/refresh
// Body: { refreshToken }
// Returns a new access token when the old one expires
router.post('/refresh', authController.refresh)

// POST /auth/logout
// Body: { refreshToken }
// Invalidates the refresh token
router.post('/logout', authController.logout)

export default router