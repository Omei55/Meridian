import { Request, Response, NextFunction } from 'express'

export const requireRole = (role: 'professor' | 'student') => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      res.status(401).json({ error: 'Not authenticated' })
      return
    }

    if (req.user.role !== role) {
      res.status(403).json({ error: 'Access denied' })
      return
    }

    next()
  }
}