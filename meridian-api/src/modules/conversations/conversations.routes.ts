import { Router } from 'express'

import { authenticate } from '../../middleware/authenticate'

import * as conversationsController from './conversations.controller'

const router = Router()

router.get(
  '/',
  authenticate,
  conversationsController.getConversations
)

router.post(
  '/',
  authenticate,
  conversationsController.getOrCreateConversation
)

router.patch(
  '/:id/last-message',
  authenticate,
  conversationsController.updateLastMessage
)
router.get('/messageable-users', authenticate, conversationsController.getMessageableUsers)
export default router