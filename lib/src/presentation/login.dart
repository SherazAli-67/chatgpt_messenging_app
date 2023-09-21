import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messenger_type_app/src/anim/anim_widget.dart';
import 'package:messenger_type_app/src/config/app_controller.dart';
import 'package:messenger_type_app/src/constant/constants.dart';
import 'package:messenger_type_app/src/data/authentication.dart';
import 'package:messenger_type_app/src/presentation/speech_recognizer.dart';
import 'package:messenger_type_app/src/utils/utility.dart';

class Login extends StatefulWidget{
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  bool showPassword = true;


  @override
  void initState() {
    super.initState();
    _initUser();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _pinController.dispose();
    _pinFocusNode.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
   return Scaffold(
     body: SafeArea(
       child: Padding(
         padding: const EdgeInsets.all(8.0),
         child: SingleChildScrollView(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const AnimWidget(),
               Text('Enter your Credentials',style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600),),
               const SizedBox(height: 20,),
               _buildTextField(_pinController, _pinFocusNode, 'Enter your name'),
               const SizedBox(height: 10,),
               _buildTextField(_passwordController, _passwordFocusNode, 'Enter your pin', isPassword: true),
               const SizedBox(height: 20,),
               InkWell(
                 onTap: () async{
                   String pin = _pinController.text.trim();
                   String password = _passwordController.text.trim();

                   if(pin.trim().isEmpty){
                     return;
                   }

                   if(password.trim().isEmpty){
                     return;
                   }

                   AppController appController = Get.find();
                   String userID = DateTime.now().millisecond.toString();

                   await appController.appDao.insertUser(Authentication(id: userID, pin: pin, password: password));
                   await Utility.saveLoginInfo(true);
                   await Utility.saveUserInfo(userIDKey, userID);
                   Get.off(()=> const SpeechSampleApp());
                 },
                 child: Container(
                   alignment: Alignment.center,
                   width: size.width,
                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(5),
                     color: Colors.amber,
                   ),
                   child: Text('Continue', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),),
                 ),
               )
             ],
           ),
         ),
       ),
     ),
   );
  }

  TextField _buildTextField(TextEditingController controller, FocusNode focusNode, String hintText, {bool isPassword = false}) {
    return TextField(
             keyboardType: isPassword ? TextInputType.number: TextInputType.text,
             controller: controller,
             focusNode: focusNode,
             obscureText: isPassword ? showPassword: false,
             onTapOutside: (val)=> focusNode.unfocus(),
             decoration: InputDecoration(
               suffixIcon: isPassword ? IconButton(onPressed: (){
                 setState(() {
                   showPassword = !showPassword;
                 });
               }, icon: showPassword ?  const Icon(Icons.visibility) : const Icon(Icons.visibility_off)): const SizedBox(),
               border: const OutlineInputBorder(),
               focusedBorder: const OutlineInputBorder(),
               hintText: hintText,
             ),
           );
  }



  void _initUser() async{
    bool? isLoggedIn = await Utility.getLoginInfo();
    if(isLoggedIn != null){
      if(isLoggedIn){
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const SpeechSampleApp()));
      }
    }
  }
}