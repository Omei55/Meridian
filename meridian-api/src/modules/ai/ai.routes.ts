import { Router } from 'express'
import { authenticate } from '../../middleware/authenticate'
import { requireRole } from '../../middleware/requireRole'
import * as aiController from './ai.controller'

const router = Router()

router.post(
  '/ingest/:assignmentId',
  authenticate,
  requireRole('professor'),
  aiController.ingestPDF
)

router.post(
  '/chat',
  authenticate,
  requireRole('student'),
  aiController.chat
)

router.get(
  '/summarize/:assignmentId',
  authenticate,
  requireRole('student'),
  aiController.summarize
)

export default router