// users.controller.ts

import { Request, Response } from 'express'
import * as usersService from './users.service'

// SAVE DEVICE TOKEN
export const saveDeviceToken = async (req: Request, res: Response) => {
    try {
        const { deviceToken } = req.body

        if (!deviceToken) {
            res.status(400).json({ error: 'deviceToken is required' })
            return
        }

        await usersService.saveDeviceToken(req.user!.userId, deviceToken)
        res.status(200).json({ success: true })

    } catch (error: any) {
        res.status(500).json({ error: error.message })
    }
}
// GET DEVICE INFO
// Public endpoint called by Cloud Function — no auth needed
// since it's called server-to-server, not from a client app
export const getDeviceInfo = async (req: Request, res: Response) => {
    try {
        const { id } = req.params
        
        const info = await usersService.getDeviceInfo(id)
        
        if (!info) {
            res.status(404).json({ error: 'User not found' })
            return
        }
        
        res.status(200).json(info)
        
    } catch (error: any) {
        res.status(500).json({ error: error.message })
    }
}