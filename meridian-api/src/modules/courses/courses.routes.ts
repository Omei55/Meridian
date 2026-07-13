import { Router } from 'express'

import { authenticate } from '../../middleware/authenticate'
import { requireRole } from '../../middleware/requireRole'

import * as coursesController from './courses.controller'

const router = Router()

router.get('/', authenticate, coursesController.getCourses)
router.post('/', authenticate, requireRole('professor'), coursesController.createCourse)

// Search MUST be before /:id — otherwise Express matches 'search' as an id
router.get('/search', authenticate, coursesController.searchByCode)

// /:id routes after
router.get('/:id', authenticate, coursesController.getCourse)
router.post('/:id/enroll', authenticate, requireRole('student'), coursesController.enrollInCourse)
router.delete('/:id/enroll', authenticate, requireRole('student'), coursesController.unenrollFromCourse)
// Search by course code — must be before /:id
// otherwise Express matches 'search' as an id
router.get('/search', authenticate, coursesController.searchByCode)


export default router