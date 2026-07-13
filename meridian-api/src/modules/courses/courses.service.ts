import pool from '../../config/db'

interface CreateCourseInput {
  professorId: string
  title: string
  description: string
  courseCode: string
}

export const getProfessorCourses = async (professorId: string) => {
  const result = await pool.query(
    `SELECT * FROM courses 
     WHERE professor_id = $1 
     ORDER BY created_at DESC`,
    [professorId]
  )

  return result.rows
}

export const getStudentCourses = async (studentId: string) => {
  const result = await pool.query(
    `SELECT courses.* FROM courses
     JOIN enrollments ON courses.id = enrollments.course_id
     WHERE enrollments.student_id = $1
     ORDER BY enrollments.enrolled_at DESC`,
    [studentId]
  )

  return result.rows
}

export const getCourseById = async (courseId: string) => {
  const result = await pool.query(
    `SELECT * FROM courses WHERE id = $1`,
    [courseId]
  )

  return result.rows[0] || null
}

export const createCourse = async (input: CreateCourseInput) => {
  const { professorId, title, description, courseCode } = input

  const result = await pool.query(
    `INSERT INTO courses (professor_id, title, description, course_code)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
    [professorId, title, description, courseCode]
  )

  return result.rows[0]
}

export const enrollStudent = async (
  studentId: string,
  courseId: string
) => {
  const result = await pool.query(
    `INSERT INTO enrollments (student_id, course_id)
     VALUES ($1, $2)
     RETURNING *`,
    [studentId, courseId]
  )

  return result.rows[0]
}

export const unenrollStudent = async (
  studentId: string,
  courseId: string
) => {
  await pool.query(
    `DELETE FROM enrollments
     WHERE student_id = $1 AND course_id = $2`,
    [studentId, courseId]
  )
}
// Find a course by its course code
// Used by students to search before enrolling
export const getCourseByCode = async (courseCode: string) => {
  const result = await pool.query(
      `SELECT * FROM courses WHERE LOWER(course_code) = LOWER($1)`,
      [courseCode]
  )
  return result.rows[0] || null
}