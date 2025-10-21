import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

/// Paylaşım kartı widget'ı
class ShareCard extends StatelessWidget {
  final String dream;
  final String interpretation;
  final ShareCardStyle style;

  const ShareCard({
    super.key,
    required this.dream,
    required this.interpretation,
    this.style = ShareCardStyle.instagram,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 600,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: _getGradient(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Arka plan gradient
            Container(
              decoration: BoxDecoration(
                gradient: _getGradient(),
              ),
            ),
            // İçerik
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo ve başlık
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        'Dreams AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Rüya bölümü
                  _buildSection(
                    '💭 Rüyam',
                    dream,
                    const Color(0xFF4CAF50),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Yorum bölümü
                  _buildSection(
                    '✨ Yorum',
                    interpretation,
                    const Color(0xFF6C63FF),
                  ),
                  
                  const Spacer(),
                  
                  // Alt bilgi
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dreams AI ile yorumlandı',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: accentColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  LinearGradient _getGradient() {
    switch (style) {
      case ShareCardStyle.instagram:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF833AB4),
            Color(0xFFFD1D1D),
            Color(0xFFFCB045),
          ],
        );
      case ShareCardStyle.facebook:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1877F2),
            Color(0xFF42A5F5),
          ],
        );
      case ShareCardStyle.twitter:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1DA1F2),
            Color(0xFF0D8BD9),
          ],
        );
      case ShareCardStyle.whatsapp:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF25D366),
            Color(0xFF128C7E),
          ],
        );
      case ShareCardStyle.general:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C63FF),
            Color(0xFF4CAF50),
          ],
        );
    }
  }
}

/// Paylaşım kartı stilleri
enum ShareCardStyle {
  instagram,
  facebook,
  twitter,
  whatsapp,
  general,
}

/// Paylaşım kartı önizleme widget'ı
class ShareCardPreview extends StatelessWidget {
  final String dream;
  final String interpretation;
  final ShareCardStyle style;

  const ShareCardPreview({
    super.key,
    required this.dream,
    required this.interpretation,
    this.style = ShareCardStyle.general,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF1A1A1A),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.share,
                    color: Color(0xFF6C63FF),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Paylaşım Önizlemesi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            // Kart önizlemesi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ShareCard(
                dream: dream,
                interpretation: interpretation,
                style: style,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Platform seçimi
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Paylaşım Platformu Seçin',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPlatformButton(
                        context,
                        Icons.camera_alt,
                        'Instagram',
                        ShareCardStyle.instagram,
                        const Color(0xFF833AB4),
                      ),
                      _buildPlatformButton(
                        context,
                        Icons.facebook,
                        'Facebook',
                        ShareCardStyle.facebook,
                        const Color(0xFF1877F2),
                      ),
                      _buildPlatformButton(
                        context,
                        Icons.alternate_email,
                        'Twitter',
                        ShareCardStyle.twitter,
                        const Color(0xFF1DA1F2),
                      ),
                      _buildPlatformButton(
                        context,
                        Icons.chat,
                        'WhatsApp',
                        ShareCardStyle.whatsapp,
                        const Color(0xFF25D366),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformButton(
    BuildContext context,
    IconData icon,
    String label,
    ShareCardStyle style,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
