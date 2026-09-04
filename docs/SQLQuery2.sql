CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    Role VARCHAR(20) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),

    CONSTRAINT CK_Users_Role
    CHECK (Role IN ('Organizer', 'Participant'))
);
GO
CREATE TABLE Organizers (
    OrganizerID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    OrganizationName VARCHAR(150) NOT NULL,
    ContactNumber VARCHAR(20),

    CONSTRAINT FK_Organizers_Users
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO
CREATE TABLE Participants (
    ParticipantID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    DateOfBirth DATE,
    EmergencyContact VARCHAR(100),
    EmergencyPhone VARCHAR(20),

    CONSTRAINT FK_Participants_Users
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO
CREATE TABLE Categories (
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
CREATE TABLE Events (
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
    CHECK (EventType IN ('Running', 'Walking', 'Cycling'))
);
GO
CREATE TABLE Categories (
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
CREATE TABLE EventEnrollments (
    EnrollmentID INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID INT NOT NULL,
    CategoryID INT NOT NULL,
    RegistrationDate DATETIME DEFAULT GETDATE(),
    Status VARCHAR(30) NOT NULL DEFAULT 'Registered',
    RaceNumber VARCHAR(20),

    CONSTRAINT FK_Enrollments_Participants
    FOREIGN KEY (ParticipantID)
    REFERENCES Participants(ParticipantID),

    CONSTRAINT FK_Enrollments_Categories
    FOREIGN KEY (CategoryID)
    REFERENCES Categories(CategoryID),

    CONSTRAINT UQ_Participant_Category
    UNIQUE (ParticipantID, CategoryID)
);
GO
CREATE TABLE Results (
    ResultID INT IDENTITY(1,1) PRIMARY KEY,
    EnrollmentID INT NOT NULL UNIQUE,
    FinishTime TIME,
    Position INT,
    ResultStatus VARCHAR(30) NOT NULL,

    CONSTRAINT FK_Results_Enrollments
    FOREIGN KEY (EnrollmentID)
    REFERENCES EventEnrollments(EnrollmentID),

    CONSTRAINT CK_Results_Position
    CHECK (Position IS NULL OR Position > 0)
);
GO
CREATE TABLE Routes (
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
CREATE TABLE WeatherInformation (
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
    CHECK (RainProbability BETWEEN 0 AND 100)
);
GO
INSERT INTO Users
(FullName, Email, PasswordHash, Role)
VALUES
('Thabo Nkosi', 'thabo@raceday.co.za', 'hashed_password_1', 'Organizer'),
('Lerato Mokoena', 'lerato@example.co.za', 'hashed_password_2', 'Participant'),
('Sipho Dlamini', 'sipho@example.co.za', 'hashed_password_3', 'Participant'),
('Naledi Molefe', 'naledi@example.co.za', 'hashed_password_4', 'Participant');
GO
INSERT INTO Organizers
(UserID, OrganizationName, ContactNumber)
VALUES
(1, 'RaceDay Events SA', '0125550101');
GO
INSERT INTO Participants
(UserID, DateOfBirth, EmergencyContact, EmergencyPhone)
VALUES
(2, '2000-05-14', 'Nomsa Mokoena', '0825550102'),
(3, '1998-11-22', 'Ayanda Dlamini', '0835550103'),
(4, '2001-07-09', 'Kagiso Molefe', '0845550104');
GO
INSERT INTO Events
(OrganizerID, EventName, EventType, EventDate, Location, Description, Status)
VALUES
(1, 'Pretoria City Run', 'Running', '2026-10-10 07:00:00',
 'Pretoria, Gauteng',
 'A road running event through Pretoria.',
 'Upcoming'),

(1, 'Johannesburg Community Walk', 'Walking', '2026-11-07 08:00:00',
 'Johannesburg, Gauteng',
 'A community walking event suitable for different fitness levels.',
 'Upcoming'),

(1, 'Cape Town Cycle Challenge', 'Cycling', '2026-12-05 06:30:00',
 'Cape Town, Western Cape',
 'A cycling event featuring scenic Cape Town routes.',
 'Upcoming');
GO
INSERT INTO Categories
(EventID, CategoryName, DistanceKm, MaxParticipants, EntryFee)
VALUES
(1, '5 KM Run', 5.00, 500, 150.00),
(1, '10 KM Run', 10.00, 400, 220.00),
(1, '21 KM Half Marathon', 21.10, 300, 350.00),

(2, '5 KM Walk', 5.00, 400, 100.00),
(2, '10 KM Walk', 10.00, 250, 160.00),

(3, '40 KM Cycle', 40.00, 300, 300.00),
(3, '80 KM Cycle', 80.00, 250, 450.00);
GO
INSERT INTO Results
(EnrollmentID, FinishTime, Position, ResultStatus)
VALUES
(1, '00:28:45', 12, 'Finished');
INSERT INTO Routes
(EventID, RouteName, DistanceKm, StartPoint, EndPoint, MapUrl)
VALUES
(1, 'Pretoria 5 KM Route', 5.00,
 'Union Buildings', 'Union Buildings',
 'https://example.com/routes/pretoria5'),

(1, 'Pretoria 10 KM Route', 10.00,
 'Union Buildings', 'Union Buildings',
 'https://example.com/routes/pretoria10'),

(2, 'Johannesburg Walk Route', 5.00,
 'Zoo Lake', 'Zoo Lake',
 'https://example.com/routes/joburgwalk'),

(3, 'Cape Town Cycle Route', 40.00,
 'Cape Town Stadium', 'Cape Town Stadium',
 'https://example.com/routes/capetowncycle');
GO
INSERT INTO WeatherInformation
(EventID, ForecastDate, Temperature, RainProbability, WindSpeed, Condition)
VALUES
(1, '2026-10-10 06:00:00', 17.50, 20.00, 12.00, 'Partly Cloudy'),
(2, '2026-11-07 07:00:00', 20.00, 30.00, 10.50, 'Cloudy'),
(3, '2026-12-05 06:00:00', 18.00, 10.00, 16.00, 'Clear');
GO
SELECT * FROM Users;
SELECT * FROM Organizers;
SELECT * FROM Participants;
SELECT * FROM Events;
SELECT * FROM Categories;
SELECT * FROM EventEnrollments;
SELECT * FROM Results;
SELECT * FROM Routes;
SELECT * FROM WeatherInformation;
SELECT
    e.EventName,
    e.EventType,
    e.EventDate,
    e.Location,
    c.CategoryName,
    c.DistanceKm,
    c.EntryFee
FROM Events e
INNER JOIN Categories c
    ON e.EventID = c.EventID;
    SELECT
    u.FullName,
    e.EventName,
    c.CategoryName,
    ee.RaceNumber,
    ee.Status
FROM EventEnrollments ee
INNER JOIN Participants p
    ON ee.ParticipantID = p.ParticipantID
INNER JOIN Users u
    ON p.UserID = u.UserID
INNER JOIN Categories c
    ON ee.CategoryID = c.CategoryID
INNER JOIN Events e
    ON c.EventID = e.EventID;
    -- Historical completed event
INSERT INTO Events
(OrganizerID, EventName, EventType, EventDate, Location, Description, Status)
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
INSERT INTO Categories
(EventID, CategoryName, DistanceKm, MaxParticipants, EntryFee)
VALUES
(
    4,
    '10 KM Run',
    10.00,
    300,
    200.00
);
GO
INSERT INTO EventEnrollments
(ParticipantID, CategoryID, RegistrationDate, Status, RaceNumber)
VALUES
(1, 8, '2026-05-10', 'Completed', 'PW101'),
(2, 8, '2026-05-12', 'Completed', 'PW102'),
(3, 8, '2026-05-14', 'Completed', 'PW103');
GO
INSERT INTO Results
(EnrollmentID, FinishTime, Position, ResultStatus)
VALUES
(6, '00:49:32', 18, 'Finished'),
(7, '00:54:10', 31, 'Finished'),
(8, '01:02:45', 57, 'Finished');
GO
SELECT
    u.FullName,
    e.EventName,
    c.CategoryName,
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
    ON c.EventID = e.EventID;
    SELECT * FROM Events;
SELECT * FROM Categories;
SELECT * FROM EventEnrollments;
-- Add historical completed event
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
SELECT * FROM Events;