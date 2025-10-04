import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF6C63FF),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: Color(0xFF6C63FF),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Kullanıcı',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Bildirimler',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Ayarlar',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Hakkında',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Yardım',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white70,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF555555),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFF1A1A1A),
      height: 1,
      thickness: 0.5,
    );
  }
}
