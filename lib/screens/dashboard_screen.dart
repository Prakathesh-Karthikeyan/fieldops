import 'package:flutter/material.dart';

import '../core/api_service.dart';
import '../core/app_session.dart';
import 'create_ticket_screen.dart';
import 'tickets_screen.dart';
import 'visits_screen.dart';
import 'customer_service_request_screen.dart';


// ============================================================
// DASHBOARD SCREEN
// ============================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> stats = {};
  List<dynamic> tickets = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  // ==========================================================
  // LOAD DASHBOARD DATA
  // ==========================================================

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final dashboardStats = await ApiService.getDashboardStats();

      final ticketResult = await ApiService.getTickets();

      int countStatus(String status) {
        return ticketResult.where((ticket) {
          final currentStatus =
              ticket['status']?.toString().toUpperCase() ?? '';

          return currentStatus == status;
        }).length;
      }

      final normalizedStats = Map<String, dynamic>.from(dashboardStats);

      normalizedStats['open_tickets'] =
          normalizedStats['open_tickets'] ?? countStatus('OPEN');

      normalizedStats['assigned_tickets'] = countStatus('ASSIGNED');

      normalizedStats['in_progress'] = countStatus('IN PROGRESS');

      normalizedStats['resolved'] =
          normalizedStats['resolved_tickets'] ?? countStatus('RESOLVED');

      if (!mounted) return;

      setState(() {
        stats = normalizedStats;
        tickets = ticketResult;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load dashboard data.';
      });
    }
  }

  // ==========================================================
  // VALUE HELPER
  // ==========================================================

  String _value(String key, String fallback) {
    return stats[key]?.toString() ?? fallback;
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
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final userName = AppSession.user?['name']?.toString() ?? 'Technician';

    final openTickets = int.tryParse(_value('open_tickets', '0')) ?? 0;

    final highPriorityCount = tickets.where((ticket) {
      final priority = ticket['priority']?.toString().toUpperCase() ?? '';

      final status = ticket['status']?.toString().toUpperCase() ?? '';

      return priority == 'HIGH' && status != 'RESOLVED';
    }).length;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              // ==================================================
// HEADER
// ==================================================

Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF16A34A),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'FIELD OPERATIONS',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Text(
            'Good day, $userName 👋',
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Here is your field operations overview.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ],
      ),
    ),

    const SizedBox(width: 14),

    Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF2563EB),
              size: 23,
            ),
          ),

          Positioned(
            top: 9,
            right: 10,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFFDC2626),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    ),
  ],
),

const SizedBox(height: 24),
// ==================================================
// PRIMARY STATUS CARD
// ==================================================

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(22),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0F3FA8),
        Color(0xFF2563EB),
      ],
    ),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF2563EB)
            .withValues(alpha: 0.18),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.14,
              ),
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: Color(0xFF86EFAC),
                ),
                SizedBox(width: 7),
                Text(
                  'SYSTEM ONLINE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.12,
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.engineering_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),

      const SizedBox(height: 18),

      const Text(
        'Ready for field work',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.3,
        ),
      ),

      const SizedBox(height: 6),

      Text(
        openTickets == 0
            ? 'All tickets are under control. You are ready for your next task.'
            : '$openTickets open ${openTickets == 1 ? 'ticket' : 'tickets'} require attention.',
        style: const TextStyle(
          color: Color(0xFFDCE7FF),
          fontSize: 13,
          height: 1.45,
        ),
      ),

      const SizedBox(height: 18),

      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.10,
          ),
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(
              alpha: 0.12,
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              color: Colors.white,
              size: 19,
            ),

            const SizedBox(width: 9),

            const Expanded(
              child: Text(
                'Open tickets',
                style: TextStyle(
                  color: Color(0xFFDCE7FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Text(
              '$openTickets',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

const SizedBox(height: 22),
              // ==================================================
              // LOADING
              // ==================================================
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: Color(0xFFE8F0FF),
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              // ==================================================
              // ERROR
              // ==================================================

              if (errorMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(15),
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
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _loadDashboard,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Color(0xFFDC2626),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

              // ==================================================
              // OVERVIEW
              // ==================================================
              const Text(
                'Operations Overview',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 13),

              LayoutBuilder(
  builder: (context, constraints) {
    final width = constraints.maxWidth;

    final crossAxisCount = width >= 1200
        ? 4
        : width >= 700
            ? 2
            : 1;

    final cardHeight = width >= 700 ? 150.0 : 128.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: cardHeight,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final cards = [
          _statCard(
            title: 'Open Tickets',
            value: _value('open_tickets', '0'),
            icon: Icons.confirmation_number_outlined,
            color: const Color(0xFF2563EB),
          ),

          _statCard(
            title: 'Assigned',
            value: _value('assigned_tickets', '0'),
            icon: Icons.assignment_outlined,
            color: const Color(0xFFD97706),
          ),

          _statCard(
            title: 'In Progress',
            value: _value('in_progress', '0'),
            icon: Icons.pending_actions_outlined,
            color: const Color(0xFF7C3AED),
          ),

          _statCard(
            title: 'Resolved',
            value: _value('resolved', '0'),
            icon: Icons.check_circle_outline,
            color: const Color(0xFF16A34A),
          ),
        ];

        return cards[index];
      },
    );
  },
),

              const SizedBox(height: 25),

              // ==================================================
              // PRIORITY ALERT
              // ==================================================
              if (highPriorityCount > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFEDD5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.priority_high_rounded,
                          color: Color(0xFFEA580C),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'High priority attention',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF9A3412),
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              '$highPriorityCount ${highPriorityCount == 1 ? 'ticket' : 'tickets'} need immediate attention.',
                              style: const TextStyle(
                                color: Color(0xFF9A3412),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              if (highPriorityCount > 0) const SizedBox(height: 25),

              // ==================================================
              // QUICK ACTIONS
              // ==================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),

                  Text(
                    'Shortcuts',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),

              const SizedBox(height: 13),

                            Row(
                children: [
                  Expanded(
                    child: _quickAction(
                      icon: Icons.add_circle_outline_rounded,
                      title: 'New Ticket',
                      subtitle: 'Create request',
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateTicketScreen(),
                          ),
                        );

                        _loadDashboard();
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _quickAction(
                      icon: Icons.support_agent_rounded,
                      title: 'Service Request',
                      subtitle: 'Customer support',
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CustomerServiceRequestScreen(),
                          ),
                        );

                        _loadDashboard();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _quickAction(
                      icon: Icons.calendar_month_outlined,
                      title: 'Visits',
                      subtitle: 'View schedule',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VisitsScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _quickAction(
                      icon: Icons.confirmation_number_outlined,
                      title: 'Tickets',
                      subtitle: 'View all tickets',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TicketsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ==================================================
              // RECENT TICKETS
              // ==================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Tickets',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),

                  Text(
                    '${tickets.length} total',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),

              const SizedBox(height: 13),

              if (tickets.isEmpty && !isLoading) _emptyTickets(),

              if (tickets.isNotEmpty)
                ...tickets.take(3).map((ticket) {
                  final ticketData = Map<String, dynamic>.from(ticket);

                  return _recentTicket(ticketData);
                }),

              const SizedBox(height: 12),

              // ==================================================
              // CONNECTION STATUS
              // ==================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.cloud_done_outlined,
                        color: Color(0xFF16A34A),
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FieldOps API Connected',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Live data is synchronized with your workspace.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF16A34A),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // STAT CARD
  // ==========================================================

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: color),
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // QUICK ACTION
  // ==========================================================

  Widget _quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
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
                child: Icon(icon, color: const Color(0xFF2563EB), size: 21),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // RECENT TICKET
  // ==========================================================

  Widget _recentTicket(Map<String, dynamic> ticket) {
    final title = ticket['title']?.toString() ?? 'Ticket';

    final customer = ticket['customer']?.toString() ?? 'Unknown customer';

    final status = ticket['status']?.toString() ?? 'OPEN';

    final priority = ticket['priority']?.toString() ?? 'MEDIUM';

    final ticketId = ticket['id']?.toString() ?? '-';

    final statusColor = _statusColor(status);

    final priorityColor = _priorityColor(priority);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      customer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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

              const Spacer(),

              Text(
                ticketId,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _emptyTickets() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(Icons.inbox_outlined, size: 42, color: Color(0xFF94A3B8)),
          SizedBox(height: 10),
          Text(
            'No tickets available',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Create a ticket to start managing field work.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}