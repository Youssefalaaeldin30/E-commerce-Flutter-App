import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/cart_item.dart';
import '/models/product.dart';
part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final FirebaseFirestore firestore;
  String? _uid;
  CartCubit(this.firestore) : super(CartInitial());

  Future<void> loadCart(String uid) async {
    _uid = uid;
    emit(CartLoading());
    try {
      final doc = await firestore.collection('carts').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        emit(CartLoaded([]));
        return;
      }
      final data = doc.data()!;
      final items = (data['items'] as List<dynamic>? ?? [])
          .map((e) => CartItem.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _save() async {
    if (_uid == null) return;
    final stateNow = state;
    if (stateNow is CartLoaded) {
      final itemsMap = stateNow.items.map((e) => e.toMap()).toList();
      await firestore.collection('carts').doc(_uid).set({
        'uid': _uid,
        'items': itemsMap,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> addToCart(Product p) async {
    final stateNow = state;
    List<CartItem> items = [];
    if (stateNow is CartLoaded) items = List.from(stateNow.items);
    final idx = items.indexWhere((it) => it.productId == p.id);
    if (idx >= 0) {
      items[idx].qty += 1;
    } else {
      items.add(
        CartItem(
          productId: p.id,
          name: p.name,
          price: p.price,
          image: p.image,
          qty: 1,
        ),
      );
    }
    emit(CartLoaded(items));
    await _save();
  }

  Future<void> removeFromCart(String productId) async {
    final stateNow = state;
    if (stateNow is! CartLoaded) return;
    final items = List<CartItem>.from(stateNow.items);
    items.removeWhere((it) => it.productId == productId);
    emit(CartLoaded(items));
    await _save();
  }

  Future<void> increaseQty(String productId) async {
    final stateNow = state;
    if (stateNow is! CartLoaded) return;
    final items = List<CartItem>.from(stateNow.items);
    final idx = items.indexWhere((it) => it.productId == productId);
    if (idx >= 0) {
      items[idx].qty += 1;
      emit(CartLoaded(items));
      await _save();
    }
  }

  Future<void> decreaseQty(String productId) async {
    final stateNow = state;
    if (stateNow is! CartLoaded) return;
    final items = List<CartItem>.from(stateNow.items);
    final idx = items.indexWhere((it) => it.productId == productId);
    if (idx >= 0 && items[idx].qty > 1) {
      items[idx].qty -= 1;
      emit(CartLoaded(items));
      await _save();
    } else if (idx >= 0 && items[idx].qty == 1) {
      items.removeAt(idx);
      emit(CartLoaded(items));
      await _save();
    }
  }

  double subtotal() {
    final stateNow = state;
    if (stateNow is! CartLoaded) return 0.0;
    return stateNow.items.fold(0.0, (s, it) => s + (it.price * it.qty));
  }
}
