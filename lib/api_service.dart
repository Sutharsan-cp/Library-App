import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:5000";
  static String? token;

  static void setToken(String newToken) {
    token = newToken;
  }

  static Map<String, String> get headers => {
    "Content-Type": "application/json",
    if (token != null) "Authorization": "Bearer $token",
  };

  // Signup API
  static Future<Map<String, dynamic>> signUp(String email, String password, String name, String role) async {
    final response = await http.post(
      Uri.parse("$baseUrl/signup"),
      headers: headers,
      body: jsonEncode({"email": email, "password": password, "name": name, "role": role}),
    );
    return jsonDecode(response.body);
  }

  // Login API
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: headers,
      body: jsonEncode({"email": email, "password": password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) setToken(data['token']);
    return data;
  }

  // Admin APIs
  static Future<List<dynamic>> searchBooksBySubject(String subject) async {
    final response = await http.get(Uri.parse("$baseUrl/admin/search-books/$subject"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> viewBorrowedBooks() async {
    final response = await http.get(Uri.parse("$baseUrl/admin/borrowed-books"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> viewOverdueBooks() async {
    final response = await http.get(Uri.parse("$baseUrl/admin/overdue-books"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> viewBooksInLibrary() async {
    final response = await http.get(Uri.parse("$baseUrl/admin/library-books"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> viewFinesForAllBooks() async {
    final response = await http.get(Uri.parse("$baseUrl/admin/fines"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> viewBooksByPublisher(String publisher) async {
    final response = await http.get(Uri.parse("$baseUrl/admin/books-by-publisher/$publisher"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> viewOverdueMembers() async {
    final response = await http.get(Uri.parse("$baseUrl/admin/overdue-members"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> searchByItemName(String name) async {
    final response = await http.get(Uri.parse("$baseUrl/admin/search-item/$name"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> searchByMember(String name) async {
    final response = await http.get(Uri.parse("$baseUrl/admin/search-member/$name"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> viewHistoryByMember(int memberId) async {
    final response = await http.get(Uri.parse("$baseUrl/admin/history/$memberId"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> searchBooksByAuthor(String author) async {
    final response = await http.get(Uri.parse("$baseUrl/admin/search-author/$author"), headers: headers);
    return jsonDecode(response.body);
  }

  // Student APIs
  static Future<List<dynamic>> searchItemForStudent(String name) async {
    final response = await http.get(Uri.parse("$baseUrl/student/search-item/$name"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> viewStudentHistory(int memberId) async {
    final response = await http.get(Uri.parse("$baseUrl/student/history/$memberId"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> searchBooksByAuthorStudent(String author) async {
    final response = await http.get(Uri.parse("$baseUrl/student/search-author/$author"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> searchBooksBySubjectForStudent(String subject) async {
    final response = await http.get(Uri.parse("$baseUrl/student/search-subject/$subject"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> searchBooksByNameStudent(String title) async {
    final response = await http.get(Uri.parse("$baseUrl/student/search-book/$title"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> searchJournalStudent(String term) async {
    final response = await http.get(Uri.parse("$baseUrl/student/search-journal/$term"), headers: headers);
    return jsonDecode(response.body);
  }

  // Staff APIs
  static Future<List<dynamic>> searchItemForStaff(String name) async {
    final response = await http.get(Uri.parse("$baseUrl/staff/search-item/$name"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> viewStaffHistory(int memberId) async {
    final response = await http.get(Uri.parse("$baseUrl/staff/history/$memberId"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> searchBooksByAuthorStaff(String author) async {
    final response = await http.get(Uri.parse("$baseUrl/staff/search-author/$author"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> searchBooksBySubjectForStaff(String subject) async {
    final response = await http.get(Uri.parse("$baseUrl/staff/search-subject/$subject"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> searchBooksByBookNameForStaff(String title) async {
    final response = await http.get(Uri.parse("$baseUrl/staff/search-book/$title"), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> searchJournalStaff(String term) async {
    final response = await http.get(Uri.parse("$baseUrl/staff/search-journal/$term"), headers: headers);
    return jsonDecode(response.body);
  }

static Future<Map<String, dynamic>> updateStaffEducation(
  int userId,
  String education,
  String addressLine1,
  String? addressLine2,
  String? addressLine3,
) async {
  final response = await http.post(
    Uri.parse("$baseUrl/staff/update-education"),
    headers: headers, // Includes Authorization token
    body: jsonEncode({
      "userId": userId,
      "education": education,
      "addressLine1": addressLine1,
      "addressLine2": addressLine2,
      "addressLine3": addressLine3,
    }),
  );
  return jsonDecode(response.body);
}

static Future<Map<String, dynamic>> deleteUser(int userId) async {
  final response = await http.delete(
    Uri.parse("$baseUrl/admin/delete-user/$userId"),
    headers: headers,
  );
  return jsonDecode(response.body);
}

// Shared recommendation API for students and staff
static Future<List<dynamic>> getBookRecommendations(String subject) async {
  final response = await http.get(Uri.parse("$baseUrl/student/recommend-books/$subject"), headers: headers);
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to load recommendations: ${response.statusCode} - ${response.body}");
  }
}

static Future<Map<String, dynamic>> checkAndDeleteOverdueUsers() async {
  final response = await http.post(
    Uri.parse("$baseUrl/admin/check-and-delete-overdue-users"),
    headers: headers,
  );
  return jsonDecode(response.body);
}

}