// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';

// // class ApiService {
// //   static const String baseUrl = "https://salaah-api.shahada.life/api";
// //   // static const String baseUrl = "http://10.187.168.232:8000/api";

// //   // --- Helpers ---

// //   static Future<Map<String, String>> _getHeaders({
// //     bool protected = false,
// //   }) async {
// //     Map<String, String> headers = {
// //       "Content-Type": "application/json",
// //       "Accept": "application/json",
// //     };

// //     if (protected) {
// //       String? token = await getToken();
// //       if (token != null) {
// //         headers["Authorization"] = "Bearer $token";
// //       }
// //     }
// //     return headers;
// //   }

// //   static Future<String?> getToken() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     return prefs.getString("token");
// //   }

// //   static Future<void> saveToken(String token) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.setString("token", token);
// //   }

// //   // --- Authentication ---

// //   static Future<String?> login(String email, String password) async {
// //     try {
// //       final response = await http
// //           .post(
// //             Uri.parse("$baseUrl/login"),
// //             headers: await _getHeaders(),
// //             body: jsonEncode({"email": email, "password": password}),
// //           )
// //           .timeout(const Duration(seconds: 10));

// //       if (response.statusCode == 200) {
// //         final data = jsonDecode(response.body);
// //         return data['token'];
// //       }
// //     } on SocketException {
// //       print("Network error: Check if server is running at $baseUrl");
// //     } catch (e) {
// //       print("Login Error: $e");
// //     }
// //     return null;
// //   }

// //   // ✅ FIXED: Map return karta hai — token + is_new_user dono
// //   static Future<Map<String, dynamic>?> socialLogin({
// //     required String name,
// //     required String email,
// //     required String uid,
// //     required String photo,
// //   }) async {
// //     try {
// //       final response = await http
// //           .post(
// //             Uri.parse("$baseUrl/social-login"),
// //             headers: await _getHeaders(),
// //             body: jsonEncode({
// //               "name": name,
// //               "email": email,
// //               "uid": uid,
// //               "photo": photo,
// //             }),
// //           )
// //           .timeout(const Duration(seconds: 15));

// //       print("✅ Social Login Status: ${response.statusCode}");
// //       print("✅ Social Login Body: ${response.body}");

// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         final data = jsonDecode(response.body);
// //         return {
// //           'token': data['token'],
// //           'is_new_user': data['is_new_user'] ?? false,
// //         };
// //       } else {
// //         print(
// //           "❌ Social Login Failed: ${response.statusCode} - ${response.body}",
// //         );
// //       }
// //     } catch (e) {
// //       print("Social Login Error: $e");
// //     }
// //     return null;
// //   }

// //   // --- Records ---

// //   static Future<bool> saveSalahaRecord({
// //     required int prayerIndex,
// //     required String status,
// //     String? notes,
// //     List<String>? tags,
// //   }) async {
// //     try {
// //       final prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
// //       final now = DateTime.now();

// //       final body = {
// //         "prayer_type": prayerNames[prayerIndex],
// //         "date":
// //             "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
// //         "time":
// //             "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
// //         "status": _statusToLaravel(status),
// //         "notes": notes ?? "",
// //         "reason": (tags ?? []).join(', '),
// //       };

// //       final response = await http
// //           .post(
// //             Uri.parse("$baseUrl/salaha-records"),
// //             headers: await _getHeaders(protected: true),
// //             body: jsonEncode(body),
// //           )
// //           .timeout(const Duration(seconds: 10));

// //       return response.statusCode == 200 || response.statusCode == 201;
// //     } catch (e) {
// //       print("Save Error: $e");
// //       return false;
// //     }
// //   }

// //   static String _statusToLaravel(String status) {
// //     switch (status) {
// //       case 'prayed':
// //         return 'In Jamaah';
// //       case 'excused':
// //         return 'On Time';
// //       case 'late':
// //         return 'Late';
// //       case 'missed':
// //         return 'Missed';
// //       default:
// //         return 'On Time';
// //     }
// //   }
// // }

// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class ApiService {
//   static const String baseUrl = "https://salaah-api.shahada.life/api";

//   static Future<Map<String, String>> _getHeaders({
//     bool protected = false,
//   }) async {
//     Map<String, String> headers = {
//       "Content-Type": "application/json",
//       "Accept": "application/json",
//     };

//     if (protected) {
//       String? token = await getToken();
//       if (token != null) {
//         headers["Authorization"] = "Bearer $token";
//       }
//     }
//     return headers;
//   }

//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString("token");
//   }

//   static Future<void> saveToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString("token", token);
//   }

//   static Future<String?> login(String email, String password) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse("$baseUrl/login"),
//             headers: await _getHeaders(),
//             body: jsonEncode({"email": email, "password": password}),
//           )
//           .timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['token'];
//       }
//     } on SocketException {
//       print("Network error: Check if server is running at $baseUrl");
//     } catch (e) {
//       print("Login Error: $e");
//     }
//     return null;
//   }

//   static Future<Map<String, dynamic>?> socialLogin({
//     required String name,
//     required String email,
//     required String uid,
//     required String photo,
//   }) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse("$baseUrl/social-login"),
//             headers: await _getHeaders(),
//             body: jsonEncode({
//               "name": name,
//               "email": email,
//               "uid": uid,
//               "photo": photo,
//             }),
//           )
//           .timeout(const Duration(seconds: 15));

//       print("✅ Social Login Status: ${response.statusCode}");
//       print("✅ Social Login Body: ${response.body}");

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         return {
//           'token': data['token'],
//           'is_new_user': data['is_new_user'] ?? false,
//         };
//       } else {
//         print(
//           "❌ Social Login Failed: ${response.statusCode} - ${response.body}",
//         );
//       }
//     } catch (e) {
//       print("Social Login Error: $e");
//     }
//     return null;
//   }

//   static Future<bool> saveSalahaRecord({
//     required int prayerIndex,
//     required String status,
//     String? notes,
//     List<String>? tags,
//   }) async {
//     try {
//       final prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
//       final now = DateTime.now();

//       final body = {
//         "prayer_type": prayerNames[prayerIndex],
//         "date":
//             "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
//         "time":
//             "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
//         "status": _statusToLaravel(status),
//         "notes": notes ?? "",
//         "reason": (tags ?? []).join(', '),
//       };

//       print("🔴 Sending Body: $body"); // ✅ ADDED

//       final response = await http
//           .post(
//             Uri.parse("$baseUrl/salaha-records"),
//             headers: await _getHeaders(protected: true),
//             body: jsonEncode(body),
//           )
//           .timeout(const Duration(seconds: 10));

//       print("🔴 Code: ${response.statusCode}"); // ✅ ADDED
//       print("🔴 Body: ${response.body}"); // ✅ ADDED

//       return response.statusCode == 200 || response.statusCode == 201;
//     } catch (e) {
//       print("Save Error: $e");
//       return false;
//     }
//   }

//   static String _statusToLaravel(String status) {
//     switch (status) {
//       case 'prayed':
//         return 'in_jamaah';
//       case 'excused':
//         return 'on_time';
//       case 'late':
//         return 'late';
//       case 'missed':
//         return 'missed';
//       default:
//         return 'on_time';
//     }
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://salaah-api.shahada.life/api";

  static Future<Map<String, String>> _getHeaders({
    bool protected = false,
  }) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    if (protected) {
      String? token = await getToken();
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }
    return headers;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  static Future<String?> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/login"),
            headers: await _getHeaders(),
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      }
    } on SocketException {
      print("Network error: Check if server is running at $baseUrl");
    } catch (e) {
      print("Login Error: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> socialLogin({
    required String name,
    required String email,
    required String uid,
    required String photo,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/social-login"),
            headers: await _getHeaders(),
            body: jsonEncode({
              "name": name,
              "email": email,
              "uid": uid,
              "photo": photo,
            }),
          )
          .timeout(const Duration(seconds: 15));

      print("✅ Social Login Status: ${response.statusCode}");
      print("✅ Social Login Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'token': data['token'],
          'is_new_user': data['is_new_user'] ?? false,
        };
      } else {
        print(
          "❌ Social Login Failed: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("Social Login Error: $e");
    }
    return null;
  }

  static Future<bool> saveSalahaRecord({
    required int prayerIndex,
    required String status,
    String? notes,
    List<String>? tags,
  }) async {
    try {
      final prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
      final now = DateTime.now();

      final body = {
        "prayer_type": prayerNames[prayerIndex],
        "date":
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
        "time":
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
        "status": _statusToLaravel(status),
        "notes": notes ?? "",
        "reason": (tags ?? []).join(', '),
      };

      print("🔴 Sending Body: $body");

      final response = await http
          .post(
            Uri.parse("$baseUrl/salaha-records"),
            headers: await _getHeaders(protected: true),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      print("🔴 Code: ${response.statusCode}");
      print("🔴 Body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Save Error: $e");
      return false;
    }
  }

  // ✅ FIXED: Debug logs ke saath
  static Future<List<dynamic>> getSalahaRecords() async {
    try {
      print("🌐 Calling: $baseUrl/salaha-records");
      final token = await getToken();
      print("🔑 Token: $token");

      final response = await http
          .get(
            Uri.parse("$baseUrl/salaha-records"),
            headers: await _getHeaders(protected: true),
          )
          .timeout(const Duration(seconds: 10));

      print("📡 Status Code: ${response.statusCode}");
      print("📡 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("❌ Server error: ${response.statusCode}");
      }
    } on SocketException {
      print("❌ Network error: No internet or server down");
    } catch (e) {
      print("❌ Fetch Error: $e");
    }
    return [];
  }

  static String _statusToLaravel(String status) {
    switch (status) {
      case 'prayed':
        return 'in_jamaah';
      case 'excused':
        return 'on_time';
      case 'late':
        return 'late';
      case 'missed':
        return 'missed';
      default:
        return 'on_time';
    }
  }

  static String statusFromLaravel(String status) {
    switch (status) {
      case 'in_jamaah':
        return 'prayed';
      case 'on_time':
        return 'excused';
      case 'late':
        return 'late';
      case 'missed':
        return 'missed';
      default:
        return 'none';
    }
  }
}
