import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/cubits/cart/cart_cubit.dart';
import 'package:ecommerceapp/cubits/onboard/onboarding_cubit.dart';
import 'package:ecommerceapp/cubits/products/products_cubit.dart';
import 'package:ecommerceapp/cubits/wishlist/wishlist_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'cubits/auth/auth_cubit.dart';
import 'screens/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  runApp(MyApp(firebaseAuth: firebaseAuth, firestore: firestore));
}

class MyApp extends StatelessWidget {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  MyApp({super.key, required this.firebaseAuth, required this.firestore});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(firebaseAuth, firestore)..start(),
        ),
        BlocProvider(create: (_) => OnboardingCubit()),
        BlocProvider(
          create: (_) =>
              CartCubit(firestore)
                ..loadCart(FirebaseAuth.instance.currentUser?.uid ?? ""),
        ),

        BlocProvider(create: (_) => ProductsCubit(firestore)..fetchProducts()),
        BlocProvider(
          create: (_) {
            final uid = firebaseAuth.currentUser?.uid;
            return WishlistCubit(firestore)..loadWishlist(uid);
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF7A42F4),
          textTheme: GoogleFonts.cairoTextTheme(),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
