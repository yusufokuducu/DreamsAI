import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

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
                Icons.auto_awesome,
                size: 50,
                color: Color(0xFF6C63FF),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Dreams AI',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rüyalarınızı yorumlayan yapay zeka asistanınız',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 40),
          _buildMenuHeader('Ayarlar'),
          _buildSwitchItem(
            icon: Icons.notifications_outlined,
            title: 'Bildirimler',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.color_lens_outlined,
            title: 'Tema',
            subtitle: 'Koyu mod',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuHeader('Uygulama'),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Hakkında',
            onTap: _showAboutDialog,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Gizlilik Politikası',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Yardım',
            onTap: _showHelpDialog,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF1A1A1A),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Uygulama Bilgileri',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Sürüm', '1.0.0'),
                const SizedBox(height: 8),
                _buildInfoRow('Geliştirici', 'Dreams AI Team'),
                const SizedBox(height: 8),
                _buildInfoRow('Lisans', 'GPL-3.0'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
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
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF555555),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF6C63FF),
        activeTrackColor: const Color(0xFF6C63FF).withOpacity(0.3),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFF1A1A1A),
      height: 1,
      thickness: 0.5,
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Dreams AI',
      applicationVersion: 'v1.0.0',
      applicationIcon: const Icon(
        Icons.auto_awesome,
        color: Color(0xFF6C63FF),
        size: 40,
      ),
      children: [
        const Text(
          'Dreams AI, rüyalarınızı yapay zeka ile yorumlayan akıllı bir uygulamadır. Rüyanızdaki sembolleri ve duygusal içeriği analiz ederek size anlamlı yorumlar sunar.',
        ),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text(
          'Yardım',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Rüyanızı detaylı bir şekilde anlatın. Yapay zeka, rüyanızdaki sembolleri ve duygusal içeriği analiz ederek size anlamlı bir yorum sunacaktır. Rüyanızı mümkün olduğunca ayrıntılı anlatmanız daha iyi sonuçlar almanızı sağlar.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tamam',
              style: TextStyle(color: Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),
    );
  }
}
