import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messenger_type_app/src/data/messages.dart';

class MessagesItemWidget extends StatelessWidget{
  final Messages message;
  const MessagesItemWidget({super.key, required this.message});
  @override
  Widget build(BuildContext context) {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.end,
     children: [
       Row(
         mainAxisAlignment: MainAxisAlignment.end,
         mainAxisSize: MainAxisSize.min,
         children: [
           Container(
             margin: const EdgeInsets.all(10),
             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
             decoration: const BoxDecoration(
               color: Colors.amber,
               borderRadius:  BorderRadius.only(
                   topLeft: Radius.circular(8),
                   bottomLeft: Radius.circular(8),
                   topRight: Radius.circular(8)),
             ),
             child: ConstrainedBox(
               constraints: const BoxConstraints(maxWidth: 300),
               child: Text(message.message, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),),
             ),

             //
             // Column(
             //   children: [
             //
             //     const SizedBox(height: 10,),
             //     message.isVoiceMessage ? _buildVoiceMessageItemWidget(): const SizedBox()
             //   ],
             // ),
           ),
         ],
       ),
       const SizedBox(height: 10,),
       message.isVoiceMessage ? _buildVoiceMessageItemWidget(): const SizedBox()
     ],
   );
  }

 Widget _buildVoiceMessageItemWidget() {
 return  Container(
       margin: const EdgeInsets.all(10),
       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
       decoration:  BoxDecoration(
         color: Colors.amber,
         borderRadius:  BorderRadius.circular(50),
       ),
       child: ConstrainedBox(
         constraints: const BoxConstraints(maxWidth: 300),
         child: Text('Voice Message Here', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),),
       )
 );
  }

}