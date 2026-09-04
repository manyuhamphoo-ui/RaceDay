# RaceDay

## System Description

RaceDay is a web-based event management system designed for the South African running, walking and cycling community.

The system provides a central platform where Event Organizers can create and manage sporting events, event categories, routes and participant results. Participants can browse upcoming events, enrol in event categories, view route and weather information, and track their personal race performance history.

The aim of RaceDay is to replace disconnected and paper-based event management processes with a structured digital platform that improves event administration and provides participants with easier access to race information.

## User Roles

RaceDay has two main user roles: Event Organizer and Participant.

### Event Organizer

The Event Organizer is responsible for creating and managing events on the RaceDay platform.

An Organizer can:

- Create running, walking and cycling events.
- Update event information.
- Create and manage event categories.
- Add route information.
- Manage event enrolments.
- Record participant race results.
- Update or correct race results.

### Participant

The Participant uses RaceDay to discover and participate in sporting events.

A Participant can:

- Create and manage a RaceDay account.
- Browse upcoming events.
- View event categories.
- Enrol in an event category.
- View their event registrations.
- View event route information.
- View race-day weather information.
- View their race results and performance history.

## Project Documentation

The planning documentation for Part 1 is stored inside the `/docs` folder.

The folder contains:

- `ERD.png` - RaceDay Entity Relationship Diagram.
- `RaceDay_API_Endpoint_Plan.pdf` - RESTful API endpoint plan.
- `RaceDay_Database.sql` - SQL Server database creation and sample data script.

## Database

The RaceDay database was designed for Microsoft SQL Server and contains the following main entities:

- Users
- Organizers
- Participants
- Events
- Categories
- EventEnrollments
- Results
- Routes
- WeatherInformation

The database uses primary keys, foreign keys, unique constraints, check constraints and realistic sample data to maintain data integrity.

## CI/CD

### Successful CI/CD Validation

The GitHub Actions workflow successfully validates that the required RaceDay project documentation is present in the repository.

![RaceDay CI/CD Success](images/git%20success.png)
GitHub Actions is used to validate the RaceDay repository structure and confirm that the required Part 1 documentation is available.

### CI/CD Screenshot

A screenshot of the successful GitHub Actions workflow will be added here after the workflow has been configured and successfully executed.

## Video Demonstration

An unlisted YouTube demonstration will provide a walkthrough of the RaceDay planning documents, ERD design decisions, API endpoint plan and SQL Server database script.
## Database Design Decisions

The RaceDay database separates general user account information from role-specific profile information. The `Users` table stores shared account details such as name, email, password hash and role, while the `Organizers` and `Participants` tables store information specific to each role.

The `EventEnrollments` table is used as a junction table between Participants and Categories. This resolves the many-to-many relationship because one Participant can enter multiple event categories, while one category can contain many Participants.

Results are linked to EventEnrollments so that each result belongs to a specific Participant registration for a specific event category.

## API Design Decisions

The RaceDay API follows a RESTful structure and uses HTTP methods according to the type of operation being performed.

Public GET endpoints are used for information that should be available without logging in, such as events, event categories, routes and weather information.

Protected endpoints require authentication. Participant endpoints allow users to manage enrolments and view personal results, while Organizer endpoints allow authorized users to create and manage events, categories, routes and results.

HTTP response codes such as 200, 201, 204, 400, 401, 403, 404 and 409 are used to clearly communicate the outcome of each request.

**YouTube Video:** To be added after recording.
## 🎥 Video Demonstration

A complete demonstration of the RaceDay system, including the database, API endpoints, and testing, can be viewed below:

[▶ Watch the RaceDay Demonstration on YouTube](https://youtu.be/3uh-G-Rwejg )
