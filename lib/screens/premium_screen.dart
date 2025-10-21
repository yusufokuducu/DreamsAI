import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/limit_service.dart';
import '../services/payment_service.dart';

/// Premium ekranı
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  Map<String, dynamic> _limitStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLimitStatus();
  }

  Future<void> _loadLimitStatus() async {
    final status = await LimitService.getLimitStatus();
    if (mounted) {
      setState(() {
        _limitStatus = status;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: const Text(
          'Premium',
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Limit durumu kartı
                  _buildLimitStatusCard(),
                  
                  const SizedBox(height: 30),
                  
                  // Premium paketler
                  _buildPackagesSection(),
                  
                  const SizedBox(height: 30),
                  
                  // Özellikler
                  _buildFeaturesSection(),
                  
                  const SizedBox(height: 30),
                  
                  // Restore butonu
                  _buildRestoreButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildLimitStatusCard() {
    final used = _limitStatus['used'] ?? 0;
    final limit = _limitStatus['limit'] ?? 3;
    final remaining = _limitStatus['remaining'] ?? 0;
    final isPremium = _limitStatus['isPremium'] ?? false;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.8),
            const Color(0xFF4CAF50).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
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
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPremium ? 'Premium Üye' : 'Ücretsiz Üye',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bu hafta $used/$limit rüya yorumladınız',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white.withOpacity(0.2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: used / limit,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 15),
          
          Text(
            remaining > 0 
                ? '$remaining rüya yorumu hakkınız kaldı'
                : 'Haftalık limitiniz doldu',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Premium Paketler',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Haftalık limitinizi artırın',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 20),
        
        // Paket listesi
        ...LimitService.getPackageInfo().entries.map((entry) {
          final packageId = entry.key;
          final packageInfo = entry.value;
          
          return _buildPackageCard(
            packageId,
            packageInfo['name'] as String,
            packageInfo['price'] as String,
            packageInfo['dreams'] as int,
            packageInfo['description'] as String,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPackageCard(
    String packageId,
    String name,
    String price,
    int dreams,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1A1A1A),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Paket ikonu
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6C63FF).withOpacity(0.2),
              border: Border.all(
                color: const Color(0xFF6C63FF),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Color(0xFF6C63FF),
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Paket bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '+$dreams rüya yorumu',
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Satın alma butonu
          Consumer<PaymentService>(
            builder: (context, paymentService, child) {
              return ElevatedButton(
                onPressed: paymentService.isLoading 
                    ? null 
                    : () => _purchasePackage(packageId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: paymentService.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        price,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Premium Özellikler',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        
        _buildFeatureItem(
          Icons.auto_awesome,
          'Sınırsız Rüya Yorumu',
          'Haftalık limitinizi artırın',
        ),
        _buildFeatureItem(
          Icons.share,
          'Gelişmiş Paylaşım',
          'Sosyal medyada güzel kartlar',
        ),
        _buildFeatureItem(
          Icons.history,
          'Geçmiş Kayıtları',
          'Tüm rüyalarınızı saklayın',
        ),
        _buildFeatureItem(
          Icons.priority_high,
          'Öncelikli Destek',
          '7/24 müşteri desteği',
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1A1A1A),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6C63FF),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreButton() {
    return Consumer<PaymentService>(
      builder: (context, paymentService, child) {
        return OutlinedButton(
          onPressed: paymentService.isLoading 
              ? null 
              : () => _restorePurchases(),
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
          child: paymentService.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                  ),
                )
              : const Text(
                  'Satın Almaları Geri Yükle',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        );
      },
    );
  }

  Future<void> _purchasePackage(String packageId) async {
    final paymentService = Provider.of<PaymentService>(context, listen: false);
    
    try {
      final success = await paymentService.purchasePackage(packageId);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$packageId paketi başarıyla satın alındı!'),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
          _loadLimitStatus(); // Limit durumunu yenile
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Satın alma başarısız: ${paymentService.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Satın alma hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    final paymentService = Provider.of<PaymentService>(context, listen: false);
    
    try {
      await paymentService.restorePurchases();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Satın almalar geri yüklendi'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        _loadLimitStatus(); // Limit durumunu yenile
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Geri yükleme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
