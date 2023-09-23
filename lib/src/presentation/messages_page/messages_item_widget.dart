import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messenger_type_app/src/data/messages.dart';
import 'package:messenger_type_app/src/presentation/messages_page/messages_controller.dart';

class MessagesItemWidget extends StatefulWidget{
  final Messages message;
  final MessagesController controller;
   const MessagesItemWidget({super.key, required this.message ,required this.controller});

  @override
  State<MessagesItemWidget> createState() => _MessagesItemWidgetState();
}

class _MessagesItemWidgetState extends State<MessagesItemWidget> {
  AudioPlayer audioPlayer = AudioPlayer();

  late Source urlSource;
  bool isAudioPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    urlSource = UrlSource(widget.message.path);

    audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });

    });

    audioPlayer.onPositionChanged.listen((event) {
      setState(() {
        position = event;
      });

    });

    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isAudioPlaying = false;
      });
    });

    audioPlayer.onPlayerComplete.listen((event) {
      position = Duration.zero;
      setState(() {

      });
    });
  }
  @override
  Widget build(BuildContext context) {
   return  Column(
     crossAxisAlignment: CrossAxisAlignment.end,
     children: [
       Row(
         mainAxisAlignment: MainAxisAlignment.end,
         mainAxisSize: MainAxisSize.min,
         children: [
           widget.message.isVoiceMessage ? const SizedBox(): Container(
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
               child: Text(widget.message.message, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),),
             ),
           ),
         ],
       ),
       const SizedBox(height: 10,),
       widget.message.isVoiceMessage ? _buildVoiceMessageItemWidget(): const SizedBox()
     ],
   );
  }

 Widget _buildVoiceMessageItemWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: ()async{
            if(isAudioPlaying){
              await audioPlayer.pause();
              setState(() {
                isAudioPlaying = false;
              });
            }else{
              playVoiceMessage();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius:  BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                isAudioPlaying ? const Icon(Icons.pause): const Icon(Icons.play_arrow),
                Slider(
                    activeColor: Colors.black,
                    inactiveColor: Colors.white,
                    min: 0,
                    max: duration.inSeconds.toDouble(),
                    value: position.inSeconds.toDouble(), onChanged: onSeek),
              ],
            ),

          ),
        ),
      ],
    );
  }

  playVoiceMessage() async{
    audioPlayer.play(urlSource);
    Duration? duration = await audioPlayer.getDuration();
    if(duration != null) duration = duration;
    setState(() {
      isAudioPlaying = true;
    });
  }

  onSeek(double val) async{
    position = Duration(seconds: val.toInt());
    await audioPlayer.seek(position);
    await audioPlayer.resume();

  }
}