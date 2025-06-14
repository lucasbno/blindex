import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProtectedRoute extends StatelessWidget {
  final Widget child;

  const ProtectedRoute({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Faça login para acessar esta página',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/login', 
                  (route) => false,
                ),
                child: Text('Fazer Login'),
              ),
            ],
          ),
        ),
      );
    }
    
    return child;
  }
}
