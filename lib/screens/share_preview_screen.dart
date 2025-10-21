import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/share_service.dart';
import '../services/animation_service.dart';
import '../widgets/share_card.dart';

/// Paylaşım ekranı
class SharePreviewScreen extends StatefulWidget {
  final String dream;
  final String interpretation;

  const SharePreviewScreen({
    super.key,
    required this.dream,
    required this.interpretation,
  });

  @override
  State<SharePreviewScreen> createState() => _SharePreviewScreenState();
}

class _SharePreviewScreenState extends State<SharePreviewScreen> {
  ShareCardStyle _selectedStyle = ShareCardStyle.general;
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: const Text(
          'Paylaş',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Kart önizlemesi
            Expanded(
              flex: 3,
              child: Center(
                child: SingleChildScrollView(
                  child: ShareCard(
                    dream: widget.dream,
                    interpretation: widget.interpretation,
                    style: _selectedStyle,
                  ),
                ),
              ),
            ),
            
            // Platform seçimi
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Paylaşım Platformu Seçin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Platform butonları
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPlatformButton(
                          Icons.camera_alt,
                          'Instagram',
                          ShareCardStyle.instagram,
                          const Color(0xFF833AB4),
                        ),
                        _buildPlatformButton(
                          Icons.facebook,
                          'Facebook',
                          ShareCardStyle.facebook,
                          const Color(0xFF1877F2),
                        ),
                        _buildPlatformButton(
                          Icons.alternate_email,
                          'Twitter',
                          ShareCardStyle.twitter,
                          const Color(0xFF1DA1F2),
                        ),
                        _buildPlatformButton(
                          Icons.chat,
                          'WhatsApp',
                          ShareCardStyle.whatsapp,
                          const Color(0xFF25D366),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Paylaşım butonları
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSharing ? null : _shareToGeneral,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF6C63FF),
                              ),
                              foregroundColor: const Color(0xFF6C63FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isSharing
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF6C63FF),
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Genel Paylaşım',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSharing ? null : _shareToSelectedPlatform,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isSharing
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    _getPlatformButtonText(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformButton(
    IconData icon,
    String label,
    ShareCardStyle style,
    Color color,
  ) {
    final isSelected = _selectedStyle == style;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStyle = style;
        });
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected 
                  ? color.withOpacity(0.3)
                  : color.withOpacity(0.1),
              border: Border.all(
                color: isSelected ? color : color.withOpacity(0.5),
                width: isSelected ? 3 : 2,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? color : color.withOpacity(0.7),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  String _getPlatformButtonText() {
    switch (_selectedStyle) {
      case ShareCardStyle.instagram:
        return 'Instagram\'da Paylaş';
      case ShareCardStyle.facebook:
        return 'Facebook\'ta Paylaş';
      case ShareCardStyle.twitter:
        return 'Twitter\'da Paylaş';
      case ShareCardStyle.whatsapp:
        return 'WhatsApp\'ta Paylaş';
      case ShareCardStyle.general:
        return 'Genel Paylaşım';
    }
  }

  Future<void> _shareToGeneral() async {
    setState(() {
      _isSharing = true;
    });

    try {
      final shareText = ShareService.createDreamShareText(
        widget.dream,
        widget.interpretation,
      );
      
      await ShareService.shareText(shareText);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paylaşım başlatıldı'),
            backgroundColor: Color(0xFF6C63FF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paylaşım hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _shareToSelectedPlatform() async {
    setState(() {
      _isSharing = true;
    });

    try {
      bool success = false;
      
      switch (_selectedStyle) {
        case ShareCardStyle.instagram:
          // Instagram için özel metin
          final text = ShareService.createInstagramStoryText(
            widget.dream,
            widget.interpretation,
          );
          success = await ShareService.shareToInstagramStory(text);
          break;
          
        case ShareCardStyle.facebook:
          final text = ShareService.createDreamShareText(
            widget.dream,
            widget.interpretation,
          );
          success = await ShareService.shareToFacebook(text);
          break;
          
        case ShareCardStyle.twitter:
          final text = ShareService.createShortDreamShareText(
            widget.dream,
            widget.interpretation,
          );
          success = await ShareService.shareToTwitter(text);
          break;
          
        case ShareCardStyle.whatsapp:
          final text = ShareService.createWhatsAppText(
            widget.dream,
            widget.interpretation,
          );
          success = await ShareService.shareToWhatsApp(text);
          break;
          
        case ShareCardStyle.general:
          await _shareToGeneral();
          return;
      }
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_getPlatformButtonText()} başarılı!'),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_getPlatformButtonText()} başarısız oldu'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paylaşım hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }
}
