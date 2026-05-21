import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/contact_model.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<TextEditingController> _nameControllers = [];
  List<TextEditingController> _relationshipControllers = [];
  List<TextEditingController> _phoneControllers = [];
  List<TextEditingController> _whatsappControllers = [];

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  List<ContactModel> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _relationshipControllers) {
      controller.dispose();
    }
    for (var controller in _phoneControllers) {
      controller.dispose();
    }
    for (var controller in _whatsappControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);

    try {
      final contacts = await Provider.of<ApiService>(context, listen: false)
          .getEmergencyContacts();
      setState(() {
        _contacts = contacts;
        _initializeControllers(contacts);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading contacts: $e');
      setState(() {
        _errorMessage = 'Failed to load contacts';
        _isLoading = false;
      });
    }
  }

  void _initializeControllers(List<ContactModel> contacts) {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _relationshipControllers) {
      controller.dispose();
    }
    for (var controller in _phoneControllers) {
      controller.dispose();
    }
    for (var controller in _whatsappControllers) {
      controller.dispose();
    }

    _nameControllers = contacts
        .map((c) => TextEditingController(text: c.contactName))
        .toList();
    _relationshipControllers = contacts
        .map((c) => TextEditingController(text: c.relationship ?? ''))
        .toList();
    _phoneControllers = contacts
        .map((c) => TextEditingController(text: c.phone ?? ''))
        .toList();
    _whatsappControllers = contacts
        .map((c) => TextEditingController(text: c.whatsapp ?? ''))
        .toList();
  }

  Future<void> _saveContacts() async {
    setState(() => _isSaving = true);

    final updatedContacts =
        List<ContactModel>.generate(_contacts.length, (index) {
      return _contacts[index].copyWith(
        contactName: _nameControllers[index].text,
        relationship: _relationshipControllers[index].text,
        phone: _phoneControllers[index].text,
        whatsapp: _whatsappControllers[index].text,
      );
    });

    final result = await Provider.of<ApiService>(context, listen: false)
        .updateEmergencyContacts(updatedContacts);

    setState(() => _isSaving = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency contacts updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Reload contacts
      await _loadContacts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Update failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: _loadContacts,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Header Card - matches HTML contacts-card header
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Emergency Contacts',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Add people to contact in case of emergency',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Current Contacts Display - matches HTML contacts-list
                    if (_contacts.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: Text(
                          'CURRENT CONTACTS',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      ..._buildCurrentContacts(),
                      const SizedBox(height: 10),
                    ],
                    
                    // Edit Form - matches HTML contacts-form
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EDIT CONTACTS',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ..._buildEditForms(),
                          
                          const SizedBox(height: 12),
                          
                          // Save Button - matches HTML btn-primary
                          ElevatedButton(
                            onPressed: _isSaving ? null : _saveContacts,
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save, size: 16),
                                      SizedBox(width: 5),
                                      Text('Save Changes'),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Error Message - matches HTML error-message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFEE2E2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFECAAA)),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFF991B1B),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  List<Widget> _buildCurrentContacts() {
    return List.generate(_contacts.length, (index) {
      final contact = _contacts[index];
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(6),
          border: const Border(
              left: BorderSide(color: Color(0xFF667eea), width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Priority ${contact.priority}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              contact.contactName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text('Relationship: ${contact.relationship ?? "N/A"}',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
            Text('Phone: ${contact.phone ?? "N/A"}',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
            Text('WhatsApp: ${contact.whatsapp ?? "N/A"}',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
          ],
        ),
      );
    });
  }

  List<Widget> _buildEditForms() {
    if (_contacts.isEmpty || 
        _nameControllers.length != _contacts.length ||
        _relationshipControllers.length != _contacts.length ||
        _phoneControllers.length != _contacts.length ||
        _whatsappControllers.length != _contacts.length) {
      return [];
    }
    
    return List.generate(_contacts.length, (index) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact ${index + 1} (Priority ${_contacts[index].priority})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameControllers[index],
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                hintText: 'Enter contact name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter contact name';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _relationshipControllers[index],
              decoration: const InputDecoration(
                labelText: 'Relationship',
                hintText: 'Enter relationship',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phoneControllers[index],
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: 'Enter phone number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _whatsappControllers[index],
              decoration: const InputDecoration(
                labelText: 'WhatsApp',
                hintText: 'Enter WhatsApp number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      );
    });
  }
}
