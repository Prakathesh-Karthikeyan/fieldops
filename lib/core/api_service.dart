import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_session.dart';

// ============================================================
// API SERVICE
// ============================================================

class ApiService {
  static const String baseUrl = 'http://192.168.0.98:8000';

  // ---------------- LOGIN ----------------

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }

      throw Exception('Invalid login response');
    }

    throw Exception('Invalid email or password');
  }

  // ---------------- GET TICKETS ----------------

  static Future<List<dynamic>> getTickets() async {
    final response = await http.get(Uri.parse('$baseUrl/api/tickets'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      throw Exception('Invalid ticket data');
    }

    throw Exception('Failed to load tickets');
  }

  // ---------------- DASHBOARD ----------------

  static Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await http.get(Uri.parse('$baseUrl/api/dashboard/stats'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }

      throw Exception('Invalid dashboard data');
    }

    throw Exception('Failed to load dashboard statistics');
  }

  // ---------------- CREATE TICKET ----------------

  static Future<Map<String, dynamic>> createTicket({
    required String title,
    required String customer,
    required String location,
    required String priority,
    required String scheduledTime,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/tickets'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'customer': customer,
        'location': location,
        'priority': priority,
        'technician': AppSession.user?['name']?.toString() ?? 'Technician',
        'scheduled_time': scheduledTime,
        'description': description,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }

      return {};
    }

    throw Exception('Failed to create ticket');
  }

// ---------------- UPDATE STATUS ----------------

static Future<Map<String, dynamic>> updateTicketStatus(
  String ticketId,
  String status,
) async {
  final encodedId = Uri.encodeComponent(ticketId);

  final uri = Uri.parse(
    '$baseUrl/api/tickets/$encodedId/status',
  ).replace(
    queryParameters: {
      'status': status,
    },
  );

  final response = await http.patch(uri);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }

  throw Exception(
    'Failed to update ticket status',
  );
}

// ============================================================
// ASSIGN TICKET TO TECHNICIAN
// ============================================================

static Future<Map<String, dynamic>> updateTicketTechnician(
  String ticketId,
  String technician,
) async {
  final encodedId = Uri.encodeComponent(ticketId);

  final response = await http.patch(
    Uri.parse(
      '$baseUrl/api/tickets/$encodedId/technician',
    ),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'technician': technician,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }

  throw Exception(
    'Failed to assign ticket to technician',
  );
}

  // ---------------- UPDATE RESOLUTION ----------------

  static Future<Map<String, dynamic>> updateTicketResolution(
    String ticketId,
    String resolution,
  ) async {
    final encodedId = Uri.encodeComponent(ticketId);

    final response = await http.patch(
      Uri.parse('$baseUrl/api/tickets/$encodedId/resolution'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'resolution': resolution}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }

      return {};
    }

        throw Exception('Failed to update resolution');
  }

  // ---------------- GET VISITS ----------------

  static Future<List<dynamic>> getVisits() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/visits'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      throw Exception('Invalid visit data');
    }

    throw Exception('Failed to load visits');
  }


    // ---------------- CREATE CUSTOMER REQUEST ----------------

  static Future<Map<String, dynamic>> createCustomerRequest({
    required String customer,
    required String phone,
    required String location,
    required String serviceType,
    required String priority,
    required String issue,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/customer-requests'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'customer': customer,
        'phone': phone,
        'location': location,
        'service_type': serviceType,
        'priority': priority,
        'issue': issue,
        'description': description,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }

      throw Exception('Invalid customer request response');
    }

    throw Exception(
      'Failed to create customer request',
    );
  }

    static Future<List<dynamic>> getCustomerRequests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/customer-requests'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      if (data is Map<String, dynamic> && data['requests'] is List) {
        return data['requests'];
      }

      throw Exception('Invalid customer requests response');
    }

    throw Exception('Failed to load customer requests');
  }


  // ---------------- CREATE VISIT ----------------

  static Future<Map<String, dynamic>> createVisit({
    required String customer,
    required String location,
    required String scheduledTime,
    required String serviceType,
    required String contact,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/visits'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'customer': customer,
        'location': location,
        'scheduled_time': scheduledTime,
        'service_type': serviceType,
        'technician':
            AppSession.user?['name']?.toString() ?? 'Technician',
        'contact': contact,
        'description': description,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }

      return {};
    }

    throw Exception('Failed to create visit');
  }

    // ---------------- CREATE TICKET FROM CUSTOMER REQUEST ----------------

  static Future<Map<String, dynamic>>
      createTicketFromCustomerRequest(
    String requestId,
  ) async {
    final encodedRequestId =
        Uri.encodeComponent(requestId);

    final response = await http.post(
      Uri.parse(
        '$baseUrl/api/customer-requests/'
        '$encodedRequestId/create-ticket',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }

      throw Exception(
        'Invalid ticket creation response',
      );
    }

    throw Exception(
      'Failed to create ticket from customer request',
    );
  }


  // ---------------- UPDATE VISIT STATUS ----------------

  static Future<Map<String, dynamic>> updateVisitStatus(
    String visitId,
    String status,
  ) async {
    final encodedId = Uri.encodeComponent(visitId);

    final response = await http.patch(
      Uri.parse('$baseUrl/api/visits/$encodedId/status'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }

      return {};
    }

    throw Exception('Failed to update visit status');
  }
}

