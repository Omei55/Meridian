import pool from '../../config/db'

interface CreateSubmissionInput {
  assignmentId: string
  studentId: string
  fileUrl: string
}

export const getSubmissionsByAssignment = async (assignmentId: string) => {
  const result = await pool.query(
    `SELECT submissions.*, users.full_name, users.email
     FROM submissions
     JOIN users ON submissions.student_id = users.id
     WHERE submissions.assignment_id = $1
     ORDER BY submissions.submitted_at DESC`,
    [assignmentId]
  )

  return result.rows
}

export const getStudentSubmission = async (
  assignmentId: string,
  studentId: string
) => {
  const result = await pool.query(
    `SELECT * FROM submissions
     WHERE assignment_id = $1 AND student_id = $2`,
    [assignmentId, studentId]
  )

  return result.rows[0] || null
}

export const createSubmission = async (input: CreateSubmissionInput) => {
  const { assignmentId, studentId, fileUrl } = input

  const result = await pool.query(
    `INSERT INTO submissions (assignment_id, student_id, file_url)
     VALUES ($1, $2, $3)
     RETURNING *`,
    [assignmentId, studentId, fileUrl]
  )

  return result.rows[0]
}

export const updateSubmission = async (
  submissionId: string,
  status: string,
  grade: string | null
) => {
  const result = await pool.query(
    `UPDATE submissions SET
      status = COALESCE($1, status),
      grade = COALESCE($2, grade)
     WHERE id = $3
     RETURNING *`,
    [status, grade, submissionId]
  )

  return result.rows[0]
}