import { Request, Response } from 'express'

import * as submissionsService from './submissions.service'
import * as assignmentsService from '../assignments/assignments.service'

export const getSubmissions = async (req: Request, res: Response) => {
  try {
    const { assignmentId } = req.params

    const assignment = await assignmentsService.getAssignmentById(assignmentId)

    if (!assignment) {
      res.status(404).json({ error: 'Assignment not found' })
      return
    }

    const submissions =
      await submissionsService.getSubmissionsByAssignment(assignmentId)

    res.status(200).json(submissions)
  } catch (error: any) {
    res.status(500).json({ error: error.message })
  }
}

export const getMySubmission = async (req: Request, res: Response) => {
  try {
    const { assignmentId } = req.params

    const submission = await submissionsService.getStudentSubmission(
      assignmentId,
      req.user!.userId
    )

    if (!submission) {
      res.status(200).json(null)
      return
    }

    res.status(200).json(submission)
  } catch (error: any) {
    res.status(500).json({ error: error.message })
  }
}

export const createSubmission = async (req: Request, res: Response) => {
  try {
    const { assignmentId } = req.params
    const { fileUrl } = req.body

    if (!fileUrl) {
      res.status(400).json({ error: 'File URL is required' })
      return
    }

    const assignment = await assignmentsService.getAssignmentById(assignmentId)

    if (!assignment) {
      res.status(404).json({ error: 'Assignment not found' })
      return
    }

    const submission = await submissionsService.createSubmission({
      assignmentId,
      studentId: req.user!.userId,
      fileUrl
    })

    res.status(201).json(submission)
  } catch (error: any) {
    if (error.code === '23505') {
      res.status(400).json({
        error: 'Already submitted for this assignment'
      })
      return
    }

    res.status(500).json({ error: error.message })
  }
}

export const updateSubmission = async (req: Request, res: Response) => {
  try {
    const { status, grade } = req.body

    const updated = await submissionsService.updateSubmission(
      req.params.id,
      status,
      grade || null
    )

    if (!updated) {
      res.status(404).json({ error: 'Submission not found' })
      return
    }

    res.status(200).json(updated)
  } catch (error: any) {
    res.status(500).json({ error: error.message })
  }
}