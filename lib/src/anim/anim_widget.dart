import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:messenger_type_app/src/constant/constants.dart';

class AnimWidget extends StatelessWidget{
  const AnimWidget({super.key, this.animation  = loginAnim});

  final String animation;
  @override
  Widget build(BuildContext context) {
   return SizedBox(
       height: 300,
       child: Lottie.asset(animation, repeat: true, reverse: true));
  }
  
}