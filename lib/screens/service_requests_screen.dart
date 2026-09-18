import 'package:flutter/material.dart';

import '../core/api_service.dart';

// ============================================================
// CUSTOMER SERVICE REQUEST SCREEN
// ============================================================

//------------------------------------------------------

class ServiceRequestsScreen extends StatefulWidget {
  const ServiceRequestsScreen({super.key});

  @override
  State<ServiceRequestsScreen> createState() =>
      _ServiceRequestsScreenState();
}

class _ServiceRequestsScreenState
    extends State<ServiceRequestsScreen> {
  List<dynamic> requests = [];

  bool isLoading = true;
  String? errorMessage;

  String selectedStatus = 'ALL';
  String searchText = '';

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  // ==========================================================
  // LOAD REQUESTS
  // ==========================================================

  Future<void> _loadRequests() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getCustomerRequests();

      if (!mounted) return;

      setState(() {
        requests = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load service requests.';
      });
    }
  }

  // ==========================================================
  // FILTER REQUESTS
  // ==========================================================

  List<dynamic> get filteredRequests {
    final query = searchText.toLowerCase().trim();

    return requests.where((request) {
      final customer =
          request['customer']?.toString().toLowerCase() ?? '';

      final requestId =
          request['request_id']?.toString().toLowerCase() ?? '';

      final issue =
          request['issue']?.toString().toLowerCase() ?? '';

      final location =
          request['location']?.toString().toLowerCase() ?? '';

      final status =
          request['status']?.toString().toUpperCase() ?? '';

      final matchesSearch =
          query.isEmpty ||
          customer.contains(query) ||
          requestId.contains(query) ||
          issue.contains(query) ||
          location.contains(query);

      final matchesStatus =
          selectedStatus == 'ALL' ||
          status == selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // ==========================================================
  // STATUS COLOR
  // ==========================================================

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return const Color(0xFF2563EB);

      case 'CONVERTED':
        return const Color(0xFF16A34A);

      default:
        return const Color(0xFF64748B);
    }
  }

  // ==========================================================
  // PRIORITY COLOR
  // ==========================================================

  Color _priorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'CRITICAL':
        return const Color(0xFF991B1B);

      case 'HIGH':
        return const Color(0xFFDC2626);

      case 'MEDIUM':
        return const Color(0xFFD97706);

      case 'LOW':
        return const Color(0xFF16A34A);

      default:
        return const Color(0xFF64748B);
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final visibleRequests = filteredRequests;

    return SafeArea(
      child: Column(
        children: [
          // ==================================================
          // HEADER
          // ==================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              14,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FF),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: Color(0xFF2563EB),
                          size: 23,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Flexible(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Service Requests',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Customer support intake',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: isLoading ? null : _loadRequests,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A0F172A),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF2563EB),
                              ),
                            )
                          : const Icon(
                              Icons.refresh_rounded,
                              color: Color(0xFF2563EB),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // SUMMARY
          // ==================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              3,
              20,
              13,
            ),
            child: Row(
              children: [
                Text(
                  '${visibleRequests.length} '
                  '${visibleRequests.length == 1 ? 'request' : 'requests'}',
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                Text(
                  '${requests.where((r) => r['status'] == 'OPEN').length} open',
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // SEARCH
          // ==================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText:
                    'Search request, customer or location',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 21,
                ),
                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            searchText = '';
                          });
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                        ),
                      )
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 13),

          // ==================================================
          // STATUS FILTERS
          // ==================================================

          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              children: [
                _filterChip('ALL'),
                _filterChip('OPEN'),
                _filterChip('CONVERTED'),
              ],
            ),
          ),

          const SizedBox(height: 10),

          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                10,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFFECACA),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _loadRequests,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (isLoading)
            const LinearProgressIndicator(
              minHeight: 3,
            ),

          // ==================================================
          // REQUEST LIST
          // ==================================================

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : visibleRequests.isEmpty
                    ? _emptyState()
                    : RefreshIndicator(
                        onRefresh: _loadRequests,
                        child: ListView.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding:
                              const EdgeInsets.fromLTRB(
                            20,
                            6,
                            20,
                            30,
                          ),
                          itemCount: visibleRequests.length,
                          itemBuilder:
                              (context, index) {
                            final request =
                                Map<String, dynamic>.from(
                              visibleRequests[index],
                            );

                            return _requestCard(
                              request,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FILTER CHIP
  // ==========================================================

  Widget _filterChip(String status) {
    final isSelected =
        selectedStatus == status;

    final color = status == 'ALL'
        ? const Color(0xFF2563EB)
        : _statusColor(status);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedStatus = status;
          });
        },
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 180),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? color
                : Colors.white,
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? color
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF64748B),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // REQUEST CARD
  // ==========================================================

  Widget _requestCard(Map<String, dynamic> request) {
  final requestId = request['request_id']?.toString() ?? '-';
  final customer =
      request['customer']?.toString() ?? 'Unknown customer';
  final issue =
      request['issue']?.toString() ?? 'Service request';
  final location =
      request['location']?.toString() ?? 'Location unavailable';
  final serviceType =
      request['service_type']?.toString() ?? 'General Service';
  final priority =
      request['priority']?.toString() ?? 'MEDIUM';
  final status =
      request['status']?.toString() ?? 'OPEN';

  final statusColor = _statusColor(status);
  final priorityColor = _priorityColor(priority);

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: const Color(0xFFE2E8F0),
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _showRequestDetails(request);
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: Color(0xFF2563EB),
                size: 21,
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    issue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    customer,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                priority,
                style: TextStyle(
                  color: priorityColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 11),

        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 15,
              color: Color(0xFF94A3B8),
            ),

            const SizedBox(width: 5),

            Expanded(
              child: Text(
                location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                serviceType,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const Spacer(),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Text(
              requestId,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),

            const Spacer(),

            TextButton(
              onPressed: () {
                _showRequestDetails(request);
              },
              child: const Text(
                'View Details',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ],
          ),
        ),
      ),
    ),
  );
}
  // ==========================================================
  // DETAILS
  // ==========================================================

  void _showRequestDetails(
    Map<String, dynamic> request,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final status =
            request['status']?.toString() ??
                'OPEN';

        final statusColor =
            _statusColor(status);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Container(
          padding:
              const EdgeInsets.fromLTRB(
            22,
            18,
            22,
            30,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration:
                          BoxDecoration(
                        color: const Color(
                          0xFFE2E8F0,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Request Details',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.w800,
                            color:
                                Color(0xFF0F172A),
                          ),
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color: statusColor
                              .withValues(
                            alpha: 0.10,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            8,
                          ),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  _detailRow(
                    Icons.confirmation_number_outlined,
                    'Request ID',
                    request['request_id']
                            ?.toString() ??
                        '-',
                  ),

                  _detailRow(
                    Icons.person_outline_rounded,
                    'Customer',
                    request['customer']
                            ?.toString() ??
                        '-',
                  ),

                  _detailRow(
                    Icons.phone_outlined,
                    'Phone',
                    request['phone']
                            ?.toString() ??
                        '-',
                  ),

                  _detailRow(
                    Icons.location_on_outlined,
                    'Location',
                    request['location']
                            ?.toString() ??
                        '-',
                  ),

                  _detailRow(
                    Icons.category_outlined,
                    'Service Type',
                    request['service_type']
                            ?.toString() ??
                        '-',
                  ),

                  _detailRow(
                    Icons.flag_outlined,
                    'Priority',
                    request['priority']
                            ?.toString() ??
                        '-',
                  ),

                  _detailRow(
                    Icons.report_problem_outlined,
                    'Issue',
                    request['issue']
                            ?.toString() ??
                        '-',
                  ),

                  _detailRow(
                    Icons.description_outlined,
                    'Description',
                    request['description']
                            ?.toString()
                            .isNotEmpty ==
                        true
                        ? request['description']
                              .toString()
                        : 'No additional description',
                  ),

                  const SizedBox(height: 15),

                  if (status == 'OPEN')
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: () async {
  final requestId =
      request['request_id']?.toString();

  if (requestId == null || requestId.isEmpty) {
    return;
  }

  Navigator.pop(context);

  try {
    final result =
        await ApiService.createTicketFromCustomerRequest(
      requestId,
    );

    if (!mounted) return;

    final ticket = result['ticket'];
    final ticketId =
        ticket is Map
            ? ticket['id']?.toString() ?? ''
            : '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ticketId.isNotEmpty
              ? 'Ticket $ticketId created successfully.'
              : 'Ticket created successfully.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    await _loadRequests();
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Unable to convert request to ticket.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
},
                        icon: const Icon(
                          Icons.confirmation_number_outlined,
                        ),
                        label: const Text(
                          'Convert to Ticket',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // DETAIL ROW
  // ==========================================================

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 19, color: const Color(0xFF2563EB)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _emptyState() {
    final isSearching = searchText.trim().isNotEmpty;

    final isFiltering = selectedStatus != 'ALL';

    String title;
    String subtitle;

    if (isSearching || isFiltering) {
      title = 'No matching requests';
      subtitle = 'Try changing your search or status filter.';
    } else {
      title = 'No service requests';
      subtitle = 'Customer service requests will appear here.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FF),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 34,
                color: Color(0xFF2563EB),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF334155),
              ),
            ),

            const SizedBox(height: 5),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),

            if (isSearching || isFiltering)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      searchText = '';
                      selectedStatus = 'ALL';
                    });
                  },
                  child: const Text('Clear filters'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
