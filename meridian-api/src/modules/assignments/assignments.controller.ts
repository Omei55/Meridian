import { Request, Response } from 'express'
import * as assignmentsService from './assignments.service'
import * as aiService from '../ai/ai.service'

export const getAssignments = async (req: Request, res: Response) => {
  try {
    const { courseId } = req.params

    const assignments = await assignmentsService.getAssignmentsByCourse(
      courseId
    )

    res.status(200).json(assignments)
  } catch (error: any) {
    res.status(500).json({ error: error.message })
  }
}

export const getAssignment = async (req: Request, res: Response) => {
  try {
    const assignment = await assignmentsService.getAssignmentById(
      req.params.id
    )

    if (!assignment) {
      res.status(404).json({ error: 'Assignment not found' })
      return
    }

    res.status(200).json(assignment)
  } catch (error: any) {
    res.status(500).json({ error: error.message })
  }
}

export const createAssignment = async (req: Request, res: Response) => {
  try {
    const { courseId } = req.params
    const { title, description, fileUrl, dueDate } = req.body

    if (!title || !dueDate) {
      res.status(400).json({ error: 'Title and due date are required' })
      return
    }

    const assignment = await assignmentsService.createAssignment({
      courseId,
      title,
      description,
      fileUrl: fileUrl || null,
      dueDate
    })
    if (fileUrl) {
      // Run ingestion in background — don't wait for it
      // Student can start asking questions while ingestion runs
      aiService.ingestPDF(assignment.id, courseId, fileUrl)
          .then(() => console.log(`Ingestion complete for assignment ${assignment.id}`))
          .catch(err => console.error(`Ingestion failed: ${err.message}`))
     }
    

    res.status(201).json(assignment)
  } catch (error: any) {
    res.status(500).json({ error: error.message })
  }
  
}

export const updateAssignment = async (req: Request, res: Response) => {
  try {
    const existing = await assignmentsService.getAssignmentById(req.params.id)

    if (!existing) {
      res.status(404).json({ error: 'Assignment not found' })
      return
    }

    const updated = await assignmentsService.updateAssignment(
      req.params.id,
      req.body
    )

    res.status(200).json(updated)
  } catch (error: any) {
    res.status(500).json({ error: error.message })
  }
}

export const deleteAssignment = async (req: Request, res: Response) => {
  try {
    const existing = await assignmentsService.getAssignmentById(req.params.id)

    if (!existing) {
      res.status(404).json({ error: 'Assignment not found' })
      return
    }

    await assignmentsService.deleteAssignment(req.params.id)

    res.status(200).json({
      message: 'Assignment deleted successfully'
    })
  } catch (error: any) {
    res.status(500).json({ error: error.message })
  }
}