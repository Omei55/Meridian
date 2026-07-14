import { Request, Response } from 'express'
import * as authService from './auth.service'

export const register = async (req: Request, res: Response) => {
  try {
    const { fullName, email, password, role } = req.body

    if (!fullName || !email || !password || !role) {
      res.status(400).json({ error: 'All fields are required' })
      return
    }

    const result = await authService.register({
      fullName,
      email,
      password,
      role,
    })

    res.status(201).json(result)
  } catch (error: any) {
    res.status(400).json({ error: error.message })
  }
}

export const login = async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body

    if (!email || !password) {
      res.status(400).json({ error: 'Email and password are required' })
      return
    }

    const result = await authService.login({ email, password })

    res.status(200).json(result)
  } catch (error: any) {
    res.status(401).json({ error: error.message })
  }
}

// REFRESH TOKEN
// iOS calls this when it gets a 401 with an expired access token
// Returns a fresh access token if the refresh token is still valid
export const refresh = async (req: Request, res: Response) => {
  try {
    const { refreshToken } = req.body

    if (!refreshToken) {
      res.status(400).json({ error: 'refreshToken is required' })
      return
    }

    const result = await authService.refreshAccessToken(refreshToken)
    res.status(200).json(result)

  } catch (error: any) {
    // Refresh token invalid or expired — user must log in again
    res.status(401).json({ error: error.message })
  }
}

// LOGOUT
// Deletes the refresh token so it can't be used again
export const logout = async (req: Request, res: Response) => {
  try {
    const { refreshToken } = req.body

    if (refreshToken) {
      await authService.logout(refreshToken)
    }

    res.status(200).json({ success: true })

  } catch (error: any) {
    res.status(500).json({ error: error.message })
  }
}