import { Router } from 'express'

import { authenticate } from '../../middleware/authenticate'
import { requireRole } from '../../middleware/requireRole'

import * as submissionsController from './submissions.controller'

const router = Router({ mergeParams: true })

router.get(
  '/',
  authenticate,
  requireRole('professor'),
  submissionsController.getSubmissions
)

router.get(
  '/me',
  authenticate,
  requireRole('student'),
  submissionsController.getMySubmission
)

router.post(
  '/',
  authenticate,
  requireRole('student'),
  submissionsController.createSubmission
)

router.patch(
  '/:id',
  authenticate,
  requireRole('professor'),
  submissionsController.updateSubmission
)

export default router