CREATE DATABASE CafeterialMealManagement;
GO
USE CafeterialMealManagement;
GO

CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    user_type VARCHAR(10) CHECK (user_type IN ('Staff', 'Student')) NOT NULL
);

CREATE TABLE Staff (
    staff_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    gender VARCHAR(6) CHECK (gender IN ('Male', 'Female')) NOT NULL,
    role VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    contact_info VARCHAR(150),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Student (
    student_id VARCHAR(11) PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    gender VARCHAR(6) CHECK (gender IN ('Male', 'Female')) NOT NULL,
    qr_code VARCHAR(100) UNIQUE NOT NULL,
    department VARCHAR(50) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Meal_Card (
    qr_code VARCHAR(100) PRIMARY KEY,
    meal_card_number CHAR(4) NOT NULL,
    FOREIGN KEY (qr_code) REFERENCES Student(qr_code) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Menu (
    menu_id INT IDENTITY(1,1) PRIMARY KEY,
    meal_type VARCHAR(10) CHECK (meal_type IN ('Breakfast', 'Lunch', 'Dinner')) NOT NULL,
    dish_name VARCHAR(100) NOT NULL,
    fasting Bit NOT NULL
);

CREATE TABLE Menu_Ingredients (
    menu_id INT NOT NULL,
    ingredient VARCHAR(100) NOT NULL,
    PRIMARY KEY (menu_id, ingredient),
    FOREIGN KEY (menu_id) REFERENCES Menu(menu_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Menu_Allergens (
    menu_id INT NOT NULL,
    allergen VARCHAR(100) NOT NULL,
    PRIMARY KEY (menu_id, allergen),
    FOREIGN KEY (menu_id) REFERENCES Menu(menu_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Allergy (
    allergy_id INT IDENTITY(1,1) PRIMARY KEY,
    student_id VARCHAR(11) NOT NULL,
    allergy_type VARCHAR(100) NOT NULL,
    FOREIGN KEY (student_id) REFERENCES Student(student_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Attendance (
    attendance_id INT IDENTITY(1,1) PRIMARY KEY,
    student_id VARCHAR(11) NOT NULL,
    meal_type VARCHAR(10) CHECK (meal_type IN ('Breakfast', 'Lunch', 'Dinner')) NOT NULL,
    timestamp DATETIME NOT NULL,
    FOREIGN KEY (student_id) REFERENCES Student(student_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Meal_Log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    menu_id INT NOT NULL,
    attendance_id INT NOT NULL,
    FOREIGN KEY (menu_id) REFERENCES Menu(menu_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (attendance_id) REFERENCES Attendance(attendance_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- View to list all students with their meal card information
CREATE VIEW vw_StudentMealCard AS
SELECT 
    s.student_id,
    s.name AS student_name,
    s.department,
    m.qr_code,
    m.meal_card_number
FROM 
    Student s
LEFT JOIN 
    Meal_Card m
ON 
    s.qr_code = m.qr_code;

-- View to list all menu items with their ingredients and allergens
CREATE VIEW vw_MenuDetails AS
SELECT 
    m.menu_id,
    m.meal_type,
    m.dish_name,
    m.fasting,
    mi.ingredient,
    ma.allergen
FROM 
    Menu m
LEFT JOIN 
    Menu_Ingredients mi ON m.menu_id = mi.menu_id
LEFT JOIN 
    Menu_Allergens ma ON m.menu_id = ma.menu_id;

-- View to get student allergies and matching menu allergens
CREATE VIEW vw_StudentAllergies AS
SELECT 
    s.student_id,
    s.name AS student_name,
    s.department,
    a.allergy_type,
    ma.allergen,
    CASE 
        WHEN a.allergy_type = ma.allergen THEN 'Match'
        ELSE 'No Match'
    END AS allergy_match_status
FROM 
    Allergy a
INNER JOIN 
    Student s ON a.student_id = s.student_id
LEFT JOIN 
    Menu_Allergens ma ON a.allergy_type = ma.allergen;

-- View to list attendance with meal log details
CREATE VIEW vw_AttendanceLog AS
SELECT 
    a.attendance_id,
    a.student_id,
    s.name AS student_name,
    a.meal_type,
    a.timestamp,
    ml.menu_id,
    m.dish_name
FROM 
    Attendance a
INNER JOIN 
    Student s ON a.student_id = s.student_id
LEFT JOIN 
    Meal_Log ml ON a.attendance_id = ml.attendance_id
LEFT JOIN 
    Menu m ON ml.menu_id = m.menu_id;


-- Index for faster lookup of students by their QR code
CREATE INDEX idx_StudentQRCode ON Student (qr_code);

-- Index for faster retrieval of menu items based on meal type
CREATE INDEX idx_MenuMealType ON Menu (meal_type);

-- Index for faster join operations on Student ID in the Allergy table
CREATE INDEX idx_AllergyStudentID ON Allergy (student_id);

-- Index for faster retrieval of attendance records by student and timestamp
CREATE INDEX idx_AttendanceStudentTime ON Attendance (student_id, timestamp);

-- Index for meal card lookup by QR code
CREATE INDEX idx_MealCardQRCode ON Meal_Card (qr_code);

-- Insert users
INSERT INTO Users (name, user_type)
VALUES 
    ('Abebe Kebede', 'Student'),
    ('Tigist Alemu', 'Student'),
    ('Dereje Mekonnen', 'Staff'),
    ('Alemnesh Getachew', 'Staff');

-- Insert students
INSERT INTO Student (user_id, student_id, name, gender, qr_code, department)
VALUES 
    (1, 'ugr/0001/16', 'Abebe Kebede', 'Male', 'QR001', 'Information Systems'),
    (2, 'ugr/0002/16', 'Tigist Alemu', 'Female', 'QR002', 'Accounting');

-- Insert staff members
INSERT INTO Staff (user_id, name, gender, role, department, contact_info)
VALUES 
    (3, 'Dereje Mekonnen', 'Male', 'Cafeteria Manager', 'Cafeteria', 'dereje.mekonnen@university.et'),
    (4, 'Alemnesh Getachew', 'Female', 'Cook', 'Cafeteria', 'alemnesh.getachew@university.et');

	-- Link students with their meal cards
INSERT INTO Meal_Card (qr_code, meal_card_number)
VALUES 
    ('QR001', 'MC01'),
    ('QR002', 'MC02');

	-- Add some meals to the menu
INSERT INTO Menu (meal_type, dish_name, fasting)
VALUES 
    ('Breakfast', 'Firfir with Injera', 0),
    ('Lunch', 'Shiro and Rice', 1),
    ('Dinner', 'Minchet', 0);
	-- Add ingredients for meals
INSERT INTO Menu_Ingredients (menu_id, ingredient)
VALUES 
    (1, 'Injera'),
    (1, 'Berbere'),
    (2, 'Rice'),
    (2, 'Shiro'),
    (3, 'Meat'),
    (3, 'Injera');

	-- Add allergens for meals
INSERT INTO Menu_Allergens (menu_id, allergen)
VALUES 
    (1, 'Gluten'),
    (2, 'Legumes'),
    (3, 'Meat');

	-- Add student allergies
INSERT INTO Allergy (student_id, allergy_type)
VALUES 
    ('UGR/0001/16', 'Gluten'),
    ('UGR/0002/16', 'Legumes');

-- Log student attendance
INSERT INTO Attendance (student_id, meal_type, timestamp)
VALUES 
    ('UGR/0001/16', 'Breakfast', GETDATE()),
    ('UGR/0002/16', 'Lunch', GETDATE());

	-- Link attendance with menu
INSERT INTO Meal_Log (menu_id, attendance_id)
VALUES 
    (1, 1), 
    (2, 2); 

	
	--testing the queries
SELECT * FROM vw_StudentMealCard;
SELECT * FROM vw_MenuDetails;
SELECT * FROM vw_StudentAllergies;
SELECT * FROM vw_AttendanceLog;

