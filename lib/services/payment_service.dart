import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'limit_service.dart';

/// In-app purchase servisi
class PaymentService extends ChangeNotifier {
  static const String _androidKey = 'dreams_ai_android_key';
  static const String _iosKey = 'dreams_ai_ios_key';
  
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  bool _isAvailable = false;
  bool _isLoading = false;
  String? _error;
  List<ProductDetails> _products = [];
  
  // Paket ID'leri
  static const List<String> _productIds = [
    'dreams_7',
    'dreams_14', 
    'dreams_21',
    'dreams_28',
  ];

  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ProductDetails> get products => _products;

  /// Servisi başlat
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // In-app purchase mevcut mu kontrol et
      _isAvailable = await _inAppPurchase.isAvailable();
      
      if (!_isAvailable) {
        _error = 'In-app purchase mevcut değil';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Android için billing client'ı başlat
      // Android için özel ayarlar (gerekirse)
      if (Platform.isAndroid) {
        // Android özel ayarları buraya eklenebilir
      }

      // Ürün bilgilerini yükle
      await _loadProducts();
      
      // Satın alma stream'ini dinle
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription.cancel(),
        onError: (error) {
          _error = 'Satın alma hatası: $error';
          _isLoading = false;
          notifyListeners();
        },
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Başlatma hatası: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ürün bilgilerini yükle
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds.toSet());
      
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Bulunamayan ürünler: ${response.notFoundIDs}');
      }
      
      _products = response.productDetails;
      
      if (_products.isEmpty) {
        _error = 'Ürün bulunamadı';
      }
    } catch (e) {
      _error = 'Ürün yükleme hatası: $e';
    }
  }

  /// Satın alma güncellemelerini işle
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  /// Satın alma işlemini yönet
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.purchased) {
      // Satın alma başarılı
      await _processPurchase(purchaseDetails);
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      // Satın alma hatası
      _error = 'Satın alma hatası: ${purchaseDetails.error?.message}';
      notifyListeners();
    } else if (purchaseDetails.status == PurchaseStatus.pending) {
      // Satın alma bekliyor
      debugPrint('Satın alma bekliyor...');
    }

    // Satın alma işlemini tamamla
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  /// Satın alınan paketi işle
  Future<void> _processPurchase(PurchaseDetails purchaseDetails) async {
    try {
      final productId = purchaseDetails.productID;
      
      // LimitService'e paket satın alındığını bildir
      await LimitService.purchasePackage(productId);
      
      debugPrint('Paket satın alındı: $productId');
      
      // Başarı mesajı
      _error = null;
      notifyListeners();
      
    } catch (e) {
      _error = 'Paket işleme hatası: $e';
      notifyListeners();
    }
  }

  /// Paket satın al
  Future<bool> purchasePackage(String productId) async {
    if (!_isAvailable) {
      _error = 'In-app purchase mevcut değil';
      notifyListeners();
      return false;
    }

    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Ürün bulunamadı: $productId'),
    );

    try {
      _isLoading = true;
      notifyListeners();

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      
      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      
      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _error = 'Satın alma hatası: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Restore satın almalar
  Future<void> restorePurchases() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _inAppPurchase.restorePurchases();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Restore hatası: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Servisi temizle
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  /// Paket fiyatını döndür
  String getPackagePrice(String productId) {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      return product.price;
    } catch (e) {
      // Fallback fiyatlar
      switch (productId) {
        case 'dreams_7':
          return '\$4.00';
        case 'dreams_14':
          return '\$8.00';
        case 'dreams_21':
          return '\$12.00';
        case 'dreams_28':
          return '\$16.00';
        default:
          return '\$0.00';
      }
    }
  }

  /// Paket açıklamasını döndür
  String getPackageDescription(String productId) {
    switch (productId) {
      case 'dreams_7':
        return 'Haftalık 7 ek rüya yorumu';
      case 'dreams_14':
        return 'Haftalık 14 ek rüya yorumu';
      case 'dreams_21':
        return 'Haftalık 21 ek rüya yorumu';
      case 'dreams_28':
        return 'Haftalık 28 ek rüya yorumu';
      default:
        return 'Rüya yorumu paketi';
    }
  }
}
