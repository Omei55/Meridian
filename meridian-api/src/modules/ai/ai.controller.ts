// ai.controller.ts
// Thin layer between routes and ai.service
// Handles HTTP requests and responses for all AI endpoints
 
import { Request, Response } from 'express'
import * as aiService from './ai.service'
import pool from '../../config/db'

// INGEST PDF
// Called automatically when a professor creates an assignment with a PDF
// Also callable manually to re-ingest if the PDF changes
export const ingestPDF = async (req: Request, res: Response) => {
    try {
        const { assignmentId } = req.params
        
        // Fetch assignment from database to get the file URL
        // and verify it exists and has a PDF attached
        const result = await pool.query(
            `SELECT * FROM assignments WHERE id = $1`,
            [assignmentId]
        )
        
        const assignment = result.rows[0]
        
        if (!assignment) {
            res.status(404).json({ error: 'Assignment not found' })
            return
        }
        
        if (!assignment.file_url) {
            res.status(400).json({ error: 'Assignment has no PDF attached' })
            return
        }
        
        // Run the ingestion pipeline
        // This downloads the PDF, extracts text, embeds, stores in Pinecone
        const ingestionResult = await aiService.ingestPDF(
            assignmentId,
            assignment.course_id,
            assignment.file_url
        )
        
        res.status(200).json(ingestionResult)
        
    } catch (error: any) {
        res.status(500).json({ error: error.message })
    }
}

// CHAT
// Student sends a message to Sage about a specific assignment
// Returns Sage's contextual response
export const chat = async (req: Request, res: Response) => {
    try {
        const { question, assignmentId, conversationHistory } = req.body
        
        if (!question || !assignmentId) {
            res.status(400).json({ error: 'question and assignmentId are required' })
            return
        }
        
        // Fetch assignment metadata to include in prompt
        const result = await pool.query(
            `SELECT title, due_date, description FROM assignments WHERE id = $1`,
            [assignmentId]
        )
        
        const assignment = result.rows[0]
        const metadata = assignment ? {
            title: assignment.title,
            dueDate: new Date(assignment.due_date).toLocaleDateString('en-US', {
                weekday: 'long',
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            }),
            description: assignment.description || ''
        } : undefined
        
        const response = await aiService.chat(
            question,
            assignmentId,
            conversationHistory || [],
            metadata
        )
        
        res.status(200).json(response)
        
    } catch (error: any) {
        res.status(500).json({ error: error.message })
    }
}

// SUMMARIZE
// Returns a quick summary of what an assignment is about
// Called when student first opens Sage for an assignment
export const summarize = async (req: Request, res: Response) => {
    try {
        const { assignmentId } = req.params
        
        const result = await aiService.summarizeAssignment(assignmentId)
        
        res.status(200).json(result)
        
    } catch (error: any) {
        res.status(500).json({ error: error.message })
    }
}