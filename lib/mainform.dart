import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


 class Mainform extends StatefulWidget {
    Mainform({super.key});

  @override
  State<Mainform> createState() => _MainformState();
}



class _MainformState extends State<Mainform> {
   TextEditingController usernameController = TextEditingController();
   TextEditingController fullnameController = TextEditingController();
   TextEditingController phoneController = TextEditingController();
   TextEditingController EmailController = TextEditingController();
   TextEditingController passwordController = TextEditingController();



  String? selectedGender;

   InputDecoration  _inputDecoration (String lable ){
     return InputDecoration(
       labelText: lable,
       labelStyle: TextStyle(
         color: Colors.white,
       ),
       enabledBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(12),
         borderSide: BorderSide(color: Colors.white54)
       ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black.withOpacity(0.1), width: 2 ),
          borderRadius: BorderRadius.circular(12)
        )
     );
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       body: Container(
         child: Column(
           children: [
             SizedBox(height: 200,),
             Card(
               color: Colors.white10.withOpacity(0.2),
               shape: RoundedRectangleBorder(borderRadius : BorderRadiusGeometry.circular(15),
               ),
         child: Column(
           children: [

             Row(
               children: [
                 Expanded(child:ListTile(
                   leading: Icon(Icons.person,color: Colors.black,),
                   title: TextFormField(
                     controller: usernameController,
                     decoration: _inputDecoration('username'),
                   )
                 )),
                 Expanded(child: ListTile(
                   leading: Icon(Icons.person_2,color: Colors.black,),
                   title: TextFormField(
                     decoration: _inputDecoration("Full name "),
                   )
                 )),

               ],
             ),
             ListTile(
               leading: Icon(Icons.calendar_today,color: Colors.black,),
               title: TextFormField(
  readOnly: true,
                 onTap:() async{
    DateTime? pickData = await showDatePicker(context: context,
        initialDate: DateTime(2000),
        firstDate: DateTime(1900), lastDate: DateTime.now());
     if ( pickData != null ){

     }
     } ,
                 decoration: _inputDecoration(" Date of Birth ").copyWith(
                   suffix: Icon(Icons.calendar_today , color: Colors.white,)
                 )

               ),),
              ListTile(leading:Icon(Icons.phone,color: Colors.black,),
                title: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: _inputDecoration("Phone"),
                  validator: (value) => value!.isEmpty? " Date if Birth is required " : null ,
                )
              ),

              SizedBox(height: 10,),

              ListTile(
                leading: Icon(Icons.email,color: Colors.white,),
                  title: TextFormField(
                    decoration: _inputDecoration("Email"),
                  ),
              ),
              ListTile(
                leading: Icon(Icons.password, color: Colors.black,),
                title: TextFormField(
                  decoration: _inputDecoration("Password"),
                  validator: (value){
                    if ( value == null || value.isEmpty ){
                      return "passwordis required";}
                      if (value.length < 6 ){
                        return "password must be at least 6 charachers ";
                      }
                    return null;
                  },
                ),
              ),
             Card(
               //   elevation: 2,
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(10),),color: Colors.white70.withOpacity(0.500),
               child: Padding(
                 padding: EdgeInsets.symmetric(vertical: 8),
                 child: Column(
                   children: [
                     const ListTile(
                       leading: Icon(Icons.wc,color: Colors.white,),
                       title: Text("Select Gender",style: TextStyle(fontWeight: FontWeight.w300 ),),
                     ),
                     RadioListTile<String>(
                       title: const Text("Male",style: TextStyle(color: Colors.white),),
                       value: "Male",
                       groupValue: selectedGender,
                       onChanged: (value) =>
                           setState(() => selectedGender = value),
                     ),
                     RadioListTile<String>(
                       title:  Text("Female",style: TextStyle(color: Colors.white)),
                       value: "Female",
                       groupValue: selectedGender,
                       onChanged: (value) =>
                           setState(() => selectedGender = value),
                     ),


      if (selectedGender == null)
                       Padding(
                         padding: EdgeInsets.only(left: 16.0),
                         child: Align(
                           alignment: Alignment.centerLeft,
                           child: Text(
                             "Please select gender",
                             style:
                             TextStyle(color: Colors.red, fontSize: 12),
                           ),
                         ),
                       ),
                   ],
                 ),
               ),
             ),
         ElevatedButton(onPressed: (){}, child: Text("Done"))
           ],
         ),
             ),
         ],

         ),
       ),
     );
   }
}
