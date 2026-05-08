import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gps/Mainpages.dart';
import 'package:gps/mainform.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();


  late AnimationController _controller;
  late Animation<double> _animation;
   bool isLoading = false;


  Future<UserCredential?> signInWithGoogle() async {
    try {

      final GoogleSignInAccount? googleUser =
      await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.access.tokon,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await FirebaseAuth.instance
          .signInWithCredential(credential);

      // SAVE USER DATA

      final prefs =
      await SharedPreferences.getInstance();

      prefs.setString(
        "username",
        userCredential.user?.displayName ?? "",
      );

      prefs.setString(
        "email",
        userCredential.user?.email ?? "",
      );

      return userCredential;

    } catch (e) {
      print(e);
    }

    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds:1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -1,end:1 ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.slowMiddle),
    );
  }
  @override
   void dispose (){
    _controller.dispose();
    super.dispose();
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
      return Container(
        height: 950,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.lerp(Colors.deepPurple, Colors.blue, _controller.value)!,
              Color.lerp(Colors.black, Colors.pink, _controller.value)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: child,
      );
    },
        child:SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 120),
             /* TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.5, end: 1),
                duration: const Duration(seconds: 1),
                curve: Curves.elasticInOut,
                builder: (context, double scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: const Icon(
                      Icons.lock_outline,
                      size: 80,
                      color: Colors.blueAccent,
                    ),
                  );
                },
              ),*/
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(3, _animation.value),
                    child: child,
                  );
                },
                child:Image.network("https://static.vecteezy.com/system/resources/thumbnails/009/085/230/small/cartoon-cute-dogs-with-big-bone-vector.jpg", height: 50,)

              ),

              SizedBox(height: 20),
              /// 🔹 Title
              const Text(
                "Welcome Back!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Login to continue",
                style: TextStyle(color: Colors.white70),
              ),

               SizedBox(height: 40),

              /// 🔹 Card Container
              Padding(
                padding:  EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),

                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle:
                          const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.email,
                              color: Colors.white70),
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Password
                      TextFormField(
                        controller: _passController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle:
                          const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.lock,
                              color: Colors.white70),
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      /// Forgot
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                      ),

                      /// Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            await Future.delayed(Duration(seconds: 2)); // fake delay
                            setState(() {
                              isLoading = false;
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => Mainpage()),
                            );
                          },
                          child: Text("Login"),
                        )
                      ),

                      const SizedBox(height: 20),

                      /// Facebook
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async{
                            UserCredential? user = await signInWithGoogle();
                            if(user != null){
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Mainpage()));
                            }
                          },
                          icon: const Icon(Icons.facebook,
                              color: Colors.white),
                          label: const Text(
                            "Continue with Facebook",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// Gmail
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon:
                          const Icon(Icons.email, color: Colors.white),
                          label: const Text(
                            "Continue with Gmail",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// Signup
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>Mainform()));
                            },
                            child:  Text(
                              "Sign Up",
                              style:
                              TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
    );
  }
}


