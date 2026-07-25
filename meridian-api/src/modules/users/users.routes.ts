import { Router } from 'express'
import { authenticate } from '../../middleware/authenticate'
import * as usersController from './users.controller'

const router = Router()

// POST /users/device-token
// Saves the FCM device token for the logged in user
router.post('/device-token', authenticate, usersController.saveDeviceToken)

export default router
