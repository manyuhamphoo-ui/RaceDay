/* ============================================================
   RaceDay Database Script
   Part 1 - Section C: SQL Database Script

   Student Name: [Enter Your Name]
   Student Number: [Enter Your Student Number]

   Description:
   This script creates and populates the SQL Server database
   for the RaceDay event management system.
   ============================================================ */


-- ============================================================
-- 1. CREATE DATABASE
-- ============================================================

USE master;
GO

IF DB_ID('RaceDayDB') IS NOT NULL
BEGIN
    ALTER DATABASE RaceDayDB
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE RaceDayDB;
END;
GO

CREATE DATABASE RaceDayDB;
GO

USE RaceDayDB;
GO


-- ============================================================
-- 2. CREATE USERS TABLE
-- ============================================================

CREATE TABLE Users
(
    UserID INT IDENTITY(1,1) PRIMARY KEY,

    FullName VARCHAR(100) NOT NULL,

    Email VARCHAR(150) NOT NULL UNIQUE,

    PasswordHash VARCHAR(255) NOT NULL,

    Role VARCHAR(20) NOT NULL,

    CreatedAt DATETIME NOT NULL
        DEFAULT GETDATE(),

    CONSTRAINT CK_Users_Role
        CHECK (Role IN ('Organizer', 'Participant'))
);
GO


-- ============================================================
-- 3. CREATE ORGANIZERS TABLE
-- ============================================================

CREATE TABLE Organizers
(
    OrganizerID INT IDENTITY(1,1) PRIMARY KEY,

    UserID INT NOT NULL UNIQUE,

    OrganizationName VARCHAR(150) NOT NULL,

    ContactNumber VARCHAR(20),

    CONSTRAINT FK_Organizers_Users
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID)
);
GO


-- ============================================================
-- 4. CREATE PARTICIPANTS TABLE
-- ============================================================

CREATE TABLE Participants
(
    ParticipantID INT IDENTITY(1,1) PRIMARY KEY,

    UserID INT NOT NULL UNIQUE,

    DateOfBirth DATE,

    EmergencyContact VARCHAR(100),

    EmergencyPhone VARCHAR(20),

    CONSTRAINT FK_Participants_Users
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID)
);
GO


-- ============================================================
-- 5. CREATE EVENTS TABLE
-- ============================================================

CREATE TABLE Events
(
    EventID INT IDENTITY(1,1) PRIMARY KEY,

    OrganizerID INT NOT NULL,

    EventName VARCHAR(150) NOT NULL,

    EventType VARCHAR(30) NOT NULL,

    EventDate DATETIME NOT NULL,

    Location VARCHAR(200) NOT NULL,

    Description VARCHAR(500),

    Status VARCHAR(30) NOT NULL,

    CONSTRAINT FK_Events_Organizers
        FOREIGN KEY (OrganizerID)
        REFERENCES Organizers(OrganizerID),

    CONSTRAINT CK_Events_Type
        CHECK
        (
            EventType IN
            ('Running', 'Walking', 'Cycling')
        ),

    CONSTRAINT CK_Events_Status
        CHECK
        (
            Status IN
            ('Upcoming', 'Completed', 'Cancelled')
        )
);
GO


-- ============================================================
-- 6. CREATE CATEGORIES TABLE
-- ============================================================

CREATE TABLE Categories
(
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,

    EventID INT NOT NULL,

    CategoryName VARCHAR(100) NOT NULL,

    DistanceKm DECIMAL(6,2) NOT NULL,

    MaxParticipants INT NOT NULL,

    EntryFee DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_Categories_Events
        FOREIGN KEY (EventID)
        REFERENCES Events(EventID),

    CONSTRAINT CK_Categories_Distance
        CHECK (DistanceKm > 0),

    CONSTRAINT CK_Categories_MaxParticipants
        CHECK (MaxParticipants > 0),

    CONSTRAINT CK_Categories_EntryFee
        CHECK (EntryFee >= 0)
);
GO


-- ============================================================
-- 7. CREATE EVENT ENROLMENTS TABLE
-- ============================================================

CREATE TABLE EventEnrollments
(
    EnrollmentID INT IDENTITY(1,1) PRIMARY KEY,

    ParticipantID INT NOT NULL,

    CategoryID INT NOT NULL,

    RegistrationDate DATETIME NOT NULL
        DEFAULT GETDATE(),

    Status VARCHAR(30) NOT NULL
        DEFAULT 'Registered',

    RaceNumber VARCHAR(20),

    CONSTRAINT FK_Enrollments_Participants
        FOREIGN KEY (ParticipantID)
        REFERENCES Participants(ParticipantID),

    CONSTRAINT FK_Enrollments_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID),

    CONSTRAINT UQ_Participant_Category
        UNIQUE (ParticipantID, CategoryID),

    CONSTRAINT UQ_Enrollment_RaceNumber
        UNIQUE (RaceNumber),

    CONSTRAINT CK_Enrollment_Status
        CHECK
        (
            Status IN
            ('Registered', 'Completed', 'Cancelled')
        )
);
GO


-- ============================================================
-- 8. CREATE RESULTS TABLE
-- ============================================================

CREATE TABLE Results
(
    ResultID INT IDENTITY(1,1) PRIMARY KEY,

    EnrollmentID INT NOT NULL UNIQUE,

    FinishTime TIME,

    Position INT,

    ResultStatus VARCHAR(30) NOT NULL,

    CONSTRAINT FK_Results_Enrollments
        FOREIGN KEY (EnrollmentID)
        REFERENCES EventEnrollments(EnrollmentID),

    CONSTRAINT CK_Results_Position
        CHECK
        (
            Position IS NULL
            OR Position > 0
        ),

    CONSTRAINT CK_Result_Status
        CHECK
        (
            ResultStatus IN
            ('Finished', 'Did Not Finish', 'Disqualified')
        )
);
GO


-- ============================================================
-- 9. CREATE ROUTES TABLE
-- ============================================================

CREATE TABLE Routes
(
    RouteID INT IDENTITY(1,1) PRIMARY KEY,

    EventID INT NOT NULL,

    RouteName VARCHAR(150) NOT NULL,

    DistanceKm DECIMAL(6,2) NOT NULL,

    StartPoint VARCHAR(200) NOT NULL,

    EndPoint VARCHAR(200) NOT NULL,

    MapUrl VARCHAR(500),

    CONSTRAINT FK_Routes_Events
        FOREIGN KEY (EventID)
        REFERENCES Events(EventID),

    CONSTRAINT CK_Routes_Distance
        CHECK (DistanceKm > 0)
);
GO


-- ============================================================
-- 10. CREATE WEATHER INFORMATION TABLE
-- ============================================================

CREATE TABLE WeatherInformation
(
    WeatherID INT IDENTITY(1,1) PRIMARY KEY,

    EventID INT NOT NULL,

    ForecastDate DATETIME NOT NULL,

    Temperature DECIMAL(5,2),

    RainProbability DECIMAL(5,2),

    WindSpeed DECIMAL(6,2),

    Condition VARCHAR(100),

    CONSTRAINT FK_Weather_Events
        FOREIGN KEY (EventID)
        REFERENCES Events(EventID),

    CONSTRAINT CK_Weather_RainProbability
        CHECK
        (
            RainProbability IS NULL
            OR RainProbability BETWEEN 0 AND 100
        ),

    CONSTRAINT CK_Weather_WindSpeed
        CHECK
        (
            WindSpeed IS NULL
            OR WindSpeed >= 0
        )
);
GO


-- ============================================================
-- 11. INSERT SAMPLE USERS
-- ============================================================

INSERT INTO Users
(
    FullName,
    Email,
    PasswordHash,
    Role
)
VALUES
(
    'Thabo Nkosi',
    'thabo@raceday.co.za',
    'hashed_password_1',
    'Organizer'
),
(
    'Lerato Mokoena',
    'lerato@example.co.za',
    'hashed_password_2',
    'Participant'
),
(
    'Sipho Dlamini',
    'sipho@example.co.za',
    'hashed_password_3',
    'Participant'
),
(
    'Naledi Molefe',
    'naledi@example.co.za',
    'hashed_password_4',
    'Participant'
);
GO


-- ============================================================
-- 12. INSERT SAMPLE ORGANIZER
-- ============================================================

INSERT INTO Organizers
(
    UserID,
    OrganizationName,
    ContactNumber
)
VALUES
(
    1,
    'RaceDay Events SA',
    '0125550101'
);
GO


-- ============================================================
-- 13. INSERT SAMPLE PARTICIPANTS
-- ============================================================

INSERT INTO Participants
(
    UserID,
    DateOfBirth,
    EmergencyContact,
    EmergencyPhone
)
VALUES
(
    2,
    '2000-05-14',
    'Nomsa Mokoena',
    '0825550102'
),
(
    3,
    '1998-11-22',
    'Ayanda Dlamini',
    '0835550103'
),
(
    4,
    '2001-07-09',
    'Kagiso Molefe',
    '0845550104'
);
GO


-- ============================================================
-- 14. INSERT SAMPLE EVENTS
-- ============================================================

-- Upcoming running event
INSERT INTO Events
(
    OrganizerID,
    EventName,
    EventType,
    EventDate,
    Location,
    Description,
    Status
)
VALUES
(
    1,
    'Pretoria City Run',
    'Running',
    '2026-10-10 07:00:00',
    'Pretoria, Gauteng',
    'A road running event through Pretoria.',
    'Upcoming'
);


-- Upcoming walking event
INSERT INTO Events
(
    OrganizerID,
    EventName,
    EventType,
    EventDate,
    Location,
    Description,
    Status
)
VALUES
(
    1,
    'Johannesburg Community Walk',
    'Walking',
    '2026-11-07 08:00:00',
    'Johannesburg, Gauteng',
    'A community walking event suitable for different fitness levels.',
    'Upcoming'
);


-- Upcoming cycling event
INSERT INTO Events
(
    OrganizerID,
    EventName,
    EventType,
    EventDate,
    Location,
    Description,
    Status
)
VALUES
(
    1,
    'Cape Town Cycle Challenge',
    'Cycling',
    '2026-12-05 06:30:00',
    'Cape Town, Western Cape',
    'A cycling event featuring scenic Cape Town routes.',
    'Upcoming'
);


-- Historical completed event
INSERT INTO Events
(
    OrganizerID,
    EventName,
    EventType,
    EventDate,
    Location,
    Description,
    Status
)
VALUES
(
    1,
    'Pretoria Winter 10K',
    'Running',
    '2026-06-20 07:00:00',
    'Pretoria, Gauteng',
    'A completed 10 kilometre road race held in Pretoria.',
    'Completed'
);
GO


-- ============================================================
-- 15. INSERT EVENT CATEGORIES
-- ============================================================

-- Pretoria City Run categories
INSERT INTO Categories
(
    EventID,
    CategoryName,
    DistanceKm,
    MaxParticipants,
    EntryFee
)
VALUES
(1, '5 KM Run', 5.00, 500, 150.00),
(1, '10 KM Run', 10.00, 400, 220.00),
(1, '21 KM Half Marathon', 21.10, 300, 350.00);


-- Johannesburg Community Walk categories
INSERT INTO Categories
(
    EventID,
    CategoryName,
    DistanceKm,
    MaxParticipants,
    EntryFee
)
VALUES
(2, '5 KM Walk', 5.00, 400, 100.00),
(2, '10 KM Walk', 10.00, 250, 160.00);


-- Cape Town Cycle Challenge categories
INSERT INTO Categories
(
    EventID,
    CategoryName,
    DistanceKm,
    MaxParticipants,
    EntryFee
)
VALUES
(3, '40 KM Cycle', 40.00, 300, 300.00),
(3, '80 KM Cycle', 80.00, 250, 450.00);


-- Historical Pretoria Winter 10K category
INSERT INTO Categories
(
    EventID,
    CategoryName,
    DistanceKm,
    MaxParticipants,
    EntryFee
)
VALUES
(
    4,
    '10 KM Run',
    10.00,
    300,
    200.00
);
GO


-- ============================================================
-- 16. INSERT UPCOMING EVENT ENROLMENTS
-- ============================================================

INSERT INTO EventEnrollments
(
    ParticipantID,
    CategoryID,
    RegistrationDate,
    Status,
    RaceNumber
)
VALUES
(
    1,
    1,
    '2026-08-15',
    'Registered',
    'RD001'
),
(
    2,
    2,
    '2026-08-16',
    'Registered',
    'RD002'
),
(
    3,
    3,
    '2026-08-17',
    'Registered',
    'RD003'
),
(
    1,
    4,
    '2026-08-18',
    'Registered',
    'JW001'
),
(
    2,
    6,
    '2026-08-19',
    'Registered',
    'CT001'
);
GO


-- ============================================================
-- 17. INSERT HISTORICAL EVENT ENROLMENTS
-- ============================================================

INSERT INTO EventEnrollments
(
    ParticipantID,
    CategoryID,
    RegistrationDate,
    Status,
    RaceNumber
)
VALUES
(
    1,
    8,
    '2026-05-10',
    'Completed',
    'PW101'
),
(
    2,
    8,
    '2026-05-12',
    'Completed',
    'PW102'
),
(
    3,
    8,
    '2026-05-14',
    'Completed',
    'PW103'
);
GO


-- ============================================================
-- 18. INSERT HISTORICAL RESULTS
-- ============================================================

INSERT INTO Results
(
    EnrollmentID,
    FinishTime,
    Position,
    ResultStatus
)
VALUES
(
    6,
    '00:49:32',
    18,
    'Finished'
),
(
    7,
    '00:54:10',
    31,
    'Finished'
),
(
    8,
    '01:02:45',
    57,
    'Finished'
);
GO


-- ============================================================
-- 19. INSERT SAMPLE ROUTES
-- ============================================================

INSERT INTO Routes
(
    EventID,
    RouteName,
    DistanceKm,
    StartPoint,
    EndPoint,
    MapUrl
)
VALUES
(
    1,
    'Pretoria 5 KM Route',
    5.00,
    'Union Buildings',
    'Union Buildings',
    'https://example.com/routes/pretoria5'
),
(
    1,
    'Pretoria 10 KM Route',
    10.00,
    'Union Buildings',
    'Union Buildings',
    'https://example.com/routes/pretoria10'
),
(
    2,
    'Johannesburg Walk Route',
    5.00,
    'Zoo Lake',
    'Zoo Lake',
    'https://example.com/routes/joburgwalk'
),
(
    3,
    'Cape Town Cycle Route',
    40.00,
    'Cape Town Stadium',
    'Cape Town Stadium',
    'https://example.com/routes/capetowncycle'
),
(
    4,
    'Pretoria Winter 10K Route',
    10.00,
    'Union Buildings',
    'Union Buildings',
    'https://example.com/routes/pretoriawinter10k'
);
GO


-- ============================================================
-- 20. INSERT SAMPLE WEATHER INFORMATION
-- ============================================================

INSERT INTO WeatherInformation
(
    EventID,
    ForecastDate,
    Temperature,
    RainProbability,
    WindSpeed,
    Condition
)
VALUES
(
    1,
    '2026-10-10 06:00:00',
    17.50,
    20.00,
    12.00,
    'Partly Cloudy'
),
(
    2,
    '2026-11-07 07:00:00',
    20.00,
    30.00,
    10.50,
    'Cloudy'
),
(
    3,
    '2026-12-05 06:00:00',
    18.00,
    10.00,
    16.00,
    'Clear'
),
(
    4,
    '2026-06-20 06:00:00',
    11.00,
    5.00,
    8.00,
    'Clear'
);
GO


-- ============================================================
-- 21. VERIFY ALL TABLE DATA
-- ============================================================

SELECT * FROM Users;
SELECT * FROM Organizers;
SELECT * FROM Participants;
SELECT * FROM Events;
SELECT * FROM Categories;
SELECT * FROM EventEnrollments;
SELECT * FROM Results;
SELECT * FROM Routes;
SELECT * FROM WeatherInformation;
GO


-- ============================================================
-- 22. DISPLAY EVENTS AND THEIR CATEGORIES
-- ============================================================

SELECT
    e.EventID,
    e.EventName,
    e.EventType,
    e.EventDate,
    e.Location,
    e.Status,
    c.CategoryName,
    c.DistanceKm,
    c.MaxParticipants,
    c.EntryFee
FROM Events e
INNER JOIN Categories c
    ON e.EventID = c.EventID
ORDER BY e.EventDate;
GO


-- ============================================================
-- 23. DISPLAY PARTICIPANT EVENT ENROLMENTS
-- ============================================================

SELECT
    u.FullName AS ParticipantName,
    e.EventName,
    c.CategoryName,
    c.DistanceKm,
    ee.RegistrationDate,
    ee.RaceNumber,
    ee.Status AS EnrollmentStatus
FROM EventEnrollments ee
INNER JOIN Participants p
    ON ee.ParticipantID = p.ParticipantID
INNER JOIN Users u
    ON p.UserID = u.UserID
INNER JOIN Categories c
    ON ee.CategoryID = c.CategoryID
INNER JOIN Events e
    ON c.EventID = e.EventID
ORDER BY u.FullName;
GO


-- ============================================================
-- 24. DISPLAY PARTICIPANT PERFORMANCE HISTORY
-- ============================================================

SELECT
    u.FullName AS ParticipantName,
    e.EventName,
    e.EventDate,
    c.CategoryName,
    c.DistanceKm,
    ee.RaceNumber,
    r.FinishTime,
    r.Position,
    r.ResultStatus
FROM Results r
INNER JOIN EventEnrollments ee
    ON r.EnrollmentID = ee.EnrollmentID
INNER JOIN Participants p
    ON ee.ParticipantID = p.ParticipantID
INNER JOIN Users u
    ON p.UserID = u.UserID
INNER JOIN Categories c
    ON ee.CategoryID = c.CategoryID
INNER JOIN Events e
    ON c.EventID = e.EventID
ORDER BY r.Position;
GO


-- ============================================================
-- 25. DISPLAY EVENTS WITH ROUTE INFORMATION
-- ============================================================

SELECT
    e.EventName,
    e.Location,
    r.RouteName,
    r.DistanceKm,
    r.StartPoint,
    r.EndPoint,
    r.MapUrl
FROM Events e
INNER JOIN Routes r
    ON e.EventID = r.EventID
ORDER BY e.EventName;
GO


-- ============================================================
-- 26. DISPLAY EVENTS WITH WEATHER INFORMATION
-- ============================================================

SELECT
    e.EventName,
    e.EventDate,
    e.Location,
    w.ForecastDate,
    w.Temperature,
    w.RainProbability,
    w.WindSpeed,
    w.Condition
FROM Events e
INNER JOIN WeatherInformation w
    ON e.EventID = w.EventID
ORDER BY e.EventDate;
GO


PRINT 'RaceDayDB database created and populated successfully.';
GO