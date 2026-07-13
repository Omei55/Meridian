// Must be first — sets up fetch for all SDKs before they initialize
import { fetch } from 'undici'
;(globalThis as any).fetch = fetch
import express from 'express'
import cors from 'cors'
import dotenv from 'dotenv'


dotenv.config()

import './config/db'

import authRoutes from './modules/auth/auth.routes'
import coursesRoutes from './modules/courses/courses.routes'
import assignmentsRoutes from './modules/assignments/assignments.routes'
import submissionsRoutes from './modules/submissions/submissions.routes'
import conversationsRoutes from './modules/conversations/conversations.routes'
import aiRoutes from './modules/ai/ai.routes'


const app = express()
const PORT = process.env.PORT || 3000

app.use(cors())
app.use(express.json())

app.use('/auth', authRoutes)

app.use('/courses', coursesRoutes)

app.use('/courses/:courseId/assignments', assignmentsRoutes)

app.use(
  '/courses/:courseId/assignments/:assignmentId/submissions',
  submissionsRoutes
)

app.get('/health', (req, res) => {
  res.json({ status: 'Meridian API is running' })
})

app.listen(PORT, () => {
  console.log(`Meridian API running on port ${PORT}`)
})
// Conversations routes
app.use('/conversations', conversationsRoutes)
// AI routes — Sage assistant
app.use('/ai', aiRoutes)


export default app