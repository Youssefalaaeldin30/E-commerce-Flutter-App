import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/product.dart';
part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final FirebaseFirestore firestore;
  Timer? _debounce;

  ProductsCubit(this.firestore) : super(ProductsInitial());

  Future<void> fetchProducts() async {
    emit(ProductsLoading());
    try {
      final snap = await firestore.collection('products').get();
      final products = snap.docs
          .map((d) => Product.fromData(d.id, d.data()))
          .toList();
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> fetchProductsByCategory(String? category) async {
    emit(ProductsLoading());
    try {
      Query query = firestore.collection('products');

      if (category != null && category.isNotEmpty && category != "All") {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();
      final products = snapshot.docs
          .map(
            (doc) =>
                Product.fromData(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();

      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> searchProducts(String query) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query.isEmpty) {
        await fetchProducts();
        return;
      }

      emit(ProductsLoading());

      try {
        final lowerQuery = query.toLowerCase();

        final snapshot = await firestore.collection('products').get();

        final products = snapshot.docs
            .map((doc) => Product.fromData(doc.id, doc.data()))
            .where((p) => p.name.toLowerCase().contains(lowerQuery))
            .toList();

        emit(ProductsLoaded(products));
      } catch (e) {
        emit(ProductsError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
