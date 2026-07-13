import pool from '../../config/db'

interface CreateAssignmentInput {
  courseId: string
  title: string
  description: string
  fileUrl: string | null
  dueDate: string
}

export const getAssignmentsByCourse = async (courseId: string) => {
  const result = await pool.query(
    `SELECT * FROM assignments
     WHERE course_id = $1
     ORDER BY due_date ASC`,
    [courseId]
  )

  return result.rows
}

export const getAssignmentById = async (assignmentId: string) => {
  const result = await pool.query(
    `SELECT * FROM assignments WHERE id = $1`,
    [assignmentId]
  )

  return result.rows[0] || null
}

export const createAssignment = async (input: CreateAssignmentInput) => {
  const { courseId, title, description, fileUrl, dueDate } = input

  const result = await pool.query(
    `INSERT INTO assignments (course_id, title, description, file_url, due_date)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING *`,
    [courseId, title, description, fileUrl, dueDate]
  )

  return result.rows[0]
}

export const updateAssignment = async (
  assignmentId: string,
  updates: Partial<CreateAssignmentInput>
) => {
  const result = await pool.query(
    `UPDATE assignments SET
      title = COALESCE($1, title),
      description = COALESCE($2, description),
      file_url = COALESCE($3, file_url),
      due_date = COALESCE($4, due_date)
     WHERE id = $5
     RETURNING *`,
    [
      updates.title,
      updates.description,
      updates.fileUrl,
      updates.dueDate,
      assignmentId
    ]
  )

  return result.rows[0]
}

export const deleteAssignment = async (assignmentId: string) => {
  await pool.query(
    `DELETE FROM assignments WHERE id = $1`,
    [assignmentId]
  )
}