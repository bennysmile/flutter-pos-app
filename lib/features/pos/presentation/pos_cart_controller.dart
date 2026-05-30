import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/product.dart';
import '../../../shared/models/sale.dart';

final posCartProvider = StateNotifierProvider<PosCartController, PosCartState>((
  ref,
) {
  return PosCartController();
});

class PosCartState {
  const PosCartState({
    this.items = const [],
    this.discountAmount = 0,
    this.paymentMethod = PaymentMethod.cash,
    this.cashReceived,
  });

  final List<PosCartItem> items;
  final double discountAmount;
  final PaymentMethod paymentMethod;
  final double? cashReceived;

  double get subtotal {
    return items.fold(0, (total, item) => total + item.lineTotal);
  }

  double get total {
    final calculated = subtotal - discountAmount;
    return calculated < 0 ? 0 : calculated;
  }

  double get amountReceived {
    if (paymentMethod == PaymentMethod.cash) {
      return cashReceived ?? 0;
    }
    return total;
  }

  double get changeAmount {
    if (paymentMethod != PaymentMethod.cash || cashReceived == null) {
      return 0;
    }
    final change = cashReceived! - total;
    return change < 0 ? 0 : change;
  }

  String? get cashReceivedError {
    if (paymentMethod != PaymentMethod.cash || cashReceived == null) {
      return null;
    }
    if (cashReceived! < total) {
      return 'Cash received cannot be less than total amount.';
    }
    return null;
  }

  bool get canCheckout {
    if (items.isEmpty || total < 0) {
      return false;
    }
    if (paymentMethod == PaymentMethod.cash) {
      return cashReceived != null && cashReceived! >= total;
    }
    return true;
  }

  PosCartState copyWith({
    List<PosCartItem>? items,
    double? discountAmount,
    PaymentMethod? paymentMethod,
    double? cashReceived,
    bool clearCashReceived = false,
  }) {
    return PosCartState(
      items: items ?? this.items,
      discountAmount: discountAmount ?? this.discountAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cashReceived: clearCashReceived
          ? null
          : cashReceived ?? this.cashReceived,
    );
  }
}

class PosCartItem {
  const PosCartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get lineTotal => product.price * quantity;
  bool get canIncrease => quantity < product.stockQuantity;

  PosCartItem copyWith({Product? product, int? quantity}) {
    return PosCartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class PosCartController extends StateNotifier<PosCartState> {
  PosCartController() : super(const PosCartState());

  bool addProduct(Product product) {
    if (product.stockQuantity <= 0) {
      return false;
    }

    final existingIndex = state.items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex == -1) {
      state = state.copyWith(
        items: [
          ...state.items,
          PosCartItem(product: product, quantity: 1),
        ],
      );
      return true;
    }

    return increaseQuantity(product.id);
  }

  bool increaseQuantity(String productId) {
    var didIncrease = false;
    final items = state.items.map((item) {
      if (item.product.id != productId) {
        return item;
      }
      if (!item.canIncrease) {
        return item;
      }
      didIncrease = true;
      return item.copyWith(quantity: item.quantity + 1);
    }).toList();

    if (didIncrease) {
      state = state.copyWith(
        items: items,
        discountAmount: _clampDiscount(state.discountAmount, items),
      );
    }

    return didIncrease;
  }

  void decreaseQuantity(String productId) {
    final items = <PosCartItem>[];
    for (final item in state.items) {
      if (item.product.id == productId) {
        if (item.quantity > 1) {
          items.add(item.copyWith(quantity: item.quantity - 1));
        }
      } else {
        items.add(item);
      }
    }

    state = state.copyWith(
      items: items,
      discountAmount: _clampDiscount(state.discountAmount, items),
    );
  }

  void removeItem(String productId) {
    final items = state.items
        .where((item) => item.product.id != productId)
        .toList();
    state = state.copyWith(
      items: items,
      discountAmount: _clampDiscount(state.discountAmount, items),
    );
  }

  void setDiscount(double value) {
    state = state.copyWith(
      discountAmount: value.clamp(0, state.subtotal).toDouble(),
    );
  }

  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(
      paymentMethod: method,
      clearCashReceived: method != PaymentMethod.cash,
    );
  }

  void setCashReceived(double? value) {
    state = state.copyWith(cashReceived: value);
  }

  void clear() {
    state = const PosCartState();
  }

  double _clampDiscount(double discount, List<PosCartItem> items) {
    final subtotal = items.fold(0.0, (total, item) => total + item.lineTotal);
    return discount.clamp(0, subtotal).toDouble();
  }
}
