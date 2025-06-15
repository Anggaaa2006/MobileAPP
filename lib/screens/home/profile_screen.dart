import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _notificationsEnabled = true;
  int _reminderDays = 3;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = await authService.getUserData();
    
    if (userData != null && mounted) {
      setState(() {
        _fullNameController.text = userData['fullName'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _notificationsEnabled = userData['notificationEnabled'] ?? true;
        _reminderDays = userData['reminderDays'] ?? 3;
      });
    }
  }
  
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.updateUserProfile(
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      notificationEnabled: _notificationsEnabled,
      reminderDays: _reminderDays,
    );
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
        if (error == null) {
          _isEditing = false;
        }
      });
    }
  }
  
  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryBlue,
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Consumer<AuthService>(
                          builder: (context, authService, child) {
                            return Text(
                              authService.currentUser?.email ?? 'User',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.darkGray,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_errorMessage != null) const SizedBox(height: 20),
                  
                  // Profile Form
                  CustomTextField(
                    controller: _fullNameController,
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icons.person_outline,
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    controller: _phoneController,
                    labelText: 'Nomor Telepon',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nomor telepon tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Notification Settings
                  const Text(
                    'Pengaturan Notifikasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('Aktifkan Notifikasi'),
                    subtitle: const Text('Dapatkan pengingat untuk tagihan'),
                    value: _notificationsEnabled,
                    activeColor: AppColors.primaryBlue,
                    onChanged: _isEditing
                        ? (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          }
                        : null,
                  ),
                  
                  const Divider(),
                  
                  ListTile(
                    title: const Text('Ingatkan Sebelum Jatuh Tempo'),
                    subtitle: Text('$_reminderDays hari sebelumnya'),
                    enabled: _isEditing && _notificationsEnabled,
                  ),
                  
                  if (_isEditing && _notificationsEnabled)
                    Slider(
                      value: _reminderDays.toDouble(),
                      min: 1,
                      max: 7,
                      divisions: 6,
                      label: _reminderDays.toString(),
                      activeColor: AppColors.primaryBlue,
                      onChanged: (value) {
                        setState(() {
                          _reminderDays = value.toInt();
                        });
                      },
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // Update Button
                  if (_isEditing)
                    CustomButton(
                      text: 'Simpan Perubahan',
                      isLoading: _isLoading,
                      onPressed: _updateProfile,
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Cancel Button
                  if (_isEditing)
                    CustomButton(
                      text: 'Batal',
                      backgroundColor: AppColors.lightGray,
                      textColor: AppColors.darkGray,
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _errorMessage = null;
                        });
                        _loadUserData();
                      },
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Sign Out Button
                  if (!_isEditing)
                    CustomButton(
                      text: 'Keluar',
                      backgroundColor: AppColors.error,
                      icon: Icons.logout,
                      onPressed: _signOut,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}