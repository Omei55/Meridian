import { Request, Response } from 'express'

import * as conversationsService from './conversations.service'

export const getConversations = async (
  req: Request,
  res: Response
) => {
  try {
    const conversations =
      await conversationsService.getUserConversations(
        req.user!.userId
      )

    res.status(200).json(conversations)

  } catch (error: any) {
    res.status(500).json({ error: error.message })
  }
}

export const getOrCreateConversation = async (
  req: Request,
  res: Response
) => {
  try {
    const {
      participantTwoId,
      courseId,
      assignmentId
    } = req.body

    if (!participantTwoId) {
      res.status(400).json({
        error: 'participantTwoId is required'
      })
      return
    }

    const existing =
      await conversationsService.getConversationBetweenUsers(
        req.user!.userId,
        participantTwoId
      )

    if (existing) {
      res.status(200).json(existing)
      return
    }

    const conversation =
      await conversationsService.createConversation({
        participantOne: req.user!.userId,
        participantTwo: participantTwoId,
        courseId,
        assignmentId
      })

    res.status(201).json(conversation)

  } catch (error: any) {
    if (error.code === '23505') {
      const existing =
        await conversationsService.getConversationBetweenUsers(
          req.user!.userId,
          req.body.participantTwoId
        )

      res.status(200).json(existing)
      return
    }

    res.status(500).json({ error: error.message })
  }
}

export const updateLastMessage = async (
  req: Request,
  res: Response
) => {
  try {
    const { lastMessage } = req.body
    const { id } = req.params

    if (!lastMessage) {
      res.status(400).json({
        error: 'lastMessage is required'
      })
      return
    }

    await conversationsService.updateLastMessage(
      id,
      lastMessage
    )

    res.status(200).json({ success: true })

  } catch (error: any) {
    res.status(500).json({ error: error.message })
  }
}
export const getMessageableUsers = async (req: Request, res: Response) => {
    try {
      const users = await conversationsService.getMessageableUsers(
        req.user!.userId,
        req.user!.role
      )
      res.status(200).json(users)
    } catch (error: any) {
      res.status(500).json({ error: error.message })
    }
  }