import { Router } from 'express'

import { authenticate } from '../../middleware/authenticate'
import { requireRole } from '../../middleware/requireRole'

import * as assignmentsController from './assignments.controller'

const router = Router({ mergeParams: true })

router.get('/', authenticate, assignmentsController.getAssignments)

router.post(
  '/',
  authenticate,
  requireRole('professor'),
  assignmentsController.createAssignment
)

router.get('/:id', authenticate, assignmentsController.getAssignment)

router.patch(
  '/:id',
  authenticate,
  requireRole('professor'),
  assignmentsController.updateAssignment
)

router.delete(
  '/:id',
  authenticate,
  requireRole('professor'),
  assignmentsController.deleteAssignment
)

export default router