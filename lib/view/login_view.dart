import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            
            //Logo
            //TODO Make App Logo asset in .svg (vector) format
            SvgPicture.asset(
              'assets/svg/placeholder-app-logo.svg',
              width: 200,
              height: 200,
            ),

            //Login card
            logInForm(context),
          ],
        ),
      ),
    );
  }

  Widget logInForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0), // To avoid edges
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5, // Optional: Adds shadow to the card
        color: Theme.of(context).cardColor, // Your card color
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding inside the card
          child: Column(
            mainAxisSize: MainAxisSize.min, // Makes the column size fit content
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
            children: [
              // Title
              Center(
                child: Text(
                  'Log In',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center, // Custom title style
                ),
              ),

              const SizedBox(height: 26), // Spacing between title and fields

              // Username TextField
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, // Accent color for border
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20), // Space between fields

              // Password TextField
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24), // Space before button

              // Login Button
              SizedBox(
                width: double.infinity, // Make the button stretch
                child: ElevatedButton(
                  onPressed: () {
                    // Handle login logic
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20), // Taller button
                  ),
                  child: Text('Log In'),
                ),
              ),

              SizedBox(height: 12),

              // Signup Button
              SizedBox(
                width: double.infinity, // Make the button stretch
                child: OutlinedButton(
                  onPressed: () {
                    //Handle Sign Up Logic
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    side: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20)
                  ), 
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              //Forgot Password TextButton

              Center(
                child: TextButton(
                  onPressed: () {
                    // Add the functionality for password recovery here
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor, // Use your accent color
                  ),
                  child: Text('Forgot your password?', style: TextStyle(fontSize: 16), textAlign: TextAlign.center,),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
