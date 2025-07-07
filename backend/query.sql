CREATE DATABASE library_db;
USE library_db;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'student', 'staff') NOT NULL
);

INSERT INTO users (name, email, password, role) VALUES
('Alice', 'alice@example.com', '$2b$10$YOUR_HASH_HERE', 'student'), -- Replace with bcrypt hash of '12345'
('Bob', 'bob@example.com', '$2b$10$YOUR_HASH_HERE', 'admin');   -- Replace with bcrypt hash of 'password'

CREATE TABLE Employee (
    Employee_ID INT PRIMARY KEY,
    First_name VARCHAR(50),
    Last_name VARCHAR(50),
    Name VARCHAR(100),
    Education VARCHAR(100),
    Hired_Date DATE,
    Address_Line1 VARCHAR(100),
    Address_Line2 VARCHAR(100),
    Address_Line3 VARCHAR(100),
    No_Of_Time_Published_per_year INT
);

CREATE TABLE Publisher (
    Publisher_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Contact_Number VARCHAR(15),
    Address_Line1 VARCHAR(100),
    Address_Line2 VARCHAR(100),
    Address_Line3 VARCHAR(100)
);

CREATE TABLE Member (
    Member_ID INT PRIMARY KEY,
    First_Name VARCHAR(50),
    Last_Name VARCHAR(50),
    Name VARCHAR(100),
    Address_Line1 VARCHAR(100),
    Address_Line2 VARCHAR(100),
    Address_Line3 VARCHAR(100),
    Classification VARCHAR(50)
);

CREATE TABLE Item (
    Item_ID INT PRIMARY KEY,
    Title VARCHAR(200)
);

CREATE TABLE Book (
    Book_ID INT PRIMARY KEY,
    Item_ID INT,
    Author VARCHAR(100),
    Subject VARCHAR(100),
    No_of_Copies_Owned INT,
    No_Of_Copies_Borrowed INT,
    No_of_Copies_Shelf INT,
    FOREIGN KEY (Item_ID) REFERENCES Item(Item_ID)
);

CREATE TABLE DVD (
    Item_ID INT PRIMARY KEY,
    Subject VARCHAR(100),
    Producer VARCHAR(100),
    Subject_Area VARCHAR(100),
    Year_Publication YEAR,
    FOREIGN KEY (Item_ID) REFERENCES Item(Item_ID)
);

CREATE TABLE Journal (
    Item_ID INT PRIMARY KEY,
    Research_Society VARCHAR(100),
    Subject_Number VARCHAR(50),
    FOREIGN KEY (Item_ID) REFERENCES Item(Item_ID)
);

CREATE TABLE Transaction (
    Transaction_ID INT PRIMARY KEY,
    Transaction_Amount DECIMAL(10, 2),
    Employee_ID INT,
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID)
);

CREATE TABLE Lend_Transaction (
    Transaction_ID INT PRIMARY KEY,
    Borrow_Date DATE,
    Return_Date DATE,
    Due_Date DATE,
    FOREIGN KEY (Transaction_ID) REFERENCES Transaction(Transaction_ID)
);

CREATE TABLE Buy_Transaction (
    Transaction_ID INT PRIMARY KEY,
    Order_Receiving_Date DATE,
    Amount DECIMAL(10, 2),
    Order_Date DATE,
    Publisher_ID INT,
    FOREIGN KEY (Transaction_ID) REFERENCES Transaction(Transaction_ID),
    FOREIGN KEY (Publisher_ID) REFERENCES Publisher(Publisher_ID)
);

CREATE TABLE Member_History (
    History_ID INT PRIMARY KEY,
    Member_ID INT,
    Item_ID INT,
    Borrow_Date DATE,
    Due_Date DATE,
    Return_Date DATE,
    Overdue_Charge DECIMAL(10, 2),
    FOREIGN KEY (Member_ID) REFERENCES Member(Member_ID),
    FOREIGN KEY (Item_ID) REFERENCES Item(Item_ID)
);

-- Sample Data
INSERT INTO Employee (Employee_ID, First_name, Last_name, Name, Education, Hired_Date, Address_Line1, Address_Line2, Address_Line3, No_Of_Time_Published_per_year)
VALUES (1, 'John', 'Doe', 'John Doe', 'Masters in Library Science', '2020-06-15', '123 Library St', 'Apt 4B', 'New York, NY', 5);

INSERT INTO Publisher (Publisher_ID, Name, Contact_Number, Address_Line1, Address_Line2, Address_Line3)
VALUES (1, 'ABC Publishing', '9876543210', '456 Book Ave', 'Suite 10', 'Boston, MA');

INSERT INTO Member (Member_ID, First_Name, Last_Name, Name, Address_Line1, Address_Line2, Address_Line3, Classification)
VALUES (1, 'Alice', 'Smith', 'Alice Smith', '789 Reader Rd', 'Unit 22', 'San Francisco, CA', 'Student');

INSERT INTO Item (Item_ID, Title)
VALUES (1, 'Introduction to Algorithms'),
       (2, 'Computer Science DVD'),
       (3, 'AI Research Journal');

INSERT INTO Book (Book_ID, Item_ID, Author, Subject, No_of_Copies_Owned, No_Of_Copies_Borrowed, No_of_Copies_Shelf)
VALUES (1, 1, 'Thomas H. Cormen', 'Computer Science', 10, 3, 7);

INSERT INTO DVD (Item_ID, Subject, Producer, Subject_Area, Year_Publication)
VALUES (2, 'Computer Science', 'Tech Studios', 'Algorithms', 2022);

INSERT INTO Journal (Item_ID, Research_Society, Subject_Number)
VALUES (3, 'AI Research Society', 'AI-2024');

INSERT INTO Transaction (Transaction_ID, Transaction_Amount, Employee_ID)
VALUES (1, 500.00, 1),
       (2, 1200.00, 1);

INSERT INTO Lend_Transaction (Transaction_ID, Borrow_Date, Return_Date, Due_Date)
VALUES (1, '2025-03-01', NULL, '2025-03-15');

INSERT INTO Buy_Transaction (Transaction_ID, Order_Receiving_Date, Amount, Order_Date, Publisher_ID)
VALUES (2, '2025-02-20', 1200.00, '2025-02-10', 1);

INSERT INTO Member_History (History_ID, Member_ID, Item_ID, Borrow_Date, Due_Date, Return_Date, Overdue_Charge)
VALUES (1, 1, 1, '2025-02-15', '2025-03-01', NULL, 10.00),
       (2, 1, 1, '2025-02-15', '2025-03-01', '2025-03-01', 0.00);

DELIMITER $$

CREATE PROCEDURE SearchBooksBySubject(IN subjectArea VARCHAR(255))
BEGIN
    SELECT b.*, i.Title FROM Book b JOIN Item i ON b.Item_ID = i.Item_ID WHERE b.Subject LIKE CONCAT('%', subjectArea, '%');
END$$

CREATE PROCEDURE ViewBorrowedBooks()
BEGIN
    SELECT b.*, i.Title, mh.Borrow_Date, mh.Due_Date, mh.Return_Date
    FROM Book b
    JOIN Item i ON b.Item_ID = i.Item_ID
    JOIN Member_History mh ON b.Item_ID = mh.Item_ID
    WHERE mh.Return_Date IS NULL;
END$$

CREATE PROCEDURE ViewOverdueBooks()
BEGIN
    SELECT b.*, i.Title, mh.Borrow_Date, mh.Due_Date, mh.Return_Date, mh.Overdue_Charge
    FROM Book b
    JOIN Item i ON b.Item_ID = i.Item_ID
    JOIN Member_History mh ON b.Item_ID = mh.Item_ID
    WHERE mh.Return_Date IS NULL AND mh.Due_Date < CURDATE();
END$$

CREATE PROCEDURE ViewBooksInLibrary()
BEGIN
    SELECT b.*, i.Title FROM Book b JOIN Item i ON b.Item_ID = i.Item_ID WHERE No_of_Copies_Shelf > 0;
END$$

CREATE PROCEDURE ViewFinesForAllBooks()
BEGIN
    SELECT i.Title, mh.Member_ID, mh.Overdue_Charge
    FROM Item i
    JOIN Member_History mh ON i.Item_ID = mh.Item_ID
    WHERE mh.Overdue_Charge > 0;
END$$

CREATE PROCEDURE ViewBookByPublisher(IN publisherName VARCHAR(100))
BEGIN
    SELECT DISTINCT b.Book_ID, i.Title, p.Name AS Publisher_Name
    FROM Book b
    JOIN Item i ON b.Item_ID = i.Item_ID
    JOIN Buy_Transaction bt ON bt.Publisher_ID = (SELECT Publisher_ID FROM Publisher WHERE Name = publisherName)
    JOIN Transaction t ON t.Transaction_ID = bt.Transaction_ID
    JOIN Publisher p ON p.Publisher_ID = bt.Publisher_ID;
END$$

CREATE PROCEDURE ViewOverdueMembers()
BEGIN
    SELECT m.*, mh.Borrow_Date, mh.Due_Date, mh.Return_Date
    FROM Member m
    JOIN Member_History mh ON m.Member_ID = mh.Member_ID
    WHERE mh.Return_Date IS NULL AND mh.Due_Date < CURDATE();
END$$

CREATE PROCEDURE SearchByItemName(IN itemName VARCHAR(255))
BEGIN
    SELECT * FROM Item WHERE Title LIKE CONCAT('%', itemName, '%');
END$$

CREATE PROCEDURE SearchByMember(IN memberName VARCHAR(255))
BEGIN
    SELECT * FROM Member WHERE Name LIKE CONCAT('%', memberName, '%');
END$$

CREATE PROCEDURE ViewHistoryByMember(IN memberId INT)
BEGIN
    SELECT mh.*, i.Title
    FROM Member_History mh
    JOIN Item i ON mh.Item_ID = i.Item_ID
    WHERE mh.Member_ID = memberId;
END$$

CREATE PROCEDURE SearchBooksByAuthor(IN authorName VARCHAR(255))
BEGIN
    SELECT b.*, i.Title FROM Book b JOIN Item i ON b.Item_ID = i.Item_ID WHERE b.Author LIKE CONCAT('%', authorName, '%');
END$$

CREATE PROCEDURE SearchBooksByBookName(IN bookTitle VARCHAR(255))
BEGIN
    SELECT b.*, i.Title FROM Book b JOIN Item i ON b.Item_ID = i.Item_ID WHERE i.Title LIKE CONCAT('%', bookTitle, '%');
END$$

CREATE PROCEDURE SearchJournal(IN searchTerm VARCHAR(100))
BEGIN
    SELECT j.*, i.Title
    FROM Journal j
    JOIN Item i ON j.Item_ID = i.Item_ID
    WHERE i.Title LIKE CONCAT('%', searchTerm, '%') OR j.Research_Society LIKE CONCAT('%', searchTerm, '%') OR j.Subject_Number LIKE CONCAT('%', searchTerm, '%');
END$$

CREATE TRIGGER after_users_insert_to_employee
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    IF NEW.role = 'staff' THEN
        INSERT INTO Employee (
            Employee_ID,
            Name,
            First_name,
            Last_name,
            Education,
            Hired_Date,
            Address_Line1,
            Address_Line2,
            Address_Line3,
            No_Of_Time_Published_per_year
        )
        VALUES (
            NEW.id,                     -- Map users.id to Employee_ID
            NEW.name,                   -- Full name from users
            SUBSTRING_INDEX(NEW.name, ' ', 1),  -- Extract first name
            SUBSTRING_INDEX(NEW.name, ' ', -1), -- Extract last name
            'Not Specified',            -- Default value for Education
            CURDATE(),                  -- Default to current date for Hired_Date
            NULL,                       -- Default Address fields to NULL
            NULL,
            NULL,
            0                           -- Default publishing count
        )
        ON DUPLICATE KEY UPDATE     -- Update if Employee_ID already exists
            Name = NEW.name,
            First_name = SUBSTRING_INDEX(NEW.name, ' ', 1),
            Last_name = SUBSTRING_INDEX(NEW.name, ' ', -1);
    END IF;
END$$

-- Create a procedure to update overdue charges
CREATE PROCEDURE UpdateOverdueCharges()
BEGIN
    -- Increase Overdue_Charge by $1 for each overdue item
    UPDATE Member_History
    SET Overdue_Charge = Overdue_Charge + 1.00
    WHERE Return_Date IS NULL 
    AND Due_Date < CURDATE()
    AND Overdue_Charge IS NOT NULL;
END$$

-- Create an event to run the procedure daily
CREATE EVENT IF NOT EXISTS IncreaseOverdueChargesDaily
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
    CALL UpdateOverdueCharges()$$
    

-- Create a procedure to check and delete users with excessive fines
CREATE PROCEDURE DeleteUsersWithHighFines()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE memberId INT;
    DECLARE totalFines DECIMAL(10, 2);
    
    -- Cursor to iterate over members with overdue charges
    DECLARE cur CURSOR FOR 
        SELECT Member_ID, SUM(Overdue_Charge) as Total_Charge
        FROM Member_History
        WHERE Overdue_Charge > 0
        GROUP BY Member_ID
        HAVING Total_Charge > 50.00; -- Threshold set to $50
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO memberId, totalFines;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Delete from Member table
        DELETE FROM Member WHERE Member_ID = memberId;
        
        -- Delete from users table (assuming Member_ID matches users.id)
        DELETE FROM users WHERE id = memberId;
        
    END LOOP;
    
    CLOSE cur;
END$$

-- Update the daily event to include user deletion
DROP EVENT IF EXISTS IncreaseOverdueChargesDaily$$
CREATE EVENT IF NOT EXISTS IncreaseOverdueChargesDaily
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL UpdateOverdueCharges();
    CALL DeleteUsersWithHighFines();
END$$


DELIMITER ;


INSERT INTO users (name, email, password, role) VALUES
('John Smith', 'john.smith@example.com', '$2b$10$YOUR_HASH_HERE', 'admin'),      -- Replace with bcrypt hash of 'admin123'
('Emma Johnson', 'emma.j@example.com', '$2b$10$YOUR_HASH_HERE', 'student'),    -- Hash of 'student456'
('Michael Brown', 'michael.b@example.com', '$2b$10$YOUR_HASH_HERE', 'staff'),  -- Hash of 'staff789'
('Sarah Davis', 'sarah.d@example.com', '$2b$10$YOUR_HASH_HERE', 'student'),    -- Hash of 'student101'
('David Wilson', 'david.w@example.com', '$2b$10$YOUR_HASH_HERE', 'admin'),     -- Hash of 'admin202'
('Lisa Anderson', 'lisa.a@example.com', '$2b$10$YOUR_HASH_HERE', 'staff'),     -- Hash of 'staff303'
('James Taylor', 'james.t@example.com', '$2b$10$YOUR_HASH_HERE', 'student'),   -- Hash of 'student404'
('Emily Martinez', 'emily.m@example.com', '$2b$10$YOUR_HASH_HERE', 'staff'),   -- Hash of 'staff505'
('Robert Lee', 'robert.l@example.com', '$2b$10$YOUR_HASH_HERE', 'admin'),      -- Hash of 'admin606'
('Anna White', 'anna.w@example.com', '$2b$10$YOUR_HASH_HERE', 'student');      -- Hash of 'student707'


INSERT INTO Employee (Employee_ID, First_name, Last_name, Name, Education, Hired_Date, Address_Line1, Address_Line2, Address_Line3, No_Of_Time_Published_per_year) VALUES
(2, 'Mary', 'Jane', 'Mary Jane', 'Bachelors in Education', '2021-01-10', '456 Book Rd', 'Unit 5', 'Boston, MA', 3),
(3, 'Peter', 'Parker', 'Peter Parker', 'Masters in Information Systems', '2019-09-01', '789 Read Ave', '', 'Chicago, IL', 4),
(4, 'Susan', 'Clark', 'Susan Clark', 'PhD in Literature', '2022-03-15', '101 Page St', 'Suite 2', 'San Francisco, CA', 6),
(5, 'Tom', 'Hanks', 'Tom Hanks', 'Bachelors in Library Science', '2020-11-20', '202 Shelf Ln', '', 'Los Angeles, CA', 2),
(6, 'Laura', 'Adams', 'Laura Adams', 'Masters in Education', '2021-07-01', '303 Book Dr', 'Apt 3C', 'Seattle, WA', 3),
(7, 'Chris', 'Evans', 'Chris Evans', 'Bachelors in History', '2023-01-05', '404 Reader Rd', '', 'Austin, TX', 1),
(8, 'Nancy', 'Drew', 'Nancy Drew', 'PhD in Library Science', '2018-05-10', '505 Mystery Ln', 'Unit 7', 'Denver, CO', 7),
(9, 'Mark', 'Twain', 'Mark Twain', 'Masters in Literature', '2022-09-15', '606 Story St', '', 'Portland, OR', 4),
(10, 'Ellen', 'Page', 'Ellen Page', 'Bachelors in Information Systems', '2021-12-01', '707 Index Ave', 'Apt 1A', 'Miami, FL', 2);


INSERT INTO Publisher (Publisher_ID, Name, Contact_Number, Address_Line1, Address_Line2, Address_Line3) VALUES
(2, 'XYZ Books', '1234567890', '789 Print St', '', 'New York, NY'),
(3, 'Tech Press', '5556667777', '101 Tech Rd', 'Floor 3', 'San Francisco, CA'),
(4, 'Literary Hub', '4445556666', '202 Story Ln', '', 'Chicago, IL'),
(5, 'EduBooks', '3334445555', '303 Learn Dr', 'Unit 5', 'Los Angeles, CA'),
(6, 'Science World', '1112223333', '505 Lab St', '', 'Austin, TX'),
(7, 'History Press', '9998887777', '606 Past Rd', 'Apt 4B', 'Denver, CO'),
(8, 'Future Publishing', '8887776666', '707 Tomorrow Ln', '', 'Portland, OR'),
(9, 'Classic Reads', '7776665555', '808 Old St', 'Unit 3', 'Miami, FL'),
(10, 'Global Prints', '6665554444', '909 World Ave', 'Floor 6', 'Boston, MA');


INSERT INTO Member (Member_ID, First_Name, Last_Name, Name, Address_Line1, Address_Line2, Address_Line3, Classification) VALUES
(2, 'Bob', 'Jones', 'Bob Jones', '123 Study St', '', 'New York, NY', 'Student'),
(3, 'Clara', 'Lee', 'Clara Lee', '456 Learn Ave', 'Apt 3B', 'Boston, MA', 'Staff'),
(4, 'David', 'Kim', 'David Kim', '789 Teach Rd', '', 'Chicago, IL', 'Staff'),
(5, 'Eve', 'Brown', 'Eve Brown', '101 Book Ln', 'Unit 5', 'Los Angeles, CA', 'Student'),
(6, 'Frank', 'Green', 'Frank Green', '202 Study Dr', '', 'Seattle, WA', 'Staff'),
(7, 'Grace', 'Hall', 'Grace Hall', '303 Read St', 'Apt 2C', 'Austin, TX', 'Student'),
(8, 'Henry', 'White', 'Henry White', '404 Learn Rd', '', 'Denver, CO', 'Staff'),
(9, 'Ivy', 'Black', 'Ivy Black', '505 Teach Ave', 'Unit 7', 'Portland, OR', 'Student'),
(10, 'Jack', 'Gray', 'Jack Gray', '606 Study Ln', '', 'Miami, FL', 'Staff');


INSERT INTO Item (Item_ID, Title) VALUES
(4, 'The Great Gatsby'),
(5, 'Physics for Scientists'),
(6, 'History of the World'),
(7, 'Future Tech Trends'),
(8, 'Classic Literature Collection'),
(9, 'Global Economics'),
(10, 'Data Structures Made Easy');

INSERT INTO Book (Book_ID, Item_ID, Author, Subject, No_of_Copies_Owned, No_Of_Copies_Borrowed, No_of_Copies_Shelf) VALUES
(2, 4, 'F. Scott Fitzgerald', 'Literature', 15, 5, 10),
(3, 5, 'Paul G. Hewitt', 'Physics', 8, 2, 6),
(4, 6, 'J.M. Roberts', 'History', 12, 4, 8),
(5, 7, 'Ray Kurzweil', 'Technology', 7, 1, 6),
(6, 8, 'Various', 'Literature', 20, 6, 14),
(7, 9, 'Paul Krugman', 'Economics', 9, 3, 6),
(8, 10, 'Robert Sedgewick', 'Computer Science', 11, 4, 7),
(9, 1, 'Charles E. Leiserson', 'Computer Science', 10, 2, 8), -- Same Item_ID as 1, different author
(10, 4, 'F. Scott Fitzgerald', 'Literature', 15, 7, 8); -- Same Item_ID as 4, different entry


INSERT INTO DVD (Item_ID, Subject, Producer, Subject_Area, Year_Publication) VALUES
(3, 'AI Research', 'Science Media', 'Artificial Intelligence', 2023),
(4, 'Literature', 'Classic Films', 'American Literature', 2020),
(5, 'Physics', 'EduMedia', 'Mechanics', 2021),
(6, 'History', 'History Channel', 'World History', 2019),
(7, 'Technology', 'Future Vision', 'Innovation', 2024),
(8, 'Literature', 'Book Adaptations', 'British Literature', 2022),
(9, 'Economics', 'Global Insights', 'Macroeconomics', 2023),
(10, 'Computer Science', 'Code Central', 'Data Structures', 2021),
(1, 'Computer Science', 'Tech Tutorials', 'Programming', 2020); -- Same Item_ID as 1


INSERT INTO Journal (Item_ID, Research_Society, Subject_Number) VALUES
(1, 'CS Research Group', 'CS-2023'),
(4, 'Literary Society', 'LIT-2022'),
(5, 'Physics Association', 'PHY-2021'),
(6, 'Historical Society', 'HIS-2020'),
(7, 'Tech Innovators', 'TECH-2025'),
(8, 'Classic Studies', 'CLS-2019'),
(9, 'Economic Forum', 'ECO-2023'),
(10, 'Data Science Group', 'DS-2022'),
(2, 'Algorithm Society', 'ALG-2021'); -- Same Item_ID as 2


INSERT INTO Transaction (Transaction_ID, Transaction_Amount, Employee_ID) VALUES
(3, 300.00, 3),
(4, 800.00, 4),
(5, 450.00, 5),
(6, 600.00, 6),
(7, 950.00, 7),
(8, 200.00, 8),
(9, 700.00, 9),
(10, 1100.00, 10);


INSERT INTO Lend_Transaction (Transaction_ID, Borrow_Date, Return_Date, Due_Date) VALUES
(2, '2025-02-20', '2025-03-10', '2025-03-05'),
(3, '2025-03-10', NULL, '2025-03-25'),
(4, '2025-02-15', '2025-03-01', '2025-02-28'),
(5, '2025-03-05', NULL, '2025-03-20'),
(6, '2025-02-25', '2025-03-15', '2025-03-10'),
(7, '2025-03-15', NULL, '2025-03-30'),
(8, '2025-02-10', '2025-02-25', '2025-02-20'),
(9, '2025-03-20', NULL, '2025-04-05'),
(10, '2025-03-01', '2025-03-20', '2025-03-15');


INSERT INTO Buy_Transaction (Transaction_ID, Order_Receiving_Date, Amount, Order_Date, Publisher_ID) VALUES
(1, '2025-02-20', 1200.00, '2025-02-10', 1),
(3, '2025-03-15', 500.00, '2025-03-05', 3),
(4, '2025-02-25', 950.00, '2025-02-15', 4),
(5, '2025-03-10', 600.00, '2025-03-01', 5),
(6, '2025-03-20', 1100.00, '2025-03-10', 6),
(7, '2025-02-15', 300.00, '2025-02-05', 7),
(8, '2025-03-05', 700.00, '2025-02-25', 8),
(9, '2025-03-25', 450.00, '2025-03-15', 9),
(10, '2025-02-28', 200.00, '2025-02-18', 10);


INSERT INTO Member_History (History_ID, Member_ID, Item_ID, Borrow_Date, Due_Date, Return_Date, Overdue_Charge) VALUES
(3, 3, 5, '2025-03-10', '2025-03-25', NULL, 5.00),
(4, 4, 6, '2025-02-20', '2025-03-05', '2025-03-01', 0.00),
(5, 5, 7, '2025-03-05', '2025-03-20', NULL, 8.00),
(6, 6, 8, '2025-02-25', '2025-03-10', '2025-03-15', 0.00),
(7, 7, 9, '2025-03-15', '2025-03-30', NULL, 12.00),
(8, 8, 10, '2025-02-10', '2025-02-25', '2025-02-20', 0.00),
(9, 9, 2, '2025-03-20', '2025-04-05', NULL, 15.00),
(10, 10, 3, '2025-03-01', '2025-03-15', '2025-03-20', 3.00);

