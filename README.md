# Meridian: AI-Powered Academic Productivity Platform

[![App Store](https://img.shields.io/badge/App%20Store-Download-blue?logo=apple&logoColor=white)](https://apps.apple.com/us/app/meridian-academic-ai/id6793667755)

**Live on the App Store:** [Meridian: Academic AI](https://apps.apple.com/us/app/meridian-academic-ai/id6793667755)

Meridian is an iOS platform for students and professors with an AI study assistant called Sage. I designed and built every layer myself: the SwiftUI app, the Node.js and PostgreSQL backend, the realtime messaging, the RAG pipeline behind Sage, the production deployment, and the App Store release.

---

## Why I Built This

Canvas went down during finals week at ASU, and it made me notice how little intelligence there is in the tools students depend on every day. Students upload assignments, professors download them, and nothing in between helps anyone understand or plan their work.

Meridian is my attempt at something different. A student can open an assignment and ask "what is this actually asking me to do?" and get an answer based on the real assignment PDF, not a generic response.

---

## What Makes It Different

Meridian is not a Canvas clone. The core feature is **Sage**, an AI assistant powered by a RAG (Retrieval-Augmented Generation) pipeline that reads the actual assignment PDF and answers questions about it.

Sage can:
- Summarize what an assignment is asking
- Explain specific requirements in plain language
- Clarify deadlines
- Suggest a way to plan and approach the work

Sage will not complete assignments or write graded work for students. That rule is enforced in the system prompt, and I tested it by asking Sage to just solve an assignment. It declined and offered to explain the concept instead.

---

## Features

**Students**
- Join courses with a course code
- Dashboard with a deadline strip and enrolled courses
- Tasks tab grouping every assignment into overdue, due soon, and upcoming
- Assignment detail with a native PDF viewer
- Submit a PDF for any assignment
- Ask Sage about a specific assignment
- Message professors of courses they are enrolled in

**Professors**
- Create courses and share a join code
- Create, edit, and delete assignments with optional PDF attachments
- View and grade submissions
- Grading tab showing which assignments still have ungraded submissions
- Message students enrolled in their courses

**Platform**
- Role-based access for professor and student accounts
- JWT access tokens with refresh tokens
- Offline caching with a visible "showing cached data" state and retry
- In-app account deletion with a two step confirmation
- Realtime messaging with typing indicators, read receipts, and unread badges

---

## Tech Stack

**iOS**
- SwiftUI with MVVM
- `@Observable` view models
- async/await and structured concurrency
- SwiftData for offline caching
- Keychain for token storage
- Apple's Testing framework for unit tests

**Backend**
- Node.js, Express, TypeScript
- PostgreSQL
- JWT authentication with refresh tokens
- Role-based access control middleware
- Deployed on Railway

**AI**
- OpenAI `text-embedding-3-small` for embeddings
- GPT-4o for responses
- Pinecone for vector storage and similarity search
- PDF text extraction and chunking with overlap

**Realtime and Infrastructure**
- Firebase Firestore for messaging
- Firebase Storage for PDF uploads
- Firebase Cloud Functions, FCM, and APNs for push notifications

---

## Architecture

```
iOS Client (SwiftUI, MVVM)
      |
      v
REST API (Node.js, Express, TypeScript) on Railway
      |
      +--> PostgreSQL (users, courses, enrollments, assignments,
      |                submissions, conversations, refresh tokens)
      |
      +--> AI Service
      |       PDF -> chunks -> OpenAI embeddings -> Pinecone
      |       Question -> embedding -> similarity search -> GPT-4o
      |
      +--> Firebase
              Firestore (messages), Storage (PDFs),
              Cloud Function -> FCM -> APNs (push notifications)
```

### How Sage works

1. A professor uploads an assignment PDF.
2. The backend downloads it, extracts the text, and splits it into overlapping chunks.
3. Each chunk is embedded with OpenAI and stored in Pinecone with the assignment id as metadata.
4. When a student asks a question, it is embedded with the same model.
5. Pinecone returns the most similar chunks for that one assignment, using cosine similarity.
6. The chunks, plus the assignment title and due date, go to GPT-4o with a system prompt that tells it to explain and never solve.

---

## API Overview

**Auth**
- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`

**Users**
- `POST /users/device-token`
- `DELETE /users/me`

**Courses**
- `GET /courses`
- `POST /courses`
- `GET /courses/search?code=`
- `GET /courses/:id`
- `POST /courses/:id/enroll`
- `DELETE /courses/:id/enroll`

**Assignments**
- `GET /courses/:courseId/assignments`
- `POST /courses/:courseId/assignments`
- `GET /courses/:courseId/assignments/:id`
- `PATCH /courses/:courseId/assignments/:id`
- `DELETE /courses/:courseId/assignments/:id`

**Submissions**
- `POST /courses/:courseId/assignments/:assignmentId/submissions`
- `GET /courses/:courseId/assignments/:assignmentId/submissions`
- `GET /courses/:courseId/assignments/:assignmentId/submissions/me`
- `PATCH /courses/:courseId/assignments/:assignmentId/submissions/:id`

**Conversations**
- `GET /conversations`
- `POST /conversations`
- `GET /conversations/messageable-users`
- `PATCH /conversations/:id/last-message`

**AI**
- `POST /ai/ingest/:assignmentId`
- `POST /ai/chat`
- `GET /ai/summarize/:assignmentId`

---

## Database Schema

```
users           id, email, password_hash, full_name, role, device_token, created_at
courses         id, professor_id, title, description, course_code, is_active, created_at
enrollments     id, student_id, course_id, enrolled_at
assignments     id, course_id, title, description, file_url, due_date, created_at
submissions     id, assignment_id, student_id, file_url, status, grade, submitted_at
conversations   id, participant_one, participant_two, course_id, assignment_id,
                last_message, last_message_time, created_at
refresh_tokens  id, user_id, token, expires_at, created_at
```

Foreign keys use `ON DELETE CASCADE` where child rows have no meaning without their parent. Conversations use `ON DELETE SET NULL` for course and assignment links so message history survives if a course is deleted. Enrollments and submissions have unique constraints so a student cannot enroll twice or submit twice.

---

## Key Engineering Decisions

**PostgreSQL for core data, Firestore for messages.** Courses, assignments, and submissions are deeply relational, so PostgreSQL enforces the relationships at the database level. Chat messages are high volume and benefit from Firestore's realtime listeners, so they live there instead.

**Access and refresh tokens instead of one long-lived token.** Access tokens expire in 15 minutes and a 30 day refresh token renews them silently. If a request returns 401, the app refreshes and retries, so the user only sees a login screen once the refresh token itself expires. Refresh tokens are stored server side, so logout can actually revoke them.

**RAG instead of fine-tuning.** Professors upload new assignments constantly. With RAG a new PDF is chunked and embedded within seconds and is immediately answerable, with no retraining.

**Firestore instead of a custom WebSocket server.** As a solo developer I traded some low level control for reconnection handling, offline support, and listeners that already work. The tradeoff is dependence on Firebase pricing at larger scale.

**Role checks live in middleware.** `requireRole('professor')` is one line on a route, instead of an `if` check repeated in every controller. The backend is where this is enforced. Hiding a button in the app is only a convenience.

**Offline first on the client.** Screens load cached SwiftData first, then refresh from the network in the background. If the refresh fails, the cached data stays on screen with a retry option instead of going blank.

**Files never touch the API server.** The app uploads PDFs straight to Firebase Storage and sends only the download URL to the backend.

---

## Testing

Unit tests use Apple's Testing framework and cover the `Assignment`, `Course`, and `Submission` models and login form validation. Writing them caught a real bug in the deadline logic: "due tomorrow" could display as "due today" depending on the time of day, because it compared exact timestamps instead of calendar days.

---

## Repository Layout

```
Meridian/             iOS app (SwiftUI)
meridian-api/         Node.js, Express, TypeScript backend
meridian-functions/   Firebase Cloud Function for push notifications
```

---

## Running Locally

### Backend

```bash
cd meridian-api
npm install
cp .env.example .env
npm run dev
```

Use Node 20 or later. Earlier versions are missing built-in `fetch`, which the OpenAI and Pinecone SDKs expect.

### Environment Variables

```
DATABASE_URL=postgresql://localhost/meridian
JWT_SECRET=your_secret_here
OPENAI_API_KEY=your_key_here
PINECONE_API_KEY=your_key_here
PINECONE_INDEX=meridian
PORT=3000
```

### iOS

Open `Meridian.xcodeproj` in Xcode, add your own `GoogleService-Info.plist` from a Firebase project, and point `APIClient.baseURL` at your backend.

---

## Known Limitations

- Push notification delivery is not fully verified end to end. Device token registration and the Cloud Function trigger work, but live delivery to a device was still hitting an APNs credential error when I last tested. In-app messaging is unaffected.
- Deleting an account removes the user and all PostgreSQL data through cascades, but does not yet remove that user's messages from Firestore.
- Sage uses a prompt-level guardrail for academic integrity. It reduces misuse but is not an airtight guarantee.
- Dark mode is not supported. The app is locked to light mode.

---

## Roadmap

- [x] PostgreSQL schema and role-based access
- [x] Courses, assignments, and submissions
- [x] SwiftUI app for both roles
- [x] Realtime messaging with Firestore
- [x] Sage RAG pipeline with OpenAI and Pinecone
- [x] Refresh token authentication
- [x] Offline caching with SwiftData
- [x] Production deployment on Railway
- [x] App Store release
- [ ] Finish and verify push notification delivery
- [ ] Clean up Firestore data on account deletion
- [ ] Background job queue for PDF ingestion
- [ ] Dark mode
- [ ] Android version

---

## About

Built by Omkar Sapkal. M.S. in Software Engineering at Arizona State University.

[LinkedIn](https://linkedin.com/in/omkarsapkal) | [App Store](https://apps.apple.com/us/app/meridian-academic-ai/id6793667755)
