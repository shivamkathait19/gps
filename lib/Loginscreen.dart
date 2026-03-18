import 'package:flutter/material.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  @override
      Widget build(BuildContext context) {
    return  Scaffold(
      body:Container(
        decoration: BoxDecoration(
          color: Colors.black
        ),
        child:SingleChildScrollView(
          child: Stack(
            children: [
            SafeArea(
              child:SingleChildScrollView(
                child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRect(
                ),
                SizedBox(height: 200,),
                Text("Welcome back!",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 26,
                  fontWeight: FontWeight.bold
                ),),
                Text("Login to continue",style: TextStyle(color: Colors.white54),),
              SizedBox(height: 40,),
                Padding(padding: EdgeInsetsGeometry.all(20),
                child: Container(
                  height: 505,
                  width: 500,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                      blurRadius : 10,
                        offset: Offset(0, 5),
                      )
                    ]
                  ),
                  child: Form(child: Column(
                    children: [
                      Padding(padding: EdgeInsets.only(left: 10, right: 10,top: 20),
                     child:  TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: Colors.white10),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.email,color: Colors.white70,),
                         filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        )
                      ),
                ),
                ),
              SizedBox(height: 20),
              Padding(padding: EdgeInsets.only(left: 10,right: 10),
              child: TextFormField(
                 controller: _passController,
                 obscureText: true,
                 style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'password',
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.lock,color: Colors.white,),
                    filled : true,
                  fillColor: Colors.grey[900],
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                   )

                ),
               )
              ),
                 Align(
                   alignment: Alignment.centerRight,
                 child: TextButton(onPressed: (){}, child: Text('Forgot Password?',
                   style: TextStyle(color: Colors.blueAccent),)),
                 ),

                      ElevatedButton(onPressed:(){}, child: Text('Login ',style: TextStyle(color: Colors.blue),)),
                     SizedBox(
                       width: double.infinity,
                       child: ElevatedButton.icon(onPressed: () {},
                           icon: Icon(Icons.facebook,color: Colors.white,),
                           label: Text("Continue with Facebook",style: TextStyle(color: Colors.black),),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.blueAccent
                       ),
                       ),
                     ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(onPressed: () {},
                          icon: Icon(Icons.eighteen_mp,color: Colors.white,),
                          label: Text("Continue with Facebook",style: TextStyle(color: Colors.black),),

                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent
                          ),
                        ),
                      ),
                      SizedBox(height: 50,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Dont have an account? ',
                          style: TextStyle(color: Colors.white),
                          ),
                          TextButton(onPressed: (){}, child: TextButton(onPressed: (){}, child: Text("sign up ",style: TextStyle(color: Colors.blue),))),
                        ],

                      )
                ],
            )
              )
            ),
                ),
]
    ),
        ),
    ),
          ]
    )
        ),
      ),
    );

  }
}
