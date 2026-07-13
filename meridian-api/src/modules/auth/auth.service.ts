import pool from '../../config/db'
import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'

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

  const token = jwt.sign(
    { userId: user.id, role: user.role },
    process.env.JWT_SECRET as string,
    { expiresIn: '7d' }
  )

  return { user, token }
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

  const token = jwt.sign(
    { userId: user.id, role: user.role },
    process.env.JWT_SECRET as string,
    { expiresIn: '7d' }
  )

  return {
    user: {
      id: user.id,
      fullName: user.full_name,
      email: user.email,
      role: user.role,
    },
    token
  }
}