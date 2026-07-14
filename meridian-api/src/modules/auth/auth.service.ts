import pool from '../../config/db'
import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'
import crypto from 'crypto'

// Generate a secure random refresh token
// Not a JWT — just a random string stored in DB
const generateRefreshToken = (): string => {
    return crypto.randomBytes(40).toString('hex')
}

interface RegisterInput {
  fullName: string
  email: string
  password: string
  role: 'professor' | 'student'
}

interface LoginInput {
  email: string
  password: string
}

// Helper — creates both tokens and saves refresh token to DB
// Used by both register and login so we don't repeat this logic
const generateTokenPair = async (userId: string, role: string) => {
  // Access token — short lived, used for every API call
  const accessToken = jwt.sign(
    { userId, role },
    process.env.JWT_SECRET as string,
    { expiresIn: '15m' }
  )

  // Refresh token — long lived, stored in DB
  const refreshToken = generateRefreshToken()
  const expiresAt = new Date()
  expiresAt.setDate(expiresAt.getDate() + 30) // 30 days from now

  await pool.query(
    `INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES ($1, $2, $3)`,
    [userId, refreshToken, expiresAt]
  )

  return { accessToken, refreshToken }
}

export const register = async (input: RegisterInput) => {
  const { fullName, email, password, role } = input

  const existing = await pool.query(
    'SELECT id FROM users WHERE email = $1',
    [email]
  )

  if (existing.rows.length > 0) {
    throw new Error('Email already in use')
  }

  const passwordHash = await bcrypt.hash(password, 10)

  const result = await pool.query(
    `INSERT INTO users (full_name, email, password_hash, role)
     VALUES ($1, $2, $3, $4)
     RETURNING id, full_name, email, role, created_at`,
    [fullName, email, passwordHash, role]
  )

  const user = result.rows[0]

  const { accessToken, refreshToken } = await generateTokenPair(user.id, user.role)

  return { user, accessToken, refreshToken }
}

export const login = async (input: LoginInput) => {
  const { email, password } = input

  const result = await pool.query(
    'SELECT * FROM users WHERE email = $1',
    [email]
  )

  if (result.rows.length === 0) {
    throw new Error('Invalid email or password')
  }

  const user = result.rows[0]

  const passwordMatch = await bcrypt.compare(password, user.password_hash)

  if (!passwordMatch) {
    throw new Error('Invalid email or password')
  }

  const { accessToken, refreshToken } = await generateTokenPair(user.id, user.role)

  return {
    user: {
      id: user.id,
      fullName: user.full_name,
      email: user.email,
      role: user.role,
    },
    accessToken,
    refreshToken
  }
}

// REFRESH ACCESS TOKEN
// Called when access token expires
// Verifies refresh token exists and hasn't expired
// Issues a brand new access token
export const refreshAccessToken = async (refreshToken: string) => {
  const result = await pool.query(
    `SELECT * FROM refresh_tokens WHERE token = $1 AND expires_at > NOW()`,
    [refreshToken]
  )

  if (result.rows.length === 0) {
    throw new Error('Invalid or expired refresh token')
  }

  const tokenRecord = result.rows[0]

  // Get user info to include role in new access token
  const userResult = await pool.query(
    `SELECT id, role FROM users WHERE id = $1`,
    [tokenRecord.user_id]
  )

  const user = userResult.rows[0]

  const newAccessToken = jwt.sign(
    { userId: user.id, role: user.role },
    process.env.JWT_SECRET as string,
    { expiresIn: '15m' }
  )

  return { accessToken: newAccessToken }
}

// LOGOUT
// Deletes the refresh token so it can no longer be used
export const logout = async (refreshToken: string) => {
  await pool.query(
    `DELETE FROM refresh_tokens WHERE token = $1`,
    [refreshToken]
  )
}