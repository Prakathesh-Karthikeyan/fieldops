import 'package:flutter/material.dart';

import '../core/api_service.dart';

// ============================================================
// VISITS SCREEN
// ============================================================

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({super.key});


  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  String selectedFilter = 'ALL';

  List<Map<String, dynamic>> visits = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await ApiService.getVisits();

      if (!mounted) return;

      setState(() {
        visits = data.map<Map<String, dynamic>>((visit) {
          final scheduledTime =
              visit['scheduled_time']?.toString() ?? '-';

          return {
            ...visit,
            'time': scheduledTime,
            'type':
                visit['service_type']?.toString() ?? 'Field Service',
          };
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load visits';
      });
    }
  }

  List<Map<String, dynamic>> get filteredVisits {
    if (selectedFilter == 'ALL') {
      return visits;
    }

    return visits.where((visit) {
      return visit['status'].toString().toUpperCase() == selectedFilter;
    }).toList();
  }

  int get upcomingCount {
    return visits.where((visit) => visit['status'] == 'UPCOMING').length;
  }

  int get completedCount {
    return visits.where((visit) => visit['status'] == 'COMPLETED').length;
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'UPCOMING':
        return const Color(0xFF2563EB);
      case 'COMPLETED':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _visitIcon(String type) {
    final value = type.toLowerCase();

    if (value.contains('installation')) {
      return Icons.build_circle_outlined;
    }

    if (value.contains('maintenance')) {
      return Icons.handyman_outlined;
    }

    if (value.contains('vpn')) {
      return Icons.vpn_key_outlined;
    }

    if (value.contains('network')) {
      return Icons.router_outlined;
    }

    return Icons.location_on_outlined;
  }

      void _showVisitDetails(Map<String, dynamic> visit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _VisitDetailsSheet(
          visit: visit,
          onUpdated: () async {
            await _loadVisits();
          },
        );
      },
    );
  }

  void _showAddVisit() {
    final customerController = TextEditingController();
    final locationController = TextEditingController();
    final timeController = TextEditingController();
    final serviceController = TextEditingController();
    final contactController = TextEditingController();
    final descriptionController = TextEditingController();

    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> saveVisit() async {
              if (customerController.text.trim().isEmpty ||
                  locationController.text.trim().isEmpty ||
                  timeController.text.trim().isEmpty ||
                  serviceController.text.trim().isEmpty) {
                ScaffoldMessenger.of(sheetContext).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please fill all required fields.',
                    ),
                  ),
                );
                return;
              }

              setModalState(() {
                isSaving = true;
              });

              try {
                await ApiService.createVisit(
                  customer: customerController.text.trim(),
                  location: locationController.text.trim(),
                  scheduledTime: timeController.text.trim(),
                  serviceType: serviceController.text.trim(),
                  contact: contactController.text.trim(),
                  description: descriptionController.text.trim(),
                );

                if (!mounted) return;

await _loadVisits();

if (!mounted) return;

if (sheetContext.mounted) {
  Navigator.of(sheetContext).pop();
}
              } catch (e) {
                if (sheetContext.mounted) {
                  setModalState(() {
                    isSaving = false;
                  });

                  ScaffoldMessenger.of(sheetContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Failed to create visit.',
                      ),
                    ),
                  );
                }
              }
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    22,
                    18,
                    22,
                    28,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Add Visit',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Schedule a new field service visit',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),

                      const SizedBox(height: 22),

                      TextField(
                        controller: customerController,
                        decoration: const InputDecoration(
                          labelText: 'Customer *',
                          hintText: 'Enter customer name',
                          prefixIcon: Icon(
                            Icons.business_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location *',
                          hintText: 'Enter visit location',
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
  controller: timeController,
  readOnly: true,
  onTap: () async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );
    if (!mounted) return;
    if (selectedDate == null) return;

    if (!sheetContext.mounted) return;

final selectedTime = await showTimePicker(
  context: sheetContext,
  initialTime: TimeOfDay.now(),
);

    if (selectedTime == null) return;

    final scheduledDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final hour = selectedTime.hourOfPeriod == 0
        ? 12
        : selectedTime.hourOfPeriod;

    final minute =
        selectedTime.minute.toString().padLeft(2, '0');

    final period =
        selectedTime.period == DayPeriod.am ? 'AM' : 'PM';

    timeController.text =
        '${scheduledDateTime.day.toString().padLeft(2, '0')}/'
        '${scheduledDateTime.month.toString().padLeft(2, '0')}/'
        '${scheduledDateTime.year} '
        '$hour:$minute $period';

    setModalState(() {});
  },
  decoration: const InputDecoration(
    labelText: 'Scheduled Time *',
    hintText: 'Select date and time',
    prefixIcon: Icon(
      Icons.schedule_outlined,
    ),
    suffixIcon: Icon(
      Icons.calendar_month_outlined,
    ),
  ),
),

                      const SizedBox(height: 14),

                      TextField(
                        controller: serviceController,
                        decoration: const InputDecoration(
                          labelText: 'Service Type *',
                          hintText:
                              'Installation / Maintenance / Support',
                          prefixIcon: Icon(
                            Icons.build_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: contactController,
                        decoration: const InputDecoration(
                          labelText: 'Contact',
                          hintText: '+91 XXXXX XXXXX',
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Describe the visit',
                          prefixIcon: Icon(
                            Icons.description_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed:
                              isSaving ? null : saveVisit,
                          icon: isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_rounded,
                                ),
                          label: Text(
                            isSaving
                                ? 'Creating Visit...'
                                : 'Create Visit',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
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
      },
    ).then((_) {
      customerController.dispose();
      locationController.dispose();
      timeController.dispose();
      serviceController.dispose();
      contactController.dispose();
      descriptionController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleVisits = filteredVisits;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================
          // HEADER
          // ==================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Field Operations',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Visits',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: _showAddVisit,
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 19,
                  ),
                  label: const Text(
                    'Add Visit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // TODAY SUMMARY CARD
          // ==================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'TODAY\'S SCHEDULE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Field visits',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$upcomingCount upcoming • '
                          '$completedCount completed',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.13),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      color: Colors.white,
                      size: 31,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==================================================
          // FILTERS
          // ==================================================
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _filterChip('ALL'),
                _filterChip('UPCOMING'),
                _filterChip('COMPLETED'),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ==================================================
          // COUNT
          // ==================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '${visibleVisits.length} '
                  '${visibleVisits.length == 1 ? 'visit' : 'visits'}',
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Today',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          if (isLoading) const LinearProgressIndicator(minHeight: 3),

          // ==================================================
          // VISIT LIST
          // ==================================================
         Expanded(
  child: isLoading
      ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2563EB),
          ),
        )
      : errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 42,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _loadVisits,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : visibleVisits.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _loadVisits,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
                    itemCount: visibleVisits.length,
                    itemBuilder: (context, index) {
                      final visit = visibleVisits[index];
                      return _visitCard(visit);
                    },
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String filter) {
    final isSelected = selectedFilter == filter;

    final color = filter == 'ALL'
        ? const Color(0xFF2563EB)
        : _statusColor(filter);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = filter;
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
            filter,
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

  Widget _visitCard(Map<String, dynamic> visit) {
  final customer = visit['customer']?.toString() ?? '-';
  final location = visit['location']?.toString() ?? '-';
  final time = visit['time']?.toString() ?? '-';
  final type = visit['type']?.toString() ?? 'Field Service';
  final status = visit['status']?.toString() ?? 'UPCOMING';

  final statusColor = _statusColor(status);

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFFE2E8F0),
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showVisitDetails(visit),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FF),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      _visitIcon(type),
                      color: const Color(0xFF2563EB),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type,
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
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
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

              const SizedBox(height: 11),

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
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.schedule_outlined,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 13),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          visit['technician']?.toString() ?? 'Technician',
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
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
  Widget _emptyState() {
    final isFiltering = selectedFilter != 'ALL';

    final title = isFiltering ? 'No matching visits' : 'No visits found';
    final subtitle = isFiltering
        ? 'Try changing the selected filter.'
        : 'Visits you schedule will appear here.';

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
                Icons.event_busy_outlined,
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
            if (isFiltering)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = 'ALL';
                    });
                  },
                  child: const Text('Clear filter'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// VISIT DETAILS SHEET
// ============================================================

class _VisitDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> visit;
  final Future<void> Function()? onUpdated;

  const _VisitDetailsSheet({
    required this.visit,
    this.onUpdated,
  });

  @override
  State<_VisitDetailsSheet> createState() =>
      _VisitDetailsSheetState();
}

class _VisitDetailsSheetState extends State<_VisitDetailsSheet> {
  bool isUpdating = false;

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'UPCOMING':
        return const Color(0xFF2563EB);
      case 'COMPLETED':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF64748B);
    }
  }

     IconData _visitIcon(String type) {
    final value = type.toLowerCase();

    if (value.contains('installation')) {
      return Icons.build_circle_outlined;
    }

    if (value.contains('maintenance')) {
      return Icons.handyman_outlined;
    }

    if (value.contains('vpn')) {
      return Icons.vpn_key_outlined;
    }

    if (value.contains('network')) {
      return Icons.router_outlined;
    }

    return Icons.location_on_outlined;
  }

  Future<void> _completeVisit() async {
    if (isUpdating) return;

    setState(() {
      isUpdating = true;
    });

    try {
      await ApiService.updateVisitStatus(
        widget.visit['id'].toString(),
        'COMPLETED',
      );

      if (!mounted) return;

      if (widget.onUpdated != null) {
        await widget.onUpdated!();
      }

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visit marked as completed'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to complete visit'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final customer = widget.visit['customer']?.toString() ?? '-';
final location = widget.visit['location']?.toString() ?? '-';
final time = widget.visit['time']?.toString() ?? '-';
final type = widget.visit['type']?.toString() ?? '-';
final status = widget.visit['status']?.toString() ?? '-';
final technician = widget.visit['technician']?.toString() ?? '-';
final description = widget.visit['description']?.toString() ?? '-';
final contact = widget.visit['contact']?.toString() ?? '-';
    final statusColor = _statusColor(status);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // HANDLE
            // ==================================================

            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // ==================================================
            // HEADER
            // ==================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _visitIcon(type),
                      color: const Color(0xFF2563EB),
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Visit Details',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          customer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(9),
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
            ),

            // ==================================================
            // CONTENT
            // ==================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailCard(
                      icon: Icons.schedule_outlined,
                      title: 'Scheduled time',
                      value: time,
                    ),
                    const SizedBox(height: 10),
                    _detailCard(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      value: location,
                    ),
                    const SizedBox(height: 10),
                    _detailCard(
                      icon: Icons.category_outlined,
                      title: 'Service type',
                      value: type,
                    ),
                    const SizedBox(height: 10),
                    _detailCard(
                      icon: Icons.person_outline_rounded,
                      title: 'Assigned technician',
                      value: technician,
                    ),
                    const SizedBox(height: 10),
                    _detailCard(
                      icon: Icons.phone_outlined,
                      title: 'Customer contact',
                      value: contact,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Visit Description',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        description,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: status == 'COMPLETED' || isUpdating
                            ? null
                            : _completeVisit,
                        icon: isUpdating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                status == 'COMPLETED'
                                    ? Icons.check_rounded
                                    : Icons.task_alt_rounded,
                              ),
                        label: Text(
                          isUpdating
                              ? 'Completing...'
                              : status == 'COMPLETED'
                                  ? 'Completed'
                                  : 'Mark Visit Completed',
                          style: const TextStyle(
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

  Widget _detailCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
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
                    color: Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
