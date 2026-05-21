import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _hotelController;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  UserModel? _userModel;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _cityController = TextEditingController();
    _countryController = TextEditingController();
    _hotelController = TextEditingController();

    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _hotelController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final profile =
          await Provider.of<ApiService>(context, listen: false).getProfile();
      setState(() {
        _userModel = profile;
        _fullNameController.text = profile.fullName ?? '';
        _addressController.text = profile.address ?? '';
        _phoneController.text = profile.phone ?? '';
        _emailController.text = profile.email ?? '';
        _cityController.text = profile.currentCity ?? '';
        _countryController.text = profile.currentCountry ?? '';
        _hotelController.text = profile.hotelName ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final updatedUser = UserModel(
      id: _userModel?.id,
      username: _userModel?.username ?? '',
      fullName: _fullNameController.text,
      address: _addressController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      currentCity: _cityController.text,
      currentCountry: _countryController.text,
      hotelName: _hotelController.text,
    );

    final result = await Provider.of<ApiService>(context, listen: false)
        .updateProfile(updatedUser);

    setState(() => _isSaving = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
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
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: const BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: Color(0xFFF9FAFB))),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'User Profile',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Manage your personal information',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Personal Info Section
                            const Text(
                              'PERSONAL INFO',
                              style: TextStyle(
                                color: Color(0xFF667eea),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 10),

                            _buildTextField(_fullNameController, 'Full Name',
                                Icons.person_outline),
                            _buildTextField(_addressController, 'Address',
                                Icons.home_outlined),
                            _buildTextField(_phoneController, 'Phone',
                                Icons.phone_outlined),
                            _buildTextField(_emailController, 'Email',
                                Icons.email_outlined),

                            const SizedBox(height: 12),

                            // Location Section
                            const Text(
                              'CURRENT LOCATION',
                              style: TextStyle(
                                color: Color(0xFF667eea),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 10),

                            _buildTextField(_cityController, 'Current City',
                                Icons.location_city_outlined),
                            _buildTextField(_countryController,
                                'Current Country', Icons.public_outlined),

                            const SizedBox(height: 12),

                            // Accommodation Section
                            const Text(
                              'ACCOMMODATION',
                              style: TextStyle(
                                color: Color(0xFF667eea),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 10),

                            _buildTextField(_hotelController, 'Hotel Name',
                                Icons.hotel_outlined),

                            const SizedBox(height: 12),

                            // Save Button
                            ElevatedButton(
                              onPressed: _isSaving ? null : _saveProfile,
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                    ),

                    // Error Message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0x00fee2e2),
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

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        validator: (value) {
          if (label == 'Full Name' && (value == null || value.isEmpty)) {
            return 'Please enter your full name';
          }
          return null;
        },
      ),
    );
  }
}
