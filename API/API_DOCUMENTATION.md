# Academic Performance Management System - API Documentation

## Base URL
```
http://localhost:4000/api
```

## Authentication
Currently authentication is not enforced. Production deployment should implement JWT-based authentication.

## Response Format

All responses follow a standard JSON format:

**Success Response:**
```json
{
  "data": { /* resource data */ }
}
```

**Error Response:**
```json
{
  "error": "Error message",
  "details": { /* validation errors if applicable */ }
}
```

## Endpoints

### Users API

#### List Users
```
GET /api/users
```
Response: `200 OK`
```json
{
  "data": [
    {
      "id": "uuid",
      "email": "user@example.com",
      "role": "teacher",
      "full_name": "John Doe",
      "active": true,
      "inserted_at": "2026-05-28T10:00:00Z"
    }
  ]
}
```

#### Create User
```
POST /api/users
Content-Type: application/json

{
  "user": {
    "email": "user@example.com",
    "password_hash": "hashed_password",
    "role": "teacher",
    "full_name": "John Doe"
  }
}
```
Response: `201 Created`

#### Get User
```
GET /api/users/{id}
```

#### Update User
```
PUT /api/users/{id}
Content-Type: application/json

{
  "user": {
    "full_name": "Updated Name"
  }
}
```

#### Delete User
```
DELETE /api/users/{id}
```
Response: `204 No Content`

---

### Students API

#### List Students
```
GET /api/students
```

#### Create Student
```
POST /api/students
Content-Type: application/json

{
  "student": {
    "registration_number": "2024001",
    "full_name": "Jane Smith",
    "email": "jane@example.com",
    "status": "registered"
  }
}
```
Response: `201 Created`

#### Get Student
```
GET /api/students/{id}
```

#### Get Student Performance
```
GET /api/students/{id}/performance
```
Response:
```json
{
  "data": {
    "student": { /* student object */ },
    "records": [ /* academic records */ ],
    "avg_grade": 8.5,
    "avg_attendance": 92.0
  }
}
```

#### Get Student Risk Profile
```
GET /api/students/{id}/risk
```
Response:
```json
{
  "data": {
    "current_assessment": {
      "risk_level": "low",
      "dropout_probability": 5.0,
      "failure_probability": 2.0,
      "average_grade": 8.5,
      "average_attendance": 92.0
    },
    "historical_assessments": [ /* past assessments */ ]
  }
}
```

#### Update Student
```
PUT /api/students/{id}
Content-Type: application/json

{
  "student": {
    "status": "enrolled"
  }
}
```

#### Delete Student
```
DELETE /api/students/{id}
```

---

### Disciplines API

#### List Disciplines
```
GET /api/disciplines?semester=1
```
Query Parameters:
- `semester` (optional): Filter by semester number

#### Create Discipline
```
POST /api/disciplines
Content-Type: application/json

{
  "discipline": {
    "name": "Mathematics",
    "code": "MATH101",
    "semester": 1,
    "credits": 4,
    "workload": 60
  }
}
```

#### Get Discipline
```
GET /api/disciplines/{id}
```

#### Get Discipline Statistics
```
GET /api/disciplines/{id}/stats
```
Response:
```json
{
  "data": {
    "discipline": { /* discipline object */ },
    "total_students": 45,
    "avg_grade": 7.2,
    "avg_attendance": 85.0,
    "at_risk_count": 8
  }
}
```

#### Update Discipline
```
PUT /api/disciplines/{id}
Content-Type: application/json

{
  "discipline": {
    "credits": 5
  }
}
```

#### Delete Discipline
```
DELETE /api/disciplines/{id}
```

---

### Enrollments API

#### List Enrollments
```
GET /api/enrollments?student_id={id}
GET /api/enrollments?discipline_id={id}
```
Query Parameters:
- `student_id` (optional): Filter by student
- `discipline_id` (optional): Filter by discipline

#### Create Enrollment
```
POST /api/enrollments
Content-Type: application/json

{
  "enrollment": {
    "student_id": "uuid",
    "discipline_id": "uuid",
    "status": "active"
  }
}
```

#### Get Enrollment
```
GET /api/enrollments/{id}
```

#### Update Enrollment
```
PUT /api/enrollments/{id}
Content-Type: application/json

{
  "enrollment": {
    "status": "completed"
  }
}
```

#### Delete Enrollment
```
DELETE /api/enrollments/{id}
```

---

### Academic Records API

#### List Academic Records
```
GET /api/academic-records?student_id={id}
GET /api/academic-records?discipline_id={id}
```

#### Create Academic Record
```
POST /api/academic-records
Content-Type: application/json

{
  "academic_record": {
    "student_id": "uuid",
    "discipline_id": "uuid",
    "grade": 8.5,
    "attendance_percentage": 92.0,
    "enrollment_id": "uuid"
  }
}
```

#### Get Record
```
GET /api/academic-records/{id}
```

#### Update Record
```
PUT /api/academic-records/{id}
Content-Type: application/json

{
  "academic_record": {
    "grade": 9.0,
    "attendance_percentage": 95.0
  }
}
```

#### Delete Record
```
DELETE /api/academic-records/{id}
```

---

### Risk Assessments API

#### List Risk Assessments
```
GET /api/risk-assessments?student_id={id}
```

#### Create Risk Assessment
```
POST /api/risk-assessments
Content-Type: application/json

{
  "student_id": "uuid",
  "risk_assessment": {
    "risk_level": "medium",
    "dropout_probability": 35.5,
    "failure_probability": 42.0,
    "notes": "Assessment notes"
  }
}
```

#### Get Latest Assessment
```
GET /api/risk-assessments/{id}
```

---

### Alerts API

#### List Alerts
```
GET /api/alerts?risk_assessment_id={id}
```

#### Get Active Alerts
```
GET /api/alerts/{id}
```

#### Mark Alert as Read
```
PUT /api/alerts/{id}
Content-Type: application/json

{
  "alert": {
    "is_read": true
  }
}
```

#### Dismiss Alert
```
PUT /api/alerts/{id}
Content-Type: application/json

{
  "alert": {
    "dismissed": true
  }
}
```

---

### Reports API

#### List User Reports
```
GET /api/reports?user_id={id}
```

#### Get Report
```
GET /api/reports/{id}
```

#### Generate Cohort Report
```
POST /api/reports/cohort
Content-Type: application/json

{
  "user_id": "uuid",
  "period_start": "2026-05-01T00:00:00Z",
  "period_end": "2026-05-31T23:59:59Z"
}
```

#### Generate Discipline Report
```
POST /api/reports/discipline
Content-Type: application/json

{
  "user_id": "uuid",
  "discipline_id": "uuid",
  "period_start": "2026-05-01T00:00:00Z",
  "period_end": "2026-05-31T23:59:59Z"
}
```

#### Generate Individual Report
```
POST /api/reports/individual
Content-Type: application/json

{
  "user_id": "uuid",
  "student_id": "uuid",
  "period_start": "2026-05-01T00:00:00Z",
  "period_end": "2026-05-31T23:59:59Z"
}
```

#### Generate Risk Analysis Report
```
POST /api/reports/risk-analysis
Content-Type: application/json

{
  "user_id": "uuid",
  "period_start": "2026-05-01T00:00:00Z",
  "period_end": "2026-05-31T23:59:59Z"
}
```

---

## Error Codes

| Code | Description |
|------|-------------|
| 200 | OK - Successful GET request |
| 201 | Created - Successful POST request |
| 204 | No Content - Successful DELETE request |
| 400 | Bad Request - Invalid parameters or validation error |
| 404 | Not Found - Resource not found |
| 500 | Internal Server Error |

---

## Status Values

### User Role
- `admin`
- `teacher`
- `manager`

### Student Status
- `registered`
- `enrolled`
- `approved`
- `failed`
- `dropped_out`

### Enrollment Status
- `active`
- `completed`
- `dropped`

### Risk Level
- `low`
- `medium`
- `high`
- `critical`

### Alert Severity
- `info`
- `warning`
- `critical`

### Report Type
- `cohort`
- `discipline`
- `individual`
- `risk_analysis`
