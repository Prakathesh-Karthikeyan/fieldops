import 'package:flutter/material.dart';

import '../core/api_service.dart';

// ============================================================
// CREATE TICKET SCREEN
// ============================================================

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final titleController = TextEditingController();

  final customerController = TextEditingController();

  final locationController = TextEditingController();

  final scheduledTimeController = TextEditingController();

  final descriptionController = TextEditingController();

  String priority = 'MEDIUM';

  bool isSaving = false;

  Future<void> _createTicket() async {
    if (titleController.text.trim().isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please enter the issue title.'),
    ),
  );
  return;
}

if (customerController.text.trim().isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please enter the customer name.'),
    ),
  );
  return;
}

if (locationController.text.trim().isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please enter the location.'),
    ),
  );
  return;
}

    setState(() {
      isSaving = true;
    });

    try {
      await ApiService.createTicket(
        title: titleController.text.trim(),
        customer: customerController.text.trim(),
        location: locationController.text.trim(),
        priority: priority,
        scheduledTime: scheduledTimeController.text.trim().isEmpty
            ? 'Not scheduled'
            : scheduledTimeController.text.trim(),
        description: descriptionController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket created successfully.')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to create ticket.')));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    customerController.dispose();
    locationController.dispose();
    scheduledTimeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  elevation: 0,
  backgroundColor: Colors.white,
  surfaceTintColor: Colors.transparent,
  foregroundColor: const Color(0xFF0F172A),
  titleSpacing: 20,
  title: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Create Ticket',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
        ),
      ),
      SizedBox(height: 2),
      Text(
        'Create a new field service request',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFF64748B),
        ),
      ),
    ],
  ),
),
      body: SingleChildScrollView(
  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field('Issue Title', titleController, 'Enter issue title', required: true),

            const SizedBox(height: 18),

            _field('Customer', customerController, 'Enter customer name', required: true),

            const SizedBox(height: 18),

            _field('Location', locationController, 'Enter location', required: true),

            const SizedBox(height: 18),

           GestureDetector(
  onTap: () async {
    final DateTime now = DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(
        const Duration(days: 365),
      ),
    );

    if (!mounted || selectedDate == null) return;

   final TimeOfDay? selectedTime = await showTimePicker(
  context: this.context,
  initialTime: TimeOfDay.now(),
);

    if (!mounted || selectedTime == null) return;

    final DateTime scheduledDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    scheduledTimeController.text =
        '${scheduledDateTime.day.toString().padLeft(2, '0')}/'
        '${scheduledDateTime.month.toString().padLeft(2, '0')}/'
        '${scheduledDateTime.year} '
        '${selectedTime.format(this.context)}';

    setState(() {});
  },
  child: AbsorbPointer(
    child: _field(
      'Scheduled Time',
      scheduledTimeController,
      'schedule',
    ),
  ),
),

            const SizedBox(height: 18),

            const Text(
  'Priority',
  style: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: Color(0xFF334155),
    letterSpacing: 0.2,
  ),
),

const SizedBox(height: 8),

Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 4,
  ),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(
      color: const Color(0xFFE2E8F0),
    ),
  ),
  child: DropdownButtonHideUnderline(
    child: DropdownButton<String>(
      value: priority,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF2563EB),
      ),
      items: const [
        DropdownMenuItem(
          value: 'LOW',
          child: Text(
            'LOW',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF16A34A),
            ),
          ),
        ),
        DropdownMenuItem(
          value: 'MEDIUM',
          child: Text(
            'MEDIUM',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFD97706),
            ),
          ),
        ),
        DropdownMenuItem(
          value: 'HIGH',
          child: Text(
            'HIGH',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFDC2626),
            ),
          ),
        ),
      ],
      onChanged: isSaving
          ? null
          : (value) {
              if (value == null) return;

              setState(() {
                priority = value;
              });
            },
    ),
  ),
),

const SizedBox(height: 18),

            _field(
  'Description',
  descriptionController,
  'Describe the issue in detail...',
  maxLines: 5,
),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: isSaving ? null : _createTicket,
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Create Ticket',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _field(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    bool required = false,
  }) {
    IconData icon;

    switch (label) {
      case 'Issue Title':
        icon = Icons.title_rounded;
        break;
      case 'Customer':
        icon = Icons.person_outline_rounded;
        break;
      case 'Location':
        icon = Icons.location_on_outlined;
        break;
      case 'Scheduled Time':
        icon = Icons.schedule_rounded;
        break;
      case 'Description':
        icon = Icons.description_outlined;
        break;
      default:
        icon = Icons.edit_outlined;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          required ? '$label *' : label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF334155),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
            prefixIcon: Icon(
              icon,
              size: 20,
              color: const Color(0xFF64748B),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
  horizontal: 14,
  vertical: 12,
),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

