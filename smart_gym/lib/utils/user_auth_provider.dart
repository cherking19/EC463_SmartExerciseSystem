import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationProvider {
  final FirebaseAuth firebaseAuth;
  AuthenticationProvider(this.firebaseAuth);
  Stream<User?> get authState => firebaseAuth.idTokenChanges();
  
 }