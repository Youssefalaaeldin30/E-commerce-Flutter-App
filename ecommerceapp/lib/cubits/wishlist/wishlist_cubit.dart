import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/product.dart';
part 'wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  final FirebaseFirestore firestore;
  String? _uid;

  WishlistCubit(this.firestore) : super(WishlistInitial());

  Future<void> loadWishlist(String? uid) async {
    if (uid == null || uid.isEmpty) {
      emit(WishlistLoaded([]));
      return;
    }

    _uid = uid;
    emit(WishlistLoading());

    try {
      final doc = await firestore.collection('wishlists').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        emit(WishlistLoaded([]));
        return;
      }

      final data = doc.data()!;
      final items = (data['items'] as List<dynamic>? ?? [])
          .map((e) => Product.fromData('', Map<String, dynamic>.from(e)))
          .toList();

      emit(WishlistLoaded(items));
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  Future<void> _save(List<Product> items) async {
    if (_uid == null) return;
    await firestore.collection('wishlists').doc(_uid).set({
      'uid': _uid,
      'items': items.map((e) => e.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addToWishlist(Product p) async {
    final stateNow = state;
    List<Product> items = [];

    if (stateNow is WishlistLoaded) {
      items = List.from(stateNow.items);
    }

    final exists = items.any((it) => it.id == p.id);
    if (!exists) items.add(p);

    emit(WishlistLoaded(items));
    await _save(items);
  }

  Future<void> removeFromWishlist(Product p) async {
    final stateNow = state;
    if (stateNow is! WishlistLoaded) return;

    final items = List<Product>.from(stateNow.items);
    items.removeWhere((it) => it.id == p.id);
    emit(WishlistLoaded(items));
    await _save(items);
  }

  bool isInWishlist(Product p) {
    final stateNow = state;
    if (stateNow is WishlistLoaded) {
      return stateNow.items.any((it) => it.id == p.id);
    }
    return false;
  }
}
