import pool from '../../config/db'

interface CreateConversationInput {
  participantOne: string
  participantTwo: string
  courseId?: string
  assignmentId?: string
}

export const getUserConversations = async (userId: string) => {
  const result = await pool.query(
    `SELECT
      c.*,
      CASE
        WHEN c.participant_one = $1 THEN u2.full_name
        ELSE u1.full_name
      END AS other_user_name,
      CASE
        WHEN c.participant_one = $1 THEN u2.email
        ELSE u1.email
      END AS other_user_email,
      CASE
        WHEN c.participant_one = $1 THEN u2.id
        ELSE u1.id
      END AS other_user_id,
      CASE
        WHEN c.participant_one = $1 THEN u2.role
        ELSE u1.role
      END AS other_user_role
    FROM conversations c
    JOIN users u1 ON c.participant_one = u1.id
    JOIN users u2 ON c.participant_two = u2.id
    WHERE c.participant_one = $1 OR c.participant_two = $1
    ORDER BY c.last_message_time DESC NULLS LAST`,
    [userId]
  )

  return result.rows
}

export const getConversationById = async (conversationId: string) => {
  const result = await pool.query(
    `SELECT * FROM conversations
     WHERE id = $1`,
    [conversationId]
  )

  return result.rows[0] || null
}

export const getConversationBetweenUsers = async (
  userOneId: string,
  userTwoId: string
) => {
  const result = await pool.query(
    `SELECT * FROM conversations
     WHERE (participant_one = $1 AND participant_two = $2)
        OR (participant_one = $2 AND participant_two = $1)`,
    [userOneId, userTwoId]
  )

  return result.rows[0] || null
}

export const createConversation = async (
  input: CreateConversationInput
) => {
  const {
    participantOne,
    participantTwo,
    courseId,
    assignmentId
  } = input

  const result = await pool.query(
    `INSERT INTO conversations
      (participant_one, participant_two, course_id, assignment_id)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
    [
      participantOne,
      participantTwo,
      courseId || null,
      assignmentId || null
    ]
  )

  return result.rows[0]
}

export const updateLastMessage = async (
  conversationId: string,
  lastMessage: string
) => {
  await pool.query(
    `UPDATE conversations
     SET last_message = $1,
         last_message_time = NOW()
     WHERE id = $2`,
    [lastMessage, conversationId]
  )
}
export const getMessageableUsers = async (userId: string, role: string) => {
    let result
  
    if (role === 'student') {
      // Student sees professors of courses they're enrolled in
      result = await pool.query(
        `SELECT DISTINCT ON (u.id) u.id, u.full_name, u.email, u.role, c.title as course_title
         FROM users u
         JOIN courses c ON c.professor_id = u.id
         JOIN enrollments e ON e.course_id = c.id
         WHERE e.student_id = $1`,
        [userId]
      )
    } else {
      // Professor sees students enrolled in their courses
      result = await pool.query(
        `SELECT DISTINCT u.id, u.full_name, u.email, u.role, c.title as course_title
         FROM users u
         JOIN enrollments e ON e.student_id = u.id
         JOIN courses c ON c.id = e.course_id
         WHERE c.professor_id = $1`,
        [userId]
      )
    }
  
    return result.rows
  }