import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Mainform extends StatefulWidget {
  const Mainform({super.key});

  @override
  State<Mainform> createState() => _MainformState();
}

class _MainformState extends State<Mainform> {

  TextEditingController usernameController = TextEditingController();
  TextEditingController fullnameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  String? selectedGender;

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.white12,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white38),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff141E30), Color(0xff243B55)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                const SizedBox(height: 20),

                const Text(
                  "Create Profile",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                Card(
                  color: Colors.white10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [

                        /// Username + Fullname
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: usernameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration("Username"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: fullnameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration("Full Name"),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

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

                        const SizedBox(height: 15),

                        /// Password
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Password"),
                        ),

                        const SizedBox(height: 20),

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
                            onPressed: () {
                              if (selectedGender == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Select Gender")),
                                );
                              } else {
                                print("Form Submitted");
                              }
                            },
                            child: const Text(
                              "Submit",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}