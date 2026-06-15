import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'app_settings.dart';

/// Singleton that manages all Google Play In-App Purchase logic.
///
/// Usage:
///   await IAPService.instance.initialize();   // call once in main()
///   IAPService.instance.buy();                // launch billing flow
///   IAPService.instance.restorePurchases();   // restore on demand
class IAPService {
  IAPService._();
  static final IAPService instance = IAPService._();

  // ── Product ID — must match exactly what is set in Google Play Console ──
  static const String _productId = 'remove_ads';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  ProductDetails? _product;

  /// Whether the store is available on this device.
  bool _available = false;

  // ── Initialize ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _available = await _iap.isAvailable();
    if (!_available) {
      debugPrint('IAPService: Store not available');
      return;
    }

    // Listen for purchase updates from the billing SDK
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (e) => debugPrint('IAPService: purchaseStream error — $e'),
    );

    // Load product details from Play Console
    await _loadProduct();

    // Restore any prior purchases (e.g. after reinstall)
    await _iap.restorePurchases();
  }

  Future<void> _loadProduct() async {
    final response = await _iap.queryProductDetails({_productId});
    if (response.error != null) {
      debugPrint('IAPService: queryProductDetails error — ${response.error}');
      return;
    }
    if (response.productDetails.isEmpty) {
      debugPrint('IAPService: No products found for id=$_productId');
      return;
    }
    _product = response.productDetails.first;
    debugPrint('IAPService: Product loaded — ${_product!.title} ${_product!.price}');
  }

  // ── Purchase ──────────────────────────────────────────────────────────

  /// Returns the price string from Play Store (e.g. "₹99.00"), or null if
  /// not yet loaded.
  String? get productPrice => _product?.price;

  /// Returns the product title, or a fallback.
  String get productTitle => _product?.title ?? 'Remove All Ads';

  /// Launches the Google Play billing flow.
  Future<void> buy() async {
    if (!_available) {
      debugPrint('IAPService: Store not available — cannot buy');
      return;
    }
    if (_product == null) {
      // Try loading again in case it failed earlier
      await _loadProduct();
    }
    if (_product == null) {
      debugPrint('IAPService: Product not found — cannot buy');
      return;
    }
    final param = PurchaseParam(productDetails: _product!);
    // non-consumable one-time purchase
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  /// Manually triggers purchase restore (e.g. from "Restore Purchase" button).
  Future<void> restorePurchases() async {
    if (!_available) return;
    await _iap.restorePurchases();
  }

  // ── Purchase stream handler ───────────────────────────────────────────

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      _handlePurchase(purchase);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.productID != _productId) return;

    debugPrint('IAPService: purchase status = ${purchase.status}');

    switch (purchase.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        // Deliver the benefit
        await AppSettings.instance.setPremium(true);
        debugPrint('IAPService: Premium activated ✓');
        break;

      case PurchaseStatus.error:
        debugPrint('IAPService: Purchase error — ${purchase.error?.message}');
        break;

      case PurchaseStatus.canceled:
        debugPrint('IAPService: Purchase canceled');
        break;

      case PurchaseStatus.pending:
        debugPrint('IAPService: Purchase pending…');
        break;
    }

    // Always complete the purchase to acknowledge it with Google Play
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  // ── Dispose ───────────────────────────────────────────────────────────

  void dispose() {
    _subscription?.cancel();
  }
}
