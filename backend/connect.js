const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;
const JWT_SECRET = process.env.JWT_SECRET || 'your_secret_key';

// Middleware
app.use(cors({ origin: "*", methods: ["GET", "POST", "PUT", "DELETE"], allowedHeaders: ["Content-Type", "Authorization"] }));
app.use(bodyParser.json());

// MySQL Connection
const db = mysql.createConnection({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASS || "",
  database: process.env.DB_NAME || "library_db"
});

db.connect(err => {
  if (err) console.error('❌ Database connection failed:', err);
  else console.log('✅ Connected to MySQL database');
});

// Authentication Middleware
const authenticate = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(401).json({ message: "No token provided" });
  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) return res.status(403).json({ message: "Invalid token" });
    req.user = decoded;
    next();
  });
};

// Test Route
app.get('/', (req, res) => res.send("🚀 Backend is running successfully!"));

// Signup API
app.post("/signup", async (req, res) => {
  try {
    const { name, email, password, role = "student" } = req.body;
    if (!name || !email || !password) return res.status(400).json({ error: "All fields are required" });
    const hashedPassword = await bcrypt.hash(password, 10);
    const query = "INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)";
    db.query(query, [name, email, hashedPassword, role], (err, result) => {
      if (err) return res.status(500).json({ error: "Error creating user", details: err.message });
      const userId = result.insertId; // Get the auto-incremented ID
      res.status(201).json({ message: "User created successfully", userId });
    });
  } catch (error) {
    res.status(500).json({ error: "Server error", details: error.message });
  }
});

// Login API
app.post('/login', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ message: "Email and password are required" });
  const sql = 'SELECT * FROM users WHERE email = ?';
  db.query(sql, [email], async (err, results) => {
    if (err) return res.status(500).json({ message: "Server error", details: err.message });
    if (results.length === 0) return res.status(401).json({ message: "Invalid credentials" });
    const user = results[0];
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ message: "Invalid credentials" });
    const token = jwt.sign({ id: user.id, role: user.role }, JWT_SECRET, { expiresIn: '1h' });
    res.status(200).json({ message: "Login successful", token, role: user.role, userId: user.id });
  });
});

// Admin Routes
app.get('/admin/search-books/:subject', authenticate, (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ message: "Unauthorized" });
  const subject = req.params.subject;
  const sql = "CALL SearchBooksBySubject(?)";
  db.query(sql, [subject], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/admin/borrowed-books', authenticate, (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ message: "Unauthorized" });
  const sql = "CALL ViewBorrowedBooks()";
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/admin/overdue-books', authenticate, (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ message: "Unauthorized" });
  const sql = "CALL ViewOverdueBooks()";
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/admin/library-books', authenticate, (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ message: "Unauthorized" });
  const sql = "CALL ViewBooksInLibrary()";
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/admin/fines', authenticate, (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ message: "Unauthorized" });
  const sql = "CALL ViewFinesForAllBooks()";
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/admin/books-by-publisher/:publisher', authenticate, (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ message: "Unauthorized" });
  const publisher = req.params.publisher;
  const sql = "CALL ViewBookByPublisher(?)";
  db.query(sql, [publisher], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/admin/overdue-members', authenticate, (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ message: "Unauthorized" });
  const sql = "CALL ViewOverdueMembers()";
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/admin/search-item/:name', authenticate, (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ message: "Unauthorized" });
  const name = req.params.name;
  const sql = "CALL SearchByItemName(?)";
  db.query(sql, [name], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/admin/search-member/:name', authenticate, (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ message: "Unauthorized" });
  const name = req.params.name;
  const sql = "CALL SearchByMember(?)";
  db.query(sql, [name], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/admin/history/:memberId', authenticate, (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ message: "Unauthorized" });
  const memberId = req.params.memberId;
  const sql = "CALL ViewHistoryByMember(?)";
  db.query(sql, [memberId], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/admin/search-author/:author', authenticate, (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ message: "Unauthorized" });
  const author = req.params.author;
  const sql = "CALL SearchBooksByAuthor(?)";
  db.query(sql, [author], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

// Student Routes
app.get('/student/search-item/:name', authenticate, (req, res) => {
  if (req.user.role !== 'student') return res.status(403).json({ message: "Unauthorized" });
  const name = req.params.name;
  const sql = "CALL SearchByItemName(?)";
  db.query(sql, [name], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/student/history/:memberId', authenticate, (req, res) => {
  if (req.user.role !== 'student') return res.status(403).json({ message: "Unauthorized" });
  const memberId = req.params.memberId;
  const sql = "CALL ViewHistoryByMember(?)";
  db.query(sql, [memberId], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/student/search-author/:author', authenticate, (req, res) => {
  if (req.user.role !== 'student') return res.status(403).json({ message: "Unauthorized" });
  const author = req.params.author;
  const sql = "CALL SearchBooksByAuthor(?)";
  db.query(sql, [author], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/student/search-subject/:subject', authenticate, (req, res) => {
  if (req.user.role !== 'student') return res.status(403).json({ message: "Unauthorized" });
  const subject = req.params.subject;
  const sql = "CALL SearchBooksBySubject(?)";
  db.query(sql, [subject], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/student/search-book/:title', authenticate, (req, res) => {
  if (req.user.role !== 'student') return res.status(403).json({ message: "Unauthorized" });
  const title = req.params.title;
  const sql = "CALL SearchBooksByBookName(?)";
  db.query(sql, [title], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/student/search-journal/:term', authenticate, (req, res) => {
  if (req.user.role !== 'student') return res.status(403).json({ message: "Unauthorized" });
  const term = req.params.term;
  const sql = "CALL SearchJournal(?)";
  db.query(sql, [term], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

// Staff Routes
app.get('/staff/search-item/:name', authenticate, (req, res) => {
  if (req.user.role !== 'staff') return res.status(403).json({ message: "Unauthorized" });
  const name = req.params.name;
  const sql = "CALL SearchByItemName(?)";
  db.query(sql, [name], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/staff/history/:memberId', authenticate, (req, res) => {
  if (req.user.role !== 'staff') return res.status(403).json({ message: "Unauthorized" });
  const memberId = req.params.memberId;
  const sql = "CALL ViewHistoryByMember(?)";
  db.query(sql, [memberId], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/staff/search-author/:author', authenticate, (req, res) => {
  if (req.user.role !== 'staff') return res.status(403).json({ message: "Unauthorized" });
  const author = req.params.author;
  const sql = "CALL SearchBooksByAuthor(?)";
  db.query(sql, [author], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/staff/search-subject/:subject', authenticate, (req, res) => {
  if (req.user.role !== 'staff') return res.status(403).json({ message: "Unauthorized" });
  const subject = req.params.subject;
  const sql = "CALL SearchBooksBySubject(?)";
  db.query(sql, [subject], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/staff/search-book/:title', authenticate, (req, res) => {
  if (req.user.role !== 'staff') return res.status(403).json({ message: "Unauthorized" });
  const title = req.params.title;
  const sql = "CALL SearchBooksByBookName(?)";
  db.query(sql, [title], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/staff/search-journal/:term', authenticate, (req, res) => {
  if (req.user.role !== 'staff') return res.status(403).json({ message: "Unauthorized" });
  const term = req.params.term;
  const sql = "CALL SearchJournal(?)";
  db.query(sql, [term], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});


app.post('/staff/update-education', authenticate, (req, res) => {
  if (req.user.role !== 'staff') return res.status(403).json({ message: "Unauthorized" });

  const { userId, education, addressLine1, addressLine2, addressLine3 } = req.body;

  if (!userId || !education || !addressLine1) {
    return res.status(400).json({ message: "User ID, education, and Address Line 1 are required" });
  }

  if (req.user.id !== userId) {
    return res.status(403).json({ message: "You can only update your own details" });
  }

  // Fetch the user's name from the users table
  db.query("SELECT name FROM users WHERE id = ?", [userId], (err, results) => {
    if (err || results.length === 0) {
      return res.status(500).json({ message: "Error fetching user", details: err?.message });
    }

    const name = results[0].name;
    const sql = `
      INSERT INTO Employee (Employee_ID, Name, Education, Hired_Date, Address_Line1, Address_Line2, Address_Line3)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
        Education = ?,
        Address_Line1 = ?,
        Address_Line2 = ?,
        Address_Line3 = ?
    `;
    db.query(
      sql,
      [
        userId,
        name,
        education,
        new Date().toISOString().slice(0, 10),
        addressLine1,
        addressLine2 || null,
        addressLine3 || null,
        education || "cs",
        addressLine1,
        addressLine2 || null,
        addressLine3 || null,
      ],
      (err, result) => {
        if (err) {
          console.error("❌ Error updating education:", err);
          return res.status(500).json({ message: "Server error", error: err });
        }
        console.log("✅ Education and address updated for user:", userId);
        res.status(200).json({ message: "Education updated successfully" });
      }
    );
  });
});

// Delete User API
app.delete('/admin/delete-user/:userId', authenticate, (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ message: "Unauthorized" });

  const userId = req.params.userId;
  const sql = "DELETE FROM users WHERE id = ?";

  db.query(sql, [userId], (err, result) => {
    if (err) return res.status(500).json({ error: "Server error", details: err.message });
    if (result.affectedRows === 0) return res.status(404).json({ message: "User not found" });
    res.status(200).json({ message: "User deleted successfully" });
  });
});

app.get('/student/recommend-books/:subject', authenticate, (req, res) => {
  // Update role check to allow both 'student' and 'staff'
  if (req.user.role !== 'student' && req.user.role !== 'staff') {
    return res.status(403).json({ message: "Unauthorized" });
  }
  const subject = req.params.subject;
  const sql = "CALL SearchBooksBySubject(?)";
  db.query(sql, [subject], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    const recommendations = results[0]
      .filter(book => book.No_of_Copies_Shelf > 0) // Only recommend available books
      .sort((a, b) => b.No_of_Copies_Shelf - a.No_of_Copies_Shelf) // Sort by availability
      .slice(0, 5); // Limit to top 5 recommendations
    res.json(recommendations);
  });
});

app.post('/admin/check-and-delete-overdue-users', authenticate, (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ message: "Unauthorized" });
  
  const sql = "CALL DeleteUsersWithHighFines()";
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(200).json({ message: "Checked and deleted users with high fines" });
  });
});

app.listen(PORT, () => console.log(`🚀 Server running on http://localhost:${PORT}`));