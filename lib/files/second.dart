import 'package:flutter/material.dart';
import 'package:gps/files/thired.dart';
import 'forth.dart';
class second extends StatefulWidget {
  const second({super.key});

  @override
  State<second> createState() => _secondState();
}

class _secondState extends State<second> {
 int selectedIndex = -1;



 final List<Map<String, dynamic>> languages = [
   {"name": "English", "flag": "🇺🇸"},
   {"name": "Bahasa Indonesia", "flag": "🇮🇩"},
   {"name": "हिन्दी", "flag": "🇮🇳", "locale": "hi"},
   {"name": "Española (Spanish)", "flag": "🇪🇸"},
   {"name": "ไทย (Thai)", "flag": "🇹🇭"},

 ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
      child: Column(
        children: [
          Padding(
            padding:  EdgeInsets.all(20.0),
            child: Text("chosse your prefrence language",textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.amber,
            ),
            ),

          ),
          Text( "From the below languages, Please choose your native language, later you can change language from settings.",
          textAlign: TextAlign.center,style: TextStyle(
              fontSize: 12 , fontWeight: FontWeight.w500), ),
             SizedBox(height: 50,),

          Expanded(child: ListView.builder(
               itemCount: languages.length,
              itemBuilder: (context , index){
                 return GestureDetector(
                   onTap: () {
                     setState(() {
                       selectedIndex = index;
                     });
                   },
                   child: Container(
                     margin: EdgeInsets.only(bottom: 15),
                     decoration: BoxDecoration(
                       color: selectedIndex == index ?
                           Colors.amber.shade50:Colors.white,
                       borderRadius: BorderRadius.circular(15),
                       border: Border.all(color: Colors.grey.shade300),
                     boxShadow:[
                       BoxShadow(
                       color: Colors.grey.shade200,
                       blurRadius: 5
                     )
                         ] ),
                       child: Row(
                         children: [
                           Text(languages[index]["flag"]!,
                           style: TextStyle(
                             fontSize:40,
                           ),
                           ),
                           SizedBox(width: 20,),
                           Expanded(child: Text(languages[index]["name"]!,
                           style: TextStyle(
                             fontSize: 20,
                             fontWeight: FontWeight.w600
                           ),
                           )),
                           if(selectedIndex == index)
                             Icon(Icons.check_circle,
                             color: Colors.amber,)
                         ],
                       ),
                   ),
                 );
              } )),
               ElevatedButton(
                   style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.amber, shape: RoundedRectangleBorder(
                 borderRadius: BorderRadiusGeometry.circular(15),


               ),shadowColor: Colors.black
               ),
                   onPressed: () {
                     if (selectedIndex != -1) {
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (_) => const Thired(),
                         ),
                       );
                     } else {
                       ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                           content: Text("Choose your preferred language")
                         ),
                       );
                     }
                   }, child: Text("Next",))
        ],
      ),
      ),
    );
  }
}
