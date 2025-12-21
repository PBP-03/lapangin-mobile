import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../providers/user_provider.dart';
import '../../config/config.dart';
import '../../models/user_model.dart';
import '../../widgets/branded_app_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeleting = false;

  bool _formInitialized = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  static const int _profilePictureCount = 6;

  int? _selectedProfilePictureIndex;

  List<int> get _profilePictureOptions =>
      List.generate(_profilePictureCount, (i) => i + 1);

  String _profileAssetForIndex(int index) {
    return 'assets/images/profile-options/profile-$index.jpg';
  }

  String _profileUrlForIndex(int index) {
    return AppConfig.buildUrl('/static/img/profile-options/profile-$index.jpg');
  }

  int? _profileIndexFromUrl(String? url) {
    final value = url?.trim();
    if (value == null || value.isEmpty) return null;

    final match = RegExp(
      r'profile-(\d+)\.jpg',
      caseSensitive: false,
    ).firstMatch(value);
    if (match == null) return null;

    final index = int.tryParse(match.group(1) ?? '');
    if (index == null) return null;
    if (index < 1 || index > _profilePictureCount) return null;
    return index;
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);

    try {
      final request = Provider.of<CookieRequest>(context, listen: false);
      final response = await request.get(
        AppConfig.buildUrl(AppConfig.profileEndpoint),
      );

      if (response is Map && response['success'] == true) {
        final data = response['data'];
        final user = (data is Map) ? data['user'] : null;
        if (user is Map) {
          final userMap = Map<String, dynamic>.from(user);
          if (!_formInitialized) {
            _usernameController.text = (userMap['username'] ?? '').toString();
            _firstNameController.text = (userMap['first_name'] ?? '')
                .toString();
            _lastNameController.text = (userMap['last_name'] ?? '').toString();
            _emailController.text = (userMap['email'] ?? '').toString();
            _phoneController.text = (userMap['phone_number'] ?? '').toString();
            _addressController.text = (userMap['address'] ?? '').toString();
            _selectedProfilePictureIndex = _profileIndexFromUrl(
              userMap['profile_picture']?.toString(),
            );
            _formInitialized = true;
          }
        }
      } else {
        if (mounted) {
          final message = (response is Map && response['message'] != null)
              ? response['message'].toString()
              : 'Failed to load profile';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final request = Provider.of<CookieRequest>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final payload = {
        'username': _usernameController.text.trim(),
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'profile_picture': _selectedProfilePictureIndex == null
            ? ''
            : _profileUrlForIndex(_selectedProfilePictureIndex!),
      };

      final response = await request.postJson(
        AppConfig.buildUrl(AppConfig.profileEndpoint),
        jsonEncode(payload),
      );

      if (!mounted) return;

      if (response is Map && response['success'] == true) {
        // Update local provider data if available.
        final updatedUserMap = (response['data'] is Map)
            ? (response['data']['user'] is Map)
                  ? Map<String, dynamic>.from(response['data']['user'])
                  : null
            : null;

        final current = userProvider.user;
        if (current != null && updatedUserMap != null) {
          userProvider.updateUser(
            current.copyWith(
              username: (updatedUserMap['username'] ?? current.username)
                  .toString(),
              email: (updatedUserMap['email'] ?? current.email).toString(),
              firstName:
                  (updatedUserMap['first_name'] ?? current.firstName)
                      as String?,
              lastName:
                  (updatedUserMap['last_name'] ?? current.lastName) as String?,
              phoneNumber:
                  (updatedUserMap['phone_number'] ?? current.phoneNumber)
                      as String?,
              address:
                  (updatedUserMap['address'] ?? current.address) as String?,
              profilePicture:
                  (updatedUserMap['profile_picture'] ?? current.profilePicture)
                      as String?,
            ),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
      } else {
        final message = (response is Map && response['message'] != null)
            ? response['message'].toString()
            : 'Gagal memperbarui profil';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan profil: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteAccount() async {
    if (_isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: const Text(
          'Anda yakin ingin menghapus akun? Semua data Anda akan dihapus permanen dan tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      final request = Provider.of<CookieRequest>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final response = await request.postJson(
        AppConfig.buildUrl(AppConfig.profileEndpoint),
        jsonEncode({'_action': 'delete'}),
      );

      if (!mounted) return;

      if (response is Map && response['success'] == true) {
        userProvider.logout();
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        final message = (response is Map && response['message'] != null)
            ? response['message'].toString()
            : 'Gagal menghapus akun';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus akun: $e')));
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final request = Provider.of<CookieRequest>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      try {
        await request.logout(AppConfig.buildUrl(AppConfig.logoutEndpoint));
        userProvider.logout();

        if (mounted) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    final displayName = (user?.fullName ?? '').trim().isNotEmpty
        ? user!.fullName
        : (user?.username ?? 'User');

    final roleLabel = (user?.role ?? 'user').toUpperCase();

    final avatarIndex =
        _selectedProfilePictureIndex ??
        _profileIndexFromUrl(user?.profilePicture);
    final hasAvatar = avatarIndex != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: BrandedAppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _fetchProfile,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E5E5)),
                        ),
                        child: Row(
                          children: [
                            ClipOval(
                              child: Container(
                                width: 72,
                                height: 72,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.12),
                                child: hasAvatar
                                    ? Image.asset(
                                        _profileAssetForIndex(avatarIndex),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Center(
                                                child: Text(
                                                  (user?.username ?? 'U')
                                                      .characters
                                                      .first
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.w800,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                  ),
                                                ),
                                              );
                                            },
                                      )
                                    : Center(
                                        child: Text(
                                          (user?.username ?? 'U')
                                              .characters
                                              .first
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.email ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.20),
                                      ),
                                    ),
                                    child: Text(
                                      roleLabel,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Form card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E5E5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Informasi Profil',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),

                            _buildTextField(
                              label: 'Username',
                              controller: _usernameController,
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: 'Nama Depan',
                                    controller: _firstNameController,
                                    icon: Icons.badge_outlined,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    label: 'Nama Belakang',
                                    controller: _lastNameController,
                                    icon: Icons.badge_outlined,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            _buildTextField(
                              label: 'Email',
                              controller: _emailController,
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),

                            _buildTextField(
                              label: 'Telepon',
                              controller: _phoneController,
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),

                            _buildTextField(
                              label: 'Alamat',
                              controller: _addressController,
                              icon: Icons.location_on_outlined,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Picture selection card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E5E5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Foto Profil',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Pilih salah satu foto di bawah sebagai foto profil Anda',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final crossAxisCount =
                                    constraints.maxWidth < 360 ? 3 : 6;
                                return GridView.count(
                                  crossAxisCount: crossAxisCount,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  children: _profilePictureOptions.map((index) {
                                    final isSelected =
                                        _selectedProfilePictureIndex == index;
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedProfilePictureIndex = index;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(999),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : const Color(0xFFE5E5E5),
                                            width: isSelected ? 3 : 2,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: Image.asset(
                                            _profileAssetForIndex(index),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    color: const Color(
                                                      0xFFF1F5F9,
                                                    ),
                                                    child: Icon(
                                                      Icons.person,
                                                      color: Colors.grey[500],
                                                    ),
                                                  );
                                                },
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Actions
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveProfile,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(_isSaving ? 'Menyimpan...' : 'Simpan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _isDeleting ? null : _deleteAccount,
                          icon: _isDeleting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.delete_outline),
                          label: Text(
                            _isDeleting ? 'Menghapus...' : 'Hapus Akun',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

extension on User {
  User copyWith({
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
    String? profilePicture,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      profilePicture: profilePicture ?? this.profilePicture,
      isVerified: isVerified,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
