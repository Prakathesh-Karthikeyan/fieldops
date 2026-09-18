import 'package:flutter/material.dart';

import '../core/api_service.dart';

class CustomerServiceRequestScreen extends StatefulWidget {
  const CustomerServiceRequestScreen({super.key});

  @override
  State<CustomerServiceRequestScreen> createState() =>
      _CustomerServiceRequestScreenState();
}

class _CustomerServiceRequestScreenState
    extends State<CustomerServiceRequestScreen> {
        final _formKey = GlobalKey<FormState>();

  final customerController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final issueController = TextEditingController();
  final descriptionController = TextEditingController();

  String selectedServiceType = 'General Service';
  String selectedPriority = 'MEDIUM';

  bool isSubmitting = false;

  final List<String> serviceTypes = [
    'General Service',
    'Automation Gate Service',
    'Electrical Service',
    'Smart Home Service',
    'IT Support',
    'Network Support',
    'Installation',
    'Maintenance',
  ];

  final List<String> priorities = [
    'LOW',
    'MEDIUM',
    'HIGH',
    'CRITICAL',
  ];

  @override
  void dispose() {
    customerController.dispose();
    phoneController.dispose();
    locationController.dispose();
    issueController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final result = await ApiService.createCustomerRequest(
  customer: customerController.text.trim(),
  phone: phoneController.text.trim(),
  location: locationController.text.trim(),
  serviceType: selectedServiceType,
  priority: selectedPriority,
  issue: issueController.text.trim(),
  description: descriptionController.text.trim(),
);

final requestId =
    result['request_id']?.toString();

if (requestId == null || requestId.isEmpty) {
  throw Exception(
    'Customer request ID was not returned',
  );
}

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      'Service request $requestId submitted successfully',
    ),
    behavior: SnackBarBehavior.floating,
  ),
);
      _formKey.currentState!.reset();

      customerController.clear();
      phoneController.clear();
      locationController.clear();
      issueController.clear();
      descriptionController.clear();

      setState(() {
        selectedServiceType = 'General Service';
        selectedPriority = 'MEDIUM';
        isSubmitting = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to submit service request. Please try again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text(
          'Service Request',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              32,
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0B2A6F),
                      Color(0xFF2563EB),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need service or support?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Tell us about your issue and our field team will take care of it.',
                            style: TextStyle(
                              color: Color(0xFFDCE7FF),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              _sectionTitle(
                'Customer Information',
                'Enter the customer contact and service location.',
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: customerController,
                decoration: _inputDecoration(
                  label: 'Customer Name',
                  icon: Icons.person_outline_rounded,
                  hint: 'Enter customer name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Customer name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration(
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  hint: 'Enter phone number',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: locationController,
                decoration: _inputDecoration(
                  label: 'Location',
                  icon: Icons.location_on_outlined,
                  hint: 'Customer location',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),

              _sectionTitle(
                'Service Details',
                'Select the service type and urgency.',
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: selectedServiceType,
                decoration: _inputDecoration(
                  label: 'Service Type',
                  icon: Icons.build_outlined,
                ),
                items: serviceTypes.map((service) {
                  return DropdownMenuItem(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedServiceType = value;
                  });
                },
              ),

              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                initialValue: selectedPriority,
                decoration: _inputDecoration(
                  label: 'Priority',
                  icon: Icons.flag_outlined,
                ),
                items: priorities.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedPriority = value;
                  });
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: issueController,
                decoration: _inputDecoration(
                  label: 'Problem / Issue',
                  icon: Icons.report_problem_outlined,
                  hint: 'What problem are you facing?',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe the issue';
                  }
                  return null;
                },
                maxLines: 2,
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: descriptionController,
                decoration: _inputDecoration(
                  label: 'Additional Description',
                  icon: Icons.notes_outlined,
                  hint: 'Add more details if required',
                ),
                maxLines: 4,
              ),

              const SizedBox(height: 26),

              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : _submitRequest,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                        ),
                  label: Text(
                    isSubmitting
                        ? 'Submitting...'
                        : 'Submit Service Request',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
