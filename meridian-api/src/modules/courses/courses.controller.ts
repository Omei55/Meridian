import { Request, Response } from 'express'
import * as coursesService from './courses.service'

export const getCourses = async (req: Request, res: Response) => {
  try {
    const { userId, role } = req.user!

    let courses

    if (role === 'professor') {
      courses = await coursesService.getProfessorCourses(userId)
    } else {
      courses = await coursesService.getStudentCourses(userId)
    }

    res.status(200).json(courses)
  } catch (error: any) {
    res.status(500).json({ error: error.message })
  }
}

export const getCourse = async (req: Request, res: Response) => {
  try {
    const course = await coursesService.getCourseById(req.params.id)

    if (!course) {
      res.status(404).json({ error: 'Course not found' })
      return
    }

    res.status(200).json(course)
  } catch (error: any) {
    res.status(500).json({ error: error.message })
  }
}

export const createCourse = async (req: Request, res: Response) => {
  try {
    const { title, description, courseCode } = req.body

    if (!title || !courseCode) {
      res.status(400).json({ error: 'Title and course code are required' })
      return
    }

    const course = await coursesService.createCourse({
      professorId: req.user!.userId,
      title,
      description,
      courseCode
    })

    res.status(201).json(course)
  } catch (error: any) {
    res.status(500).json({ error: error.message })
  }
}

export const enrollInCourse = async (req: Request, res: Response) => {
  try {
    const courseId = req.params.id

    const course = await coursesService.getCourseById(courseId)

    if (!course) {
      res.status(404).json({ error: 'Course not found' })
      return
    }

    const enrollment = await coursesService.enrollStudent(
      req.user!.userId,
      courseId
    )

    res.status(201).json(enrollment)
  } catch (error: any) {
    if (error.code === '23505') {
      res.status(400).json({ error: 'Already enrolled in this course' })
      return
    }

    res.status(500).json({ error: error.message })
  }
}

export const unenrollFromCourse = async (req: Request, res: Response) => {
  try {
    await coursesService.unenrollStudent(
      req.user!.userId,
      req.params.id
    )

    res.status(200).json({ message: 'Unenrolled successfully' })
  } catch (error: any) {
    res.status(500).json({ error: error.message })
  }
}
export const searchByCode = async (req: Request, res: Response) => {
  try {
      const { code } = req.query
      if (!code) {
          res.status(400).json({ error: 'Course code is required' })
          return
      }
      const course = await coursesService.getCourseByCode(code as string)
      if (!course) {
          res.status(404).json({ error: 'Course not found' })
          return
      }
      res.status(200).json(course)
  } catch (error: any) {
      res.status(500).json({ error: error.message })
  }
}