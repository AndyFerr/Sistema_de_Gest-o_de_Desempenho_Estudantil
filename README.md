# Academic Performance Management System

Backend API for student academic performance monitoring and predictive risk analysis system built with Elixir and Phoenix.

## Project Overview

This system provides comprehensive academic performance management including:
- Student performance tracking
- Risk assessment and prediction
- Alert generation
- Report generation (cohort, discipline, individual, risk analysis)
- Dashboard support for teachers and managers

## Architecture

### Core Components

1. **Schemas** - Domain models representing core entities
   - User (Teacher, Manager, Admin)
   - Student
   - Discipline
   - Enrollment
   - AcademicRecord
   - RiskAssessment
   - Alert
   - Report

2. **Context Modules** - Business logic layer
   - Users context
   - Students context
   - Disciplines context
   - Enrollments context
   - AcademicRecords context

3. **Services** - Domain-specific operations
   - RiskEngine - AI-based risk assessment and prediction
   - AlertService - Alert generation and management
   - ReportService - Report generation

4. **Controllers** - REST API endpoints
   - User management
   - Student management
   - Discipline management
   - Enrollment management
   - Academic records
   - Risk assessments
   - Alerts
   - Reports

## Technology Stack

- **Language**: Elixir
- **Framework**: Phoenix 1.7
- **Database**: PostgreSQL
- **ORM**: Ecto

## Setup

### Prerequisites
- Elixir 1.14+
- PostgreSQL 12+
- Mix package manager

### Installation

1. Install dependencies:
```bash
mix deps.get
```

2. Create and migrate database:
```bash
mix ecto.setup
```

3. Start the server:
```bash
mix phx.server
```

Server runs on `http://localhost:4000`

## API Endpoints

### Users
- `GET /api/users` - List all users
- `POST /api/users` - Create user
- `GET /api/users/:id` - Get user details
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

### Students
- `GET /api/students` - List students
- `POST /api/students` - Create student
- `GET /api/students/:id` - Get student details
- `GET /api/students/:id/performance` - Get student performance metrics
- `GET /api/students/:id/risk` - Get risk profile with assessments
- `PUT /api/students/:id` - Update student
- `DELETE /api/students/:id` - Delete student

### Disciplines
- `GET /api/disciplines` - List disciplines
- `POST /api/disciplines` - Create discipline
- `GET /api/disciplines/:id` - Get discipline details
- `GET /api/disciplines/:id/stats` - Get discipline statistics
- `PUT /api/disciplines/:id` - Update discipline
- `DELETE /api/disciplines/:id` - Delete discipline

### Enrollments
- `GET /api/enrollments` - List enrollments
- `POST /api/enrollments` - Create enrollment
- `GET /api/enrollments/:id` - Get enrollment details
- `PUT /api/enrollments/:id` - Update enrollment
- `DELETE /api/enrollments/:id` - Delete enrollment

### Academic Records
- `GET /api/academic-records` - List records (with filters)
- `POST /api/academic-records` - Create record
- `GET /api/academic-records/:id` - Get record details
- `PUT /api/academic-records/:id` - Update record
- `DELETE /api/academic-records/:id` - Delete record

### Risk Assessments
- `GET /api/risk-assessments` - List assessments
- `POST /api/risk-assessments` - Create assessment
- `GET /api/risk-assessments/:id` - Get latest assessment

### Alerts
- `GET /api/alerts` - List alerts
- `GET /api/alerts/:id` - Get active alerts
- `PUT /api/alerts/:id` - Mark as read or dismiss

### Reports
- `GET /api/reports` - List user reports
- `GET /api/reports/:id` - Get report details
- `POST /api/reports/cohort` - Generate cohort report
- `POST /api/reports/discipline` - Generate discipline report
- `POST /api/reports/individual` - Generate individual report
- `POST /api/reports/risk-analysis` - Generate risk analysis report

## Risk Assessment Algorithm

The RiskEngine module implements predictive risk assessment using:

**Risk Levels**: low, medium, high, critical

**Thresholds**:
- Low grade threshold: 6.0
- Critical grade threshold: 4.0
- Low attendance threshold: 75%
- Critical attendance threshold: 50%

**Probabilities** (0-100%):
- Dropout probability: Based on grade and attendance deficits
- Failure probability: Based on grade performance
- Risk level: Determined by combined metrics

## Database Schema

All tables include:
- UUID primary keys
- UTC timestamps (created_at, updated_at)
- Proper indexing for query performance
- Foreign key constraints with cascade/nullify rules

Key relationships:
- User (1) -> (N) TeacherDiscipline
- Student (1) -> (N) Enrollment, AcademicRecord, RiskAssessment
- Discipline (1) -> (N) Enrollment, TeacherDiscipline, AcademicRecord
- RiskAssessment (1) -> (N) Alert
- User (1) -> (N) Report

## Running Tests

```bash
mix test
```

## Development Notes

- All contexts are isolated in separate modules for maintainability
- Services handle complex business logic
- Controllers focus on HTTP handling and validation
- Ecto changesets ensure data integrity
- Enums used for status and role fields
- Decimal used for grade and probability calculations

## Future Enhancements

- Authentication and authorization
- Real-time alerts via WebSockets
- ML-based prediction models
- Integration with external academic systems
- Email notifications
- Export to CSV/PDF formats
