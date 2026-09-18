import 'package:flutter/material.dart';

import '../core/api_service.dart';
import 'create_ticket_screen.dart';

// ============================================================
// TICKETS SCREEN
// ============================================================

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  List<dynamic> tickets = [];

  bool isLoading = true;

  String searchText = '';

  String selectedStatus = 'ALL';

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  // ==========================================================
  // LOAD TICKETS
  // ==========================================================

  Future<void> _loadTickets() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final result = await ApiService.getTickets();

      if (!mounted) return;

      setState(() {
        tickets = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load tickets.';
      });
    }
  }

  // ==========================================================
  // FILTER TICKETS
  // ==========================================================

  List<dynamic> get filteredTickets {
    final query = searchText.toLowerCase().trim();

    return tickets.where((ticket) {
      final title = ticket['title']?.toString().toLowerCase() ?? '';

      final customer = ticket['customer']?.toString().toLowerCase() ?? '';

      final ticketId = ticket['id']?.toString().toLowerCase() ?? '';

      final location = ticket['location']?.toString().toLowerCase() ?? '';

      final status = ticket['status']?.toString().toUpperCase() ?? '';

      final matchesSearch =
          query.isEmpty ||
          title.contains(query) ||
          customer.contains(query) ||
          ticketId.contains(query) ||
          location.contains(query);

      final matchesStatus = selectedStatus == 'ALL' || status == selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // ==========================================================
  // PRIORITY COLOR
  // ==========================================================

  Color _priorityColor(String priority) {
    switch (priority.toUpperCase()) {
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
  // STATUS COLOR
  // ==========================================================

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return const Color(0xFF2563EB);

      case 'ASSIGNED':
        return const Color(0xFFD97706);

      case 'IN PROGRESS':
        return const Color(0xFF7C3AED);

      case 'RESOLVED':
        return const Color(0xFF16A34A);

      default:
        return const Color(0xFF64748B);
    }
  }

  // ==========================================================
  // STATUS ICON
  // ==========================================================

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return Icons.radio_button_checked_rounded;

      case 'ASSIGNED':
        return Icons.assignment_ind_outlined;

      case 'IN PROGRESS':
        return Icons.pending_actions_rounded;

      case 'RESOLVED':
        return Icons.check_circle_outline_rounded;

      default:
        return Icons.help_outline_rounded;
    }
  }

  // ==========================================================
  // SHOW DETAILS
  // ==========================================================

  void _showTicketDetails(BuildContext context, Map<String, dynamic> ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _TicketDetailsSheet(
          ticket: ticket,
          statusColor: _statusColor,
          priorityColor: _priorityColor,
          onUpdated: () async {
            await _loadTickets();
          },
        );
      },
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final visibleTickets = filteredTickets;


    return Material(
  color: const Color(0xFFF6F8FC),
  child: SafeArea(
    child: Column(
        children: [
          // ====================================================
          // HEADER
          // ====================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                          Icons.confirmation_number_outlined,
                          color: Color(0xFF2563EB),
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Tickets',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Field support operations',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
               Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    FilledButton.icon(
      onPressed: isLoading
          ? null
          : () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateTicketScreen(),
                ),
              );

              if (mounted) {
                await _loadTickets();
              }
            },
      icon: const Icon(
        Icons.add_rounded,
        size: 19,
      ),
      label: const Text(
        'New Ticket',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFE2E8F0),
        disabledForegroundColor: const Color(0xFF94A3B8),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        elevation: 0,
      ),
    ),

    const SizedBox(width: 8),

    Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: isLoading ? null : _loadTickets,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
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
                  size: 21,
                ),
            ),
          ),
        ),
       ],
    ),
  ],
),
          ),
          // SUMMARY
          // ====================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 14),
            child: Row(
              children: [
                Text(
                  '${visibleTickets.length} '
                  '${visibleTickets.length == 1 ? 'ticket' : 'tickets'}',
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                if (selectedStatus != 'ALL')
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedStatus = 'ALL';
                      });
                    },
                    child: const Row(
                      children: [
                        Icon(
                          Icons.filter_alt_off_outlined,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Clear filter',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ====================================================
          // SEARCH
          // ====================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by ticket, customer, ID or location',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF64748B),
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
                          color: Color(0xFF64748B),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 13),

          // ====================================================
          // STATUS FILTERS
          // ====================================================
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _statusFilter('ALL'),
                _statusFilter('OPEN'),
                _statusFilter('ASSIGNED'),
                _statusFilter('IN PROGRESS'),
                _statusFilter('RESOLVED'),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ====================================================
          // ERROR
          // ====================================================
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFFECACA)),
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
                      onPressed: _loadTickets,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Color(0xFFDC2626),
                        size: 19,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ====================================================
          // LOADING
          // ====================================================
          if (isLoading) const LinearProgressIndicator(minHeight: 3),

          // ====================================================
          // TICKET LIST
          // ====================================================
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : visibleTickets.isEmpty
                ? _emptyState()
                : RefreshIndicator(
                    onRefresh: _loadTickets,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
                      itemCount: visibleTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = Map<String, dynamic>.from(
                          visibleTickets[index],
                        );

                        return _ticketCard(ticket);
                      },
                    ),
                  ),
          ),
         ],
       ),
    ),
  );
  }

  // ==========================================================
  // STATUS FILTER CHIP
  // ==========================================================

  Widget _statusFilter(String status) {
    final isSelected = selectedStatus == status;

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
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF475569),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
                                                                   ),
                     ),
                   ),
                 ),
               );
           
  }
            
           
  // ==========================================================
  // TICKET CARD
  // ==========================================================

  Widget _ticketCard(Map<String, dynamic> ticket) {
    final title = ticket['title']?.toString() ?? 'Ticket';

    final customer = ticket['customer']?.toString() ?? 'Unknown customer';

    final location = ticket['location']?.toString() ?? '-';

    final priority = ticket['priority']?.toString() ?? 'MEDIUM';

    final status = ticket['status']?.toString() ?? 'OPEN';

    final ticketId = ticket['id']?.toString() ?? '-';

    final scheduledTime = ticket['scheduled_time']?.toString() ?? '';

    final priorityColor = _priorityColor(priority);

    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showTicketDetails(context, ticket);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==============================================
                // TOP ROW
                // ==============================================

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FF),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.confirmation_number_outlined,
                        color: Color(0xFF2563EB),
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            customer,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: priorityColor,
                              shape: BoxShape.circle,
                            ),
                          ),

                          const SizedBox(width: 5),

                          Text(
                            priority,
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 13),

                // ==============================================
                // LOCATION
                // ==============================================
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 17,
                      color: Color(0xFF64748B),
                    ),

                    const SizedBox(width: 7),

                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                if (scheduledTime.isNotEmpty) const SizedBox(height: 8),

                if (scheduledTime.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        scheduledTime,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 12),

                // ==============================================
                // BOTTOM ROW
                // =========================================
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _statusIcon(status),
                            size: 13,
                            color: statusColor,
                          ),

                          const SizedBox(width: 5),

                          Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    Text(
                      '#$ticketId',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(width: 8),

                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: Color(0xFF94A3B8),
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
  // EMPTY STATE
  // ==========================================================

  Widget _emptyState() {
    final isSearching = searchText.trim().isNotEmpty;

    final isFiltering = selectedStatus != 'ALL';

    String title;
    String subtitle;

    if (isSearching || isFiltering) {
      title = 'No matching tickets';
      subtitle = 'Try changing your search or status filter.';
    } else {
      title = 'No tickets available';
      subtitle = 'Create a ticket to start managing field work.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                size: 34,
                color: Color(0xFF2563EB),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                height: 1.4,
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

// ============================================================
// TICKET DETAILS
// ============================================================

class _TicketDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> ticket;

  final Color Function(String) statusColor;
  final Color Function(String) priorityColor;
  final Future<void> Function() onUpdated;

  const _TicketDetailsSheet({
    required this.ticket,
    required this.statusColor,
    required this.priorityColor,
    required this.onUpdated,
  });

  @override
  State<_TicketDetailsSheet> createState() =>
      _TicketDetailsSheetState();
}

class _TicketDetailsSheetState
    extends State<_TicketDetailsSheet> {
  late String selectedStatus;
late TextEditingController resolutionController;

bool isUpdatingStatus = false;
bool isSavingResolution = false;

final List<String> ticketStatuses = [
  'OPEN',
  'ASSIGNED',
  'IN PROGRESS',
  'RESOLVED',
];

bool isAssigningTechnician = false;

late String selectedTechnician;

final List<String> technicians = [
  'Prakathesh',
  'Arun',
  'Karthik',
  'Suresh',
];

  final List<String> statuses = [
    'OPEN',
    'ASSIGNED',
    'IN PROGRESS',
    'RESOLVED',
  ];

  @override
  void initState() {
    super.initState();

    final currentStatus =
    widget.ticket['status']?.toString().toUpperCase() ??
        'OPEN';

selectedStatus =
    statuses.contains(currentStatus)
        ? currentStatus
        : 'OPEN';

final currentTechnician =
    widget.ticket['technician']?.toString().trim() ?? '';

selectedTechnician =
    technicians.contains(currentTechnician)
        ? currentTechnician
        : 'Prakathesh';

resolutionController = TextEditingController(
  text: widget.ticket['resolution']?.toString() ?? '',
);
  }

  // ==========================================================
  // UPDATE STATUS
  // ==========================================================

  Future<void> _updateStatus(String newStatus) async {
    if (newStatus == selectedStatus) {
      return;
    }

    final ticketId =
        widget.ticket['id']?.toString() ?? '';

    if (ticketId.isEmpty) {
      return;
    }

    if (newStatus == 'RESOLVED' &&
    resolutionController.text.trim().isEmpty) {
  _showMessage(
    'Please enter resolution notes before resolving the ticket.',
  );
  return;
}

    setState(() {
      isUpdatingStatus = true;
    });

    try {
      await ApiService.updateTicketStatus(
        ticketId,
        newStatus,
      );

      if (!mounted) return;

      setState(() {
        selectedStatus = newStatus;
      });

      await widget.onUpdated();

      if (!mounted) return;

      _showMessage(
        'Ticket status updated to $newStatus',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to update ticket status.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isUpdatingStatus = false;
        });
      }
    }
  }

  // ==========================================================
  // SAVE RESOLUTION
  // ==========================================================

  Future<void> _saveResolution() async {
    final ticketId =
        widget.ticket['id']?.toString() ?? '';

    if (ticketId.isEmpty) {
      return;
    }

    setState(() {
      isSavingResolution = true;
    });

    try {
      await ApiService.updateTicketResolution(
        ticketId,
        resolutionController.text.trim(),
      );

      if (!mounted) return;

      await widget.onUpdated();

      if (!mounted) return;

      _showMessage(
        'Resolution saved successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to save resolution.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSavingResolution = false;
        });
      }
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    resolutionController.dispose();
    super.dispose();
  }

    // ==========================================================
  // ASSIGN TECHNICIAN
  // ==========================================================

  Future<void> _assignTechnician() async {
    final ticketId =
        widget.ticket['id']?.toString() ?? '';

    if (ticketId.isEmpty) {
      return;
    }

    setState(() {
      isAssigningTechnician = true;
    });

    try {
      await ApiService.updateTicketTechnician(
        ticketId,
        selectedTechnician,
      );

      if (!mounted) return;

      await widget.onUpdated();

      if (!mounted) return;

      _showMessage(
        'Ticket assigned to $selectedTechnician.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to assign technician.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isAssigningTechnician = false;
        });
      }
    }
  }
    


  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final ticketId =
        widget.ticket['id']?.toString() ?? '-';

    final title =
        widget.ticket['title']?.toString() ?? 'Ticket';

    final customer =
        widget.ticket['customer']?.toString() ?? '-';

    final location =
        widget.ticket['location']?.toString() ?? '-';

    final priority =
        widget.ticket['priority']?.toString() ?? 'MEDIUM';

    final scheduledTime =
        widget.ticket['time']?.toString() ??
            widget.ticket['scheduled_time']?.toString() ??
            '-';

    final description =
        widget.ticket['description']?.toString() ??
            'No description available.';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Container(
  constraints: BoxConstraints(
    maxHeight: MediaQuery.of(context).size.height * 0.92,
  ),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // SHEET HEADER
            // ==================================================

           Padding(
  padding: const EdgeInsets.fromLTRB(
    20,
    10,
    12,
    8,
  ),
  child: Row(
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F0FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.confirmation_number_outlined,
          color: Color(0xFF2563EB),
          size: 21,
        ),
      ),
      const SizedBox(width: 12),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ticket Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Manage ticket information',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.close_rounded,
          color: Color(0xFF475569),
        ),
      ),
    ],
  ),
),

            // ==================================================
            // CONTENT
            // ==================================================

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  5,
                  20,
                  30,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // PREMIUM TICKET HEADER
                    // ==================================================

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              const Color(0xFFE2E8F0),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A0F172A),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFEFF6FF),
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.confirmation_number_rounded,
                              color:
                                  Color(0xFF2563EB),
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight:
                                        FontWeight.w800,
                                    color:
                                        Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  ticketId,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.w700,
                                    color:
                                        Color(0xFF64748B),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // PRIORITY + STATUS
                    // ==================================================

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: widget
                                      .priorityColor(
                                priority,
                              ).withValues(alpha: 0.08),
                              borderRadius:
                                  BorderRadius.circular(14),
                              border: Border.all(
                                color: widget
                                    .priorityColor(
                                  priority,
                                ).withValues(alpha: 0.18),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.flag_rounded,
                                  size: 18,
                                  color: widget
                                      .priorityColor(
                                    priority,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'PRIORITY',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight:
                                              FontWeight.w800,
                                          color:
                                              Color(0xFF64748B),
                                          letterSpacing: 0.7,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        priority,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight:
                                              FontWeight.w800,
                                          color: widget
                                              .priorityColor(
                                            priority,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: widget
                                      .statusColor(
                                selectedStatus,
                              ).withValues(alpha: 0.08),
                              borderRadius:
                                  BorderRadius.circular(14),
                              border: Border.all(
                                color: widget
                                    .statusColor(
                                  selectedStatus,
                                ).withValues(alpha: 0.18),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons
                                      .radio_button_checked_rounded,
                                  size: 18,
                                  color: widget
                                      .statusColor(
                                    selectedStatus,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'STATUS',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight:
                                              FontWeight.w800,
                                          color:
                                              Color(0xFF64748B),
                                          letterSpacing: 0.7,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        selectedStatus,
                                        overflow:
                                            TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight:
                                              FontWeight.w800,
                                          color: widget
                                              .statusColor(
                                            selectedStatus,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // TICKET INFORMATION
                    // ==================================================

                    _detailRow(
                      Icons.business_outlined,
                      'Customer',
                      customer,
                    ),

                    _detailRow(
                      Icons.location_on_outlined,
                      'Location',
                      location,
                    ),

                    // ==================================================
// TECHNICIAN ASSIGNMENT
// ==================================================

const Text(
  'Assigned Technician',
  style: TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: Color(0xFF0F172A),
  ),
),

const SizedBox(height: 10),

Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 4,
  ),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: const Color(0xFFE2E8F0),
    ),
  ),
  child: DropdownButtonHideUnderline(
    child: DropdownButton<String>(
      value: selectedTechnician,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF2563EB),
      ),
      items: technicians.map((technicianName) {
        return DropdownMenuItem<String>(
          value: technicianName,
          child: Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 20,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(width: 10),
              Text(
                technicianName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: isAssigningTechnician
          ? null
          : (value) {
              if (value == null) return;

              setState(() {
                selectedTechnician = value;
              });
            },
    ),
  ),
),

const SizedBox(height: 10),

SizedBox(
  width: double.infinity,
  height: 48,
  child: OutlinedButton.icon(
    onPressed: isAssigningTechnician
        ? null
        : _assignTechnician,
    icon: isAssigningTechnician
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        : const Icon(
            Icons.assignment_turned_in_outlined,
          ),
    label: Text(
      isAssigningTechnician
          ? 'Assigning...'
          : 'Assign Technician',
    ),
  ),
),

const SizedBox(height: 15),

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      'Scheduled Visit',
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F172A),
      ),
    ),
    const SizedBox(height: 3),
    const Text(
      'Scheduled date and time for the field visit',
      style: TextStyle(
        fontSize: 11,
        color: Color(0xFF64748B),
        fontWeight: FontWeight.w500,
      ),
    ),
    const SizedBox(height: 10),
    _detailRow(
      Icons.schedule_outlined,
      'Date & Time',
      scheduledTime,
    ),
  ],
),

                    const SizedBox(height: 8),

                    // ==================================================
                    // TICKET STATUS
                    // ==================================================

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      'Ticket Status',
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F172A),
      ),
    ),
    const SizedBox(height: 3),
    const Text(
      'Update the current status of this ticket',
      style: TextStyle(
        fontSize: 11,
        color: Color(0xFF64748B),
        fontWeight: FontWeight.w500,
      ),
    ),
  ],
),

                    const SizedBox(height: 10),
// STATUS WORKFLOW
Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 14,
  ),
  decoration: BoxDecoration(
    color: const Color(0xFFF8FAFC),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: const Color(0xFFE2E8F0),
    ),
  ),
  child: Row(
    children: [
      _statusStep('OPEN', 0),
      _statusLine(0),
      _statusStep('ASSIGNED', 1),
      _statusLine(1),
      _statusStep('IN PROGRESS', 2),
      _statusLine(2),
      _statusStep('RESOLVED', 3),
    ],
  ),
),

const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              const Color(0xFFE2E8F0),
                        ),
                      ),
                      child:
                          DropdownButtonHideUnderline(
                        child:
                            DropdownButton<String>(
                          value: selectedStatus,
                          isExpanded: true,
                          items: ticketStatuses.map(
                            (status) {
                              return DropdownMenuItem<
                                  String>(
                                value: status,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration:
                                          BoxDecoration(
                                        color: widget
                                            .statusColor(
                                          status,
                                        ),
                                        shape:
                                            BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(
                                        width: 10),
                                    Text(
                                      status,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ).toList(),
                          onChanged: isUpdatingStatus
    ? null
    : (value) {
        if (value == null) {
          return;
        }

        final currentIndex =
            ticketStatuses.indexOf(selectedStatus);

        final newIndex =
            ticketStatuses.indexOf(value);

        if (newIndex > currentIndex + 1) {
          _showMessage(
            'Please follow the ticket workflow in order.',
          );
          return;
        }

        _updateStatus(value);
      },
                        ),
                      ),
                    ),

                    if (isUpdatingStatus)
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 10),
                        child:
                            LinearProgressIndicator(),
                      ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // ISSUE DESCRIPTION
                    // ==================================================

                     Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      'Issue Description',
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F172A),
      ),
    ),
    const SizedBox(height: 3),
    const Text(
      'Details provided for this service ticket',
      style: TextStyle(
        fontSize: 11,
        color: Color(0xFF64748B),
        fontWeight: FontWeight.w500,
      ),
    ),
  ],
),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFEFF6FF),
                              borderRadius:
                                  BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              color:
                                  Color(0xFF2563EB),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Text(
                              description,
                              style: const TextStyle(
                                color:
                                    Color(0xFF475569),
                                fontSize: 14,
                                height: 1.6,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // RESOLUTION
                    // ==================================================

                    Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      'Resolution Notes',
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F172A),
      ),
    ),
    const SizedBox(height: 3),
    const Text(
      'Add notes about how the issue was resolved',
      style: TextStyle(
        fontSize: 11,
        color: Color(0xFF64748B),
        fontWeight: FontWeight.w500,
      ),
    ),
  ],
),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller:
                                resolutionController,
                            maxLines: 5,
                            decoration:
                                const InputDecoration(
                              hintText:
                                  'Enter resolution notes...',
                              border:
                                  InputBorder.none,
                              contentPadding:
                                  EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton.icon(
                              onPressed:
                                  isSavingResolution
                                      ? null
                                      : _saveResolution,
                              icon: isSavingResolution
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:
                                            Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.save_rounded,
                                    ),
                              label: Text(
                                isSavingResolution
                                    ? 'Saving...'
                                    : 'Save Resolution',
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // CLOSE
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                        label: const Text(
                          'Close',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }



  Widget _statusStep(String status, int index) {
  final currentIndex = ticketStatuses.indexOf(selectedStatus);

  final isCompleted = index < currentIndex;
  final isCurrent = index == currentIndex;

  final color = isCompleted || isCurrent
      ? const Color(0xFF2563EB)
      : const Color(0xFFCBD5E1);

  return Expanded(
    child: Column(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isCompleted || isCurrent
                ? color
                : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 1.5,
            ),
          ),
          child: Icon(
            isCompleted
                ? Icons.check_rounded
                : isCurrent
                    ? Icons.circle
                    : Icons.circle_outlined,
            size: isCurrent ? 8 : 13,
            color: isCompleted || isCurrent
                ? Colors.white
                : color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          status,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 8,
            fontWeight:
                isCurrent ? FontWeight.w800 : FontWeight.w600,
            color: isCurrent
                ? const Color(0xFF2563EB)
                : const Color(0xFF64748B),
          ),
        ),
      ],
    ),
  );
}

Widget _statusLine(int index) {
  final currentIndex = ticketStatuses.indexOf(selectedStatus);
  final isCompleted = index < currentIndex;

  return Expanded(
    child: Container(
      height: 2,
      margin: const EdgeInsets.only(
        bottom: 25,
      ),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFF2563EB)
            : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
