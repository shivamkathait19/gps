import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gps/Mainpages.dart';
import 'package:shared_preferences/shared_preferences.dart';




class Mainform extends StatefulWidget {
  const Mainform({super.key});

  @override
  State<Mainform> createState() => _MainformState();
}

class _MainformState extends State<Mainform>
with SingleTickerProviderStateMixin
{

  TextEditingController usernameController = TextEditingController();
  TextEditingController fullnameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  String? selectedGender;
  late AnimationController _controller;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller= AnimationController(vsync: this, duration: Duration(seconds: 5))..repeat(reverse: true);
  }


  @override
  void dispose (){
    _controller.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.white12,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:  BorderSide(color: Colors.black.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide:  BorderSide(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child ){
            return Container(
              height: 950,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(Colors.pink, Colors.orange, _controller.value)!,
                    Color.lerp(Colors.white, Colors.pink, _controller.value)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: child,
            );
          },

          child :Container(
            child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: 20),
                 Text(
                  "Create Profile",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 20),
                Card(
                  color: Colors.white10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: usernameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration("Username"),

                              ),

                             ),


                             SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: fullnameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration("Full Name"),

                              ),

                            ),
                          ],

                        ),

                        SizedBox(height: 15),

                        /// DOB
                        TextFormField(
                          controller: dobController,
                          readOnly: true,
                          style: const TextStyle(color: Colors.white),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime(2000),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );

                            if (picked != null) {
                              dobController.text =
                              "${picked.day}/${picked.month}/${picked.year}";
                            }
                          },
                          decoration: _inputDecoration("Date of Birth")
                              .copyWith(
                            suffixIcon: const Icon(Icons.calendar_today,
                                color: Colors.white),
                          ),
                        ),

                        const SizedBox(height: 15),

                        /// Phone
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: _inputDecoration("Phone"),
                        ),

                        const SizedBox(height: 15),

                        /// Email
                        TextFormField(
                          controller: emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Email"),

                        ),

                         SizedBox(height: 15),

                        /// Password
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Password"),

                        ),

                         SizedBox(height: 20),

                        /// Gender
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              const ListTile(
                                leading: Icon(Icons.wc, color: Colors.white),
                                title: Text("Select Gender",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              RadioListTile<String>(
                                title: const Text("Male",
                                    style: TextStyle(color: Colors.white)),
                                value: "Male",
                                groupValue: selectedGender,
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value;
                                  });
                                },
                              ),
                              RadioListTile<String>(
                                title: const Text("Female",
                                    style: TextStyle(color: Colors.white)),
                                value: "Female",
                                groupValue: selectedGender,
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value;
                                  });
                                },
                              ),

                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              backgroundColor: Colors.orange,
                            ),

                            onPressed: () async {

                              // FIRST CHECK EMPTY FIELDS
                              if (usernameController.text.isEmpty ||
                                  fullnameController.text.isEmpty ||
                                  phoneController.text.isEmpty ||
                                  emailController.text.isEmpty ||
                                  dobController.text.isEmpty ||
                                  selectedGender == null) {

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please fill all fields"),
                                  ),
                                );

                              } else {

                                // SAVE DATA
                                final prefs = await SharedPreferences.getInstance();
                                //final prefs = await SharedPreferences.getInstance();

                                await prefs.setString(
                                  "email",
                                  emailController.text,
                                );

                                await prefs.setString(
                                  "password",
                                  passwordController.text,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Account Created"),
                                  ),
                                );
                                await prefs.setString("user", usernameController.text);
                                await prefs.setString("fullname", fullnameController.text);
                                await prefs.setString("phone", phoneController.text);
                                await prefs.setString("email", emailController.text);
                                await prefs.setString("dob", dobController.text);
                                await prefs.setString("gender", selectedGender ?? "");

                                // NEXT PAGE
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Mainpage(),
                                  ),
                                );
                              }
                            },

                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          ),

                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }
}