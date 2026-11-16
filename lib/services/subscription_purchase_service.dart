import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'subscription_state.dart';

class SubscriptionPurchaseService {
  SubscriptionPurchaseService._();

  static final SubscriptionPurchaseService instance =
      SubscriptionPurchaseService._();

  static const String monthlyProductId = 'analyx_pro_monthly';
  static const String yearlyProductId = 'analyx_pro_yearly';

  static const Set<String> productIds = {monthlyProductId, yearlyProductId};

  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  List<ProductDetails> products = [];

  bool storeAvailable = false;
  bool initialized = false;

  bool _purchaseInProgress = false;

  // Transakcje aktualnie przetwarzane.
  final Set<String> _processingTransactions = {};

  // Transakcje już zweryfikowane przez backend.
  final Set<String> _verifiedTransactions = {};

  Future<void> initialize() async {
    if (initialized) return;

    debugPrint('IAP: INITIALIZING');

    storeAvailable = await _iap.isAvailable();

    debugPrint('IAP: STORE AVAILABLE = $storeAvailable');

    if (!storeAvailable) {
      initialized = true;
      return;
    }

    _purchaseSubscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        debugPrint('IAP PURCHASE STREAM ERROR: $error');
      },
    );

    await loadProducts();

    initialized = true;
  }

  Future<void> loadProducts() async {
    if (!storeAvailable) return;

    debugPrint('IAP: LOADING PRODUCTS');

    final response = await _iap.queryProductDetails(productIds);

    if (response.error != null) {
      debugPrint('IAP PRODUCT ERROR: ${response.error}');
    }

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('IAP PRODUCTS NOT FOUND: ${response.notFoundIDs}');
    }

    products = response.productDetails;

    for (final product in products) {
      debugPrint(
        'IAP PRODUCT: ${product.id} '
        '${product.price} ${product.currencyCode}',
      );
    }
  }

  ProductDetails? get monthlyProduct {
    for (final product in products) {
      if (product.id == monthlyProductId) return product;
    }
    return null;
  }

  ProductDetails? get yearlyProduct {
    for (final product in products) {
      if (product.id == yearlyProductId) return product;
    }
    return null;
  }

  Future<bool> purchaseMonthly() async {
    final product = monthlyProduct;

    if (product == null) {
      debugPrint('IAP: MONTHLY PRODUCT NOT AVAILABLE');
      return false;
    }

    return _purchase(product);
  }

  Future<bool> purchaseYearly() async {
    final product = yearlyProduct;

    if (product == null) {
      debugPrint('IAP: YEARLY PRODUCT NOT AVAILABLE');
      return false;
    }

    return _purchase(product);
  }

  Future<bool> _purchase(ProductDetails product) async {
    if (_purchaseInProgress) {
      debugPrint('IAP: PURCHASE ALREADY IN PROGRESS');
      return false;
    }

    if (!storeAvailable) {
      debugPrint('IAP: STORE NOT AVAILABLE');
      return false;
    }

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      debugPrint('IAP: PURCHASE BLOCKED - USER NOT LOGGED IN');
      return false;
    }

    _purchaseInProgress = true;

    try {
      debugPrint('IAP: START PURCHASE ${product.id}');

      final tokenResponse = await client.rpc('get_my_iap_account_token');

      final appAccountToken = tokenResponse.toString().trim();

      final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-'
        r'[0-9a-fA-F]{4}-'
        r'[0-9a-fA-F]{4}-'
        r'[0-9a-fA-F]{4}-'
        r'[0-9a-fA-F]{12}$',
      );

      if (!uuidRegex.hasMatch(appAccountToken)) {
        debugPrint('IAP: INVALID APP ACCOUNT TOKEN');
        return false;
      }

      if (client.auth.currentUser?.id != user.id) {
        debugPrint('IAP: USER CHANGED BEFORE PURCHASE');
        return false;
      }

      debugPrint('IAP: APP ACCOUNT TOKEN RECEIVED');

      final purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: appAccountToken,
      );

      final result = await _iap.buyNonConsumable(purchaseParam: purchaseParam);

      debugPrint('IAP: PURCHASE REQUEST SENT = $result');

      return result;
    } catch (e, stackTrace) {
      debugPrint('IAP PURCHASE ERROR: $e');
      debugPrint('$stackTrace');
      return false;
    } finally {
      _purchaseInProgress = false;
    }
  }

  Future<void> restorePurchases() async {
    if (!storeAvailable) return;

    debugPrint('IAP: RESTORING PURCHASES');

    try {
      await _iap.restorePurchases();
    } catch (e, stackTrace) {
      debugPrint('IAP RESTORE ERROR: $e');
      debugPrint('$stackTrace');
    }
  }

  String _transactionKey(PurchaseDetails purchase) {
    final purchaseId = purchase.purchaseID?.trim();

    if (purchaseId != null && purchaseId.isNotEmpty) {
      return '${purchase.productID}:$purchaseId';
    }

    final transactionData = purchase.verificationData.serverVerificationData;

    return '${purchase.productID}:'
        '${purchase.transactionDate ?? 'unknown'}:'
        '${transactionData.hashCode}';
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      debugPrint(
        'IAP PURCHASE UPDATE: '
        '${purchase.productID} ${purchase.status}',
      );

      switch (purchase.status) {
        case PurchaseStatus.pending:
          debugPrint('IAP: PURCHASE PENDING');
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _handleSuccessfulPurchase(purchase);
          break;

        case PurchaseStatus.error:
          debugPrint('IAP PURCHASE ERROR: ${purchase.error}');
          break;

        case PurchaseStatus.canceled:
          debugPrint('IAP PURCHASE CANCELED');
          break;
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    debugPrint('IAP: PURCHASE RECEIVED ${purchase.productID}');

    if (!productIds.contains(purchase.productID)) {
      debugPrint('IAP: UNKNOWN PRODUCT - VERIFICATION BLOCKED');
      return;
    }

    final transactionKey = _transactionKey(purchase);

    // Ta sama transakcja jest już przetwarzana.
    if (_processingTransactions.contains(transactionKey)) {
      debugPrint('IAP: DUPLICATE TRANSACTION - ALREADY PROCESSING');
      return;
    }

    // Transakcja była już zweryfikowana.
    // Nie wysyłamy ponownie JWS do Supabase.
    if (_verifiedTransactions.contains(transactionKey)) {
      debugPrint('IAP: TRANSACTION ALREADY VERIFIED');

      await _completePurchaseIfNeeded(purchase);
      return;
    }

    _processingTransactions.add(transactionKey);

    try {
      final signedTransaction =
          purchase.verificationData.serverVerificationData;

      if (signedTransaction.isEmpty) {
        throw Exception('Apple transaction data is empty');
      }

      debugPrint('IAP: SENDING TRANSACTION TO SUPABASE');

      final client = Supabase.instance.client;

      final response = await client.functions.invoke(
        'verify-apple-iap',
        body: {'signedTransaction': signedTransaction},
      );

      final data = response.data;

      // Apple transaction is valid, but belongs to another
      // already verified Avexa account.
      if (data is Map &&
          data['code'] == 'TRANSACTION_BELONGS_TO_ANOTHER_ACCOUNT' &&
          data['completeTransaction'] == true) {
        debugPrint('IAP: TRANSACTION BELONGS TO ANOTHER ACCOUNT');

        // Remember that the backend safely classified this transaction.
        // This prevents repeated verification attempts in this app session.
        _verifiedTransactions.add(transactionKey);

        await _completePurchaseIfNeeded(purchase);

        debugPrint('IAP: FOREIGN ACCOUNT TRANSACTION HANDLED');

        return;
      }

      if (data is! Map || data['success'] != true) {
        throw Exception('Server did not confirm the purchase');
      }

      // Backend potwierdził weryfikację i zapis transakcji.
      _verifiedTransactions.add(transactionKey);

      debugPrint('IAP: SERVER VERIFIED PURCHASE');

      // Odświeżamy centralny status PRO dopiero po
      // potwierdzeniu zakupu przez backend.
      await SubscriptionState.instance.refresh();

      debugPrint('IAP: CENTRAL SUBSCRIPTION STATE REFRESHED');

      await _completePurchaseIfNeeded(purchase);

      debugPrint('IAP: SERVER PURCHASE RESPONSE ACCEPTED');
    } catch (e, stackTrace) {
      debugPrint('IAP SERVER VERIFICATION FAILED: $e');
      debugPrint('$stackTrace');

      // Nie oznaczamy niezweryfikowanej transakcji jako poprawnej.
      // StoreKit może dostarczyć ją ponownie.
    } finally {
      _processingTransactions.remove(transactionKey);
    }
  }

  Future<void> _completePurchaseIfNeeded(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase) {
      debugPrint('IAP: NO PURCHASE COMPLETION REQUIRED');
      return;
    }

    try {
      await _iap.completePurchase(purchase);

      debugPrint('IAP: PURCHASE COMPLETED');
    } catch (e, stackTrace) {
      debugPrint('IAP PURCHASE COMPLETION FAILED: $e');
      debugPrint('$stackTrace');

      // Backend już zweryfikował zakup.
      // Przy kolejnym zdarzeniu spróbujemy zakończyć go ponownie.
    }
  }

  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
  }
}
