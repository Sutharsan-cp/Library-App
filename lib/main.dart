import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Library App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: HomeScreen(),
    );
  }
}

// Home Screen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://static.vecteezy.com/system/resources/thumbnails/054/430/430/small_2x/open-book-on-a-table-photo.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black, BlendMode.dstATop),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_library, size: 100, color: Colors.white),
              SizedBox(height: 20),
              Text(
                "Welcome to Library Operations",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, shadows: [
                  Shadow(color: Colors.black45, offset: Offset(2, 2), blurRadius: 4),
                ]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                child: Text("Get Started", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    setState(() => isLoading = true);
    final response = await ApiService.login(emailController.text, passwordController.text);
    setState(() => isLoading = false);

    if (response['message'] == "Login successful") {
      String role = response['role'];
      int userId = response['userId'];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Login Successful: $role")));
      if (role == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminDashboard()));
      } else if (role == 'student') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserDashboard(role: 'student', userId: userId)));
      } else if (role == 'staff') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserDashboard(role: 'staff', userId: userId)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ ${response['message']}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1512820790803-83ca734da794?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black, BlendMode.dstATop),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Login",
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email, color: Colors.blue.shade700),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock, color: Colors.blue.shade700),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        SizedBox(height: 24),
                        isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: loginUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  elevation: 5,
                                ),
                                child: Text("Login", style: TextStyle(fontSize: 18)),
                              ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen())),
                          child: Text(
                            "Don't have an account? Sign Up",
                            style: TextStyle(color: Colors.blue.shade700, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Signup Screen
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = "student";
  bool isLoading = false;

  Future<void> signupUser() async {
    setState(() => isLoading = true);
    final response = await ApiService.signUp(
      emailController.text,
      passwordController.text,
      nameController.text,
      selectedRole,
    );
    setState(() => isLoading = false);

    if (response['message'] == "User created successfully") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ ${response['message']}")),
      );

      if (selectedRole == 'staff') {
        final userId = response['userId'];
        if (userId != null) {
          await _showStaffDetailsDialog(userId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Failed to retrieve user ID")),
          );
        }
      } else {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ ${response['error'] ?? 'Signup failed'}")),
      );
    }
  }

  Future<void> _showStaffDetailsDialog(int userId) async {
    final TextEditingController educationController = TextEditingController();
    final TextEditingController addressLine1Controller = TextEditingController();
    final TextEditingController addressLine2Controller = TextEditingController();
    final TextEditingController addressLine3Controller = TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Staff Details Required"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: educationController,
                decoration: InputDecoration(labelText: "Education (e.g., Masters in Library Science)"),
              ),
              TextField(
                controller: addressLine1Controller,
                decoration: InputDecoration(labelText: "Address Line 1"),
              ),
              TextField(
                controller: addressLine2Controller,
                decoration: InputDecoration(labelText: "Address Line 2 (Optional)"),
              ),
              TextField(
                controller: addressLine3Controller,
                decoration: InputDecoration(labelText: "Address Line 3 (Optional)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (educationController.text.isNotEmpty && addressLine1Controller.text.isNotEmpty) {
                final response = await ApiService.updateStaffEducation(
                  userId,
                  educationController.text,
                  addressLine1Controller.text,
                  addressLine2Controller.text.isEmpty ? null : addressLine2Controller.text,
                  addressLine3Controller.text.isEmpty ? null : addressLine3Controller.text,
                );
                if (response['message'] == "Education updated successfully") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("✅ Staff details updated successfully")),
                  );
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Return to login screen
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("❌ ${response['message'] ?? 'Failed to update staff details'}")),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("❌ Education and Address Line 1 are required")),
                );
              }
            },
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1512820790803-83ca734da794?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.dstATop),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            prefixIcon: Icon(Icons.person, color: Colors.blue.shade700),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email, color: Colors.blue.shade700),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock, color: Colors.blue.shade700),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          decoration: InputDecoration(
                            labelText: "Role",
                            prefixIcon: Icon(Icons.group, color: Colors.blue.shade700),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onChanged: (String? newValue) => setState(() => selectedRole = newValue!),
                          items: ["admin", "student", "staff"].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value.toUpperCase()));
                          }).toList(),
                        ),
                        SizedBox(height: 24),
                        isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: signupUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  elevation: 5,
                                ),
                                child: Text("Sign Up", style: TextStyle(fontSize: 18)),
                              ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Already have an account? Login",
                            style: TextStyle(color: Colors.blue.shade700, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Admin Dashboard
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<dynamic> books = [];
  List<dynamic> overdueBooks = [];
  List<dynamic> borrowedBooks = [];
  List<dynamic> fines = [];
  List<dynamic> overdueMembers = [];
  List<dynamic> searchResults = [];

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController publisherController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController memberNameController = TextEditingController();
  final TextEditingController memberIdController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController deleteUserIdController = TextEditingController();

  bool isLoading = false;

  Color getPrimaryColor() => Colors.blue.shade700;
  Color getLightColor() => Colors.blue.shade50;
  Color getDarkColor() => Colors.blue.shade900;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: getPrimaryColor(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() => isLoading = true);
              var result = await ApiService.viewBooksInLibrary();
              setState(() {
                books = result ?? [];
                isLoading = false;
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [getLightColor(), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () async => _fetchData(ApiService.viewBooksInLibrary, (r) => books = r),
                    child: const Text("View All Books"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getPrimaryColor(),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async => _fetchData(ApiService.viewOverdueBooks, (r) => overdueBooks = r),
                    child: const Text("View Overdue Books"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getPrimaryColor(),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async => _fetchData(ApiService.viewBorrowedBooks, (r) => borrowedBooks = r),
                    child: const Text("View Borrowed Books"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getPrimaryColor(),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async => _fetchData(ApiService.viewFinesForAllBooks, (r) => fines = r),
                    child: const Text("View Fines"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getPrimaryColor(),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async => _fetchData(ApiService.viewOverdueMembers, (r) => overdueMembers = r),
                    child: const Text("View Overdue Members"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getPrimaryColor(),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _deleteUserDialog(),
                    child: const Text("Delete User"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getPrimaryColor(),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                  ),
                  ElevatedButton(
  onPressed: () async {
    setState(() => isLoading = true);
    final response = await ApiService.checkAndDeleteOverdueUsers();
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['message'] ?? "Error")),
    );
  },
  child: const Text("Check & Delete Overdue Users"),
  style: ElevatedButton.styleFrom(
    backgroundColor: getPrimaryColor(),
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 3,
  ),
),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Search Options",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: getDarkColor()),
              ),
              SizedBox(height: 10),
              _buildSearchField("Search by Subject", subjectController, () => ApiService.searchBooksBySubject(subjectController.text)),
              _buildSearchField("Search by Publisher", publisherController, () => ApiService.viewBooksByPublisher(publisherController.text)),
              _buildSearchField("Search by Item Name", itemNameController, () => ApiService.searchByItemName(itemNameController.text)),
              _buildSearchField("Search by Author", authorController, () => ApiService.searchBooksByAuthor(authorController.text)),
              _buildSearchField("Search by Member Name", memberNameController, () => ApiService.searchByMember(memberNameController.text)),
              _buildSearchField("View Member History (Member ID)", memberIdController, () => ApiService.viewHistoryByMember(int.parse(memberIdController.text)), isNumber: true),
              const SizedBox(height: 20),
              if (isLoading) Center(child: CircularProgressIndicator(color: getPrimaryColor())) else _buildResults(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchData(Future<List<dynamic>> Function() apiCall, Function(List<dynamic>) setter) async {
    setState(() => isLoading = true);
    var result = await apiCall();
    setState(() {
      setter(result ?? []);
      isLoading = false;
    });
  }

  Future<void> _deleteUserDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete User", style: TextStyle(color: getDarkColor())),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: deleteUserIdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter User ID",
                prefixIcon: Icon(Icons.person, color: getPrimaryColor()),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: getPrimaryColor())),
          ),
          TextButton(
            onPressed: () async {
              if (deleteUserIdController.text.isNotEmpty) {
                setState(() => isLoading = true);
                final userId = int.parse(deleteUserIdController.text);
                final response = await ApiService.deleteUser(userId);
                setState(() => isLoading = false);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(response['message'] ?? "Error deleting user"),
                    backgroundColor: response['message'] == "User deleted successfully" ? Colors.green : Colors.red,
                  ),
                );
                deleteUserIdController.clear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("❌ Please enter a User ID")),
                );
              }
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(String label, TextEditingController controller, Future<List<dynamic>> Function() apiCall, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.search, color: getPrimaryColor()),
          suffixIcon: IconButton(
            icon: Icon(Icons.search, color: getPrimaryColor()),
            onPressed: () async => _fetchData(apiCall, (r) => searchResults = r),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (books.isNotEmpty) ...[
          Text("Library Books", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: getDarkColor())),
          SizedBox(height: 10),
          _buildBookList(books),
        ],
        if (overdueBooks.isNotEmpty) ...[
          SizedBox(height: 20),
          Text("Overdue Books", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: getDarkColor())),
          SizedBox(height: 10),
          _buildBookList(overdueBooks),
        ],
        if (borrowedBooks.isNotEmpty) ...[
          SizedBox(height: 20),
          Text("Borrowed Books", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: getDarkColor())),
          SizedBox(height: 10),
          _buildBookList(borrowedBooks),
        ],
        if (fines.isNotEmpty) ...[
          SizedBox(height: 20),
          Text("Fines", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: getDarkColor())),
          SizedBox(height: 10),
          _buildFineList(fines),
        ],
        if (overdueMembers.isNotEmpty) ...[
          SizedBox(height: 20),
          Text("Overdue Members", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: getDarkColor())),
          SizedBox(height: 10),
          _buildMemberList(overdueMembers),
        ],
        if (searchResults.isNotEmpty) ...[
          SizedBox(height: 20),
          Text("Search Results", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: getDarkColor())),
          SizedBox(height: 10),
          _buildBookList(searchResults),
        ],
      ],
    );
  }

  Widget _buildBookList(List<dynamic> items) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, spreadRadius: 2)],
      ),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];
          return ListTile(
            leading: Icon(Icons.book, color: getPrimaryColor()),
            title: Text(item['Title'] ?? 'No Title'),
            subtitle: Text('Author: ${item['Author'] ?? 'Unknown'}'),
          );
        },
      ),
    );
  }

  Widget _buildFineList(List<dynamic> items) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, spreadRadius: 2)],
      ),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];
          return ListTile(
            leading: Icon(Icons.money_off, color: getPrimaryColor()),
            title: Text('Book: ${item['Title'] ?? 'Unknown'}'),
            subtitle: Text('Fine: \$${item['Overdue_Charge'] ?? '0'} - Member: ${item['Member_ID'] ?? 'N/A'}'),
          );
        },
      ),
    );
  }

  Widget _buildMemberList(List<dynamic> items) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, spreadRadius: 2)],
      ),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];
          return ListTile(
            leading: Icon(Icons.person, color: getPrimaryColor()),
            title: Text(item['Name'] ?? 'Unknown Member'),
            subtitle: Text('ID: ${item['Member_ID'] ?? 'N/A'}'),
          );
        },
      ),
    );
  }
}

// User Dashboard (Student/Staff)
class UserDashboard extends StatefulWidget {
  final String role;
  final int userId;

  const UserDashboard({super.key, required this.role, required this.userId});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  List<dynamic> history = [];
  List<dynamic> searchResults = [];
  List<dynamic> recommendations = [];

  final TextEditingController itemController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController bookNameController = TextEditingController();
  final TextEditingController journalController = TextEditingController();
  final TextEditingController recommendationSubjectController = TextEditingController();

  bool isLoading = false;

  Color getPrimaryColor() => widget.role == 'student' ? Colors.green.shade700 : Colors.orange.shade700;
  Color getLightColor() => widget.role == 'student' ? Colors.green.shade50 : Colors.orange.shade50;
  Color getDarkColor() => widget.role == 'student' ? Colors.green.shade900 : Colors.orange.shade900;

  @override
  Widget build(BuildContext context) {
    final isStudent = widget.role == 'student';
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.role.toUpperCase()} Dashboard'),
        backgroundColor: getPrimaryColor(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() => isLoading = true);
              var result = await (isStudent ? ApiService.viewStudentHistory(widget.userId) : ApiService.viewStaffHistory(widget.userId));
              setState(() {
                history = result ?? [];
                isLoading = false;
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [getLightColor(), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildActionButton(
                    "View Borrowing History",
                    Icons.history,
                    () => _fetchData(
                      () => isStudent ? ApiService.viewStudentHistory(widget.userId) : ApiService.viewStaffHistory(widget.userId),
                      (r) => history = r,
                    ),
                  ),
                  _buildActionButton(
                    "Get Recommendations",
                    Icons.recommend,
                    () => _showRecommendationDialog(),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Search Options",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: getDarkColor()),
              ),
              SizedBox(height: 10),
              _buildSearchField(
                "Search Items",
                itemController,
                () => isStudent ? ApiService.searchItemForStudent(itemController.text) : ApiService.searchItemForStaff(itemController.text),
                Icons.search,
              ),
              _buildSearchField(
                "Search by Author",
                authorController,
                () => isStudent ? ApiService.searchBooksByAuthorStudent(authorController.text) : ApiService.searchBooksByAuthorStaff(authorController.text),
                Icons.person,
              ),
              _buildSearchField(
                "Search by Subject",
                subjectController,
                () => isStudent ? ApiService.searchBooksBySubjectForStudent(subjectController.text) : ApiService.searchBooksBySubjectForStaff(subjectController.text),
                Icons.subject,
              ),
              _buildSearchField(
                "Search by Book Name",
                bookNameController,
                () => isStudent ? ApiService.searchBooksByNameStudent(bookNameController.text) : ApiService.searchBooksByBookNameForStaff(bookNameController.text),
                Icons.book,
              ),
              _buildSearchField(
                "Search Journals",
                journalController,
                () => isStudent ? ApiService.searchJournalStudent(journalController.text) : ApiService.searchJournalStaff(journalController.text),
                Icons.article,
              ),
              SizedBox(height: 20),
              if (isLoading)
                Center(child: CircularProgressIndicator(color: getPrimaryColor()))
              else
                _buildResults(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchData(Future<List<dynamic>> Function() apiCall, Function(List<dynamic>) setter) async {
    setState(() => isLoading = true);
    try {
      var result = await apiCall();
      setState(() {
        setter(result ?? []);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _showRecommendationDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Book Recommendations", style: TextStyle(color: getDarkColor())),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: recommendationSubjectController,
              decoration: InputDecoration(
                labelText: "Enter Subject (e.g., Computer Science)",
                prefixIcon: Icon(Icons.subject, color: getPrimaryColor()),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: getPrimaryColor())),
          ),
          TextButton(
            onPressed: () async {
              if (recommendationSubjectController.text.isNotEmpty) {
                setState(() => isLoading = true);
                try {
                  final result = await ApiService.getBookRecommendations(recommendationSubjectController.text);
                  setState(() {
                    recommendations = result.isEmpty ? [] : result;
                    isLoading = false;
                  });
                  Navigator.pop(context);
                  if (recommendations.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("No recommendations found for this subject")),
                    );
                  }
                } catch (e) {
                  setState(() => isLoading = false);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error fetching recommendations: $e")),
                  );
                }
                recommendationSubjectController.clear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("❌ Please enter a subject")),
                );
              }
            },
            child: Text("Get Recommendations", style: TextStyle(color: getPrimaryColor())),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: getPrimaryColor(),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
    );
  }

  Widget _buildSearchField(String label, TextEditingController controller, Future<List<dynamic>> Function() apiCall, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: getPrimaryColor()),
          suffixIcon: IconButton(
            icon: Icon(Icons.search, color: getPrimaryColor()),
            onPressed: () async => _fetchData(apiCall, (r) => searchResults = r),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (history.isNotEmpty) ...[
          Text("Borrowing History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: getDarkColor())),
          SizedBox(height: 10),
          _buildHistoryList(history),
        ],
        if (searchResults.isNotEmpty) ...[
          SizedBox(height: 20),
          Text("Search Results", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: getDarkColor())),
          SizedBox(height: 10),
          _buildSearchResultList(searchResults),
        ],
        if (recommendations.isNotEmpty) ...[
          SizedBox(height: 20),
          Text("Recommended Books", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: getDarkColor())),
          SizedBox(height: 10),
          _buildRecommendationList(recommendations),
        ],
      ],
    );
  }

  Widget _buildHistoryList(List<dynamic> items) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, spreadRadius: 2)],
      ),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];
          return ListTile(
            leading: Icon(Icons.history, color: getPrimaryColor()),
            title: Text(item['Title'] ?? 'Unknown Item'),
            subtitle: Text('Borrowed: ${item['Borrow_Date'] ?? 'N/A'} | Due: ${item['Due_Date'] ?? 'N/A'}'),
            trailing: item['Return_Date'] == null
                ? Chip(label: Text('Not Returned'), backgroundColor: Colors.red.shade100)
                : Chip(label: Text('Returned'), backgroundColor: getLightColor()),
          );
        },
      ),
    );
  }

  Widget _buildSearchResultList(List<dynamic> items) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, spreadRadius: 2)],
      ),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];
          return ListTile(
            leading: Icon(Icons.book, color: getPrimaryColor()),
            title: Text(item['Title'] ?? 'No Title'),
            subtitle: Text('Author: ${item['Author'] ?? 'Unknown'}'),
          );
        },
      ),
    );
  }

  Widget _buildRecommendationList(List<dynamic> items) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, spreadRadius: 2)],
      ),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];
          return ListTile(
            leading: Icon(Icons.recommend, color: getPrimaryColor()),
            title: Text(item['Title'] ?? 'No Title'),
            subtitle: Text('Author: ${item['Author'] ?? 'Unknown'} | Copies: ${item['No_of_Copies_Shelf'] ?? 0}'),
          );
        },
      ),
    );
  }
}