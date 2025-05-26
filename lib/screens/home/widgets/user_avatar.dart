import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:enva/services/services.dart';

class UserAvatar extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double borderWidth;

  const UserAvatar({
    Key? key,
    this.size = 40,
    this.onTap,
    this.borderColor,
    this.borderWidth = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = SupabaseServices.client.auth.currentUser;
    final userAvatar = user?.userMetadata?['avatar_url'];
    final userName = user?.userMetadata?['name'] ?? 'User';
    final initials = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final effectiveBorderColor =
        borderColor ?? (isDarkMode ? Colors.white70 : Colors.white);

    return GestureDetector(
      onTap: onTap ??
          () {
            _showUserProfile(context);
          },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: userAvatar == null ? Colors.grey[300] : null,
          border: Border.all(
            color: effectiveBorderColor,
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
          image: userAvatar != null
              ? DecorationImage(
                  image: NetworkImage(userAvatar),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: userAvatar == null
            ? Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.4,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  void _showUserProfile(BuildContext context) {
    final user = SupabaseServices.client.auth.currentUser;
    final userAvatar = user?.userMetadata?['avatar_url'];
    final userName = user?.userMetadata?['name'] ?? 'Guest User';
    final userEmail = user?.email ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 20),
            if (userAvatar != null)
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(userAvatar),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            Text(
              userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (userEmail.isNotEmpty)
              Text(
                userEmail,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.blue),
              ),
              title: const Text('Profile Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                // Navigate to profile settings
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: Colors.red),
              ),
              title: const Text('Sign Out'),
              onTap: () async {
                Navigator.pop(context);
                await SupabaseServices.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
