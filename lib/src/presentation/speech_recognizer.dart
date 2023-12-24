import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messenger_type_app/src/anim/anim_widget.dart';
import 'package:messenger_type_app/src/constant/constants.dart';
import 'package:messenger_type_app/src/presentation/messages_page/messages_controller.dart';
import 'package:messenger_type_app/src/presentation/messages_page/messages_item_widget.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechSampleApp extends StatefulWidget {
  const SpeechSampleApp({Key? key}) : super(key: key);

  @override
  State<SpeechSampleApp> createState() => _SpeechSampleAppState();
}

class _SpeechSampleAppState extends State<SpeechSampleApp> {

  final SpeechToText speech = SpeechToText();

  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  MessagesController messagesController = Get.put(MessagesController());

  late ScrollController scrollController;

  final _logEvents = false;
  final _onDevice = false;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = '';
  List<LocaleName> _localeNames = [];

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(() {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
    initSpeechState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow,
          centerTitle: false,
          title: Row(
            children: [
              const CircleAvatar(backgroundImage: AssetImage('assets/images/user_img.jpg'),),
              const SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dummy User', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w600),),
                  Text('Online', style: GoogleFonts.manrope(fontSize: 14, color: Colors.green),)
                ],
              ),
            ],
          ), leading: IconButton(onPressed: ()=> Get.back(), icon: const Icon(Icons.arrow_back_outlined)),
        ),
        body: Column(children: [
          Expanded(
              child: Obx(() => messagesController.messagesList.value.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'You can send messages with your voice Also',
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              )
                  : ListView.builder(
                controller: scrollController,
                  itemCount: messagesController.messagesList.value.length,
                  itemBuilder: (ctx, index)=> MessagesItemWidget(message: messagesController.messagesList.value[index], controller: messagesController,)))),
          Obx(()=> SpeechControlWidget(
              messagesController.hasSpeech.value,
              messagesController.isListening.value,
              startListening,
              stopListening,
              cancelListening,
              textEditingController,
              focusNode,
              messagesController,
          messagesController.isTextMessage.value,
          messagesController.isVoiceMessage.value,
            onSendMessageClick,
            onTextChange,
            jumpToLastMessage,
          ),
        ),
      ]),
    );
  }


  Future<void> initSpeechState() async {
    _logEvent('Initialize');
    try {
      var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: _logEvents,
      );
      debugPrint('initialization Done');
      if (hasSpeech) {
        // Get the list of languages installed on the supporting platform so they
        // can be displayed in the UI for selection by the user.
        _localeNames = await speech.locales();

        var systemLocale = await speech.systemLocale();
        _currentLocaleId = systemLocale?.localeId ?? '';
      }
      if (!mounted) return;
      messagesController.hasSpeech.value = hasSpeech;

    } catch (e) {
      lastError = 'Speech recognition failed: ${e.toString()}';
      messagesController.hasSpeech.value = false;
    }
  }

  // This is called each time the users wants to start a new speech
  // recognition session
  void startListening() {
    lastWords = '';
    lastError = '';
    speech.listen(
      onResult: resultListener,
      listenFor: const Duration(seconds:  30),
      pauseFor: const Duration(seconds: 10),
      partialResults: true,
      localeId: _currentLocaleId,
      onSoundLevelChange: soundLevelListener,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
      onDevice: _onDevice,
    );
      messagesController.isListening.value = true;
      messagesController.isVoiceMessage.value = true;
      messagesController.isTextMessage.value = false;

      messagesController.startRecording();
  }

  void stopListening() async{

    speech.stop();
    debugPrint('Speech Stopped: ${speech.isListening}');
    String message = textEditingController.text.trim();
    textEditingController.clear();

      messagesController.level.value = 0.0;
      messagesController.isListening.value = false;
      messagesController.isTextMessage.value = false;
      messagesController.isVoiceMessage.value = false;

      await stopRecording();
      setState(() {

      });
    messagesController.insertMessage(message, false, '');
    Timer(const Duration(milliseconds: 500), () => scrollController.jumpTo(scrollController.position.maxScrollExtent));
  }

  void cancelListening() {
    _logEvent('cancel');
    speech.cancel();
    messagesController.level.value = 0.0;
  }

  Future<void> stopRecording() async{
    await messagesController.stopRecording();
    jumpToLastMessage();
  }
  void resultListener(SpeechRecognitionResult result) {
    _logEvent('Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
    textEditingController.text = result.recognizedWords;
    /*
    setState(() {
      if(result.finalResult){
        messagesController.insertMessage(textEditingController.text.trim());
        Timer(const Duration(milliseconds: 500), () => scrollController.jumpTo(scrollController.position.maxScrollExtent));
        textEditingController.clear();
      }
      lastWords = '${result.recognizedWords} - ${result.finalResult}';
    });

     */

  }

  void onSendMessageClick(){
    if(textEditingController.text.trim().isNotEmpty){
      messagesController.insertMessage(textEditingController.text.trim(), false, '');
     jumpToLastMessage();
      textEditingController.clear();
      messagesController.isTextMessage.value = false;
      messagesController.isVoiceMessage.value = false;
      setState(() {

      });
    }

  }
  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    messagesController.level.value = level;

  }

  void errorListener(SpeechRecognitionError error) {
    _logEvent(
        'Received error status: $error, listening: ${speech.isListening}');
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    _logEvent(
        'Received listener status: $status, listening: ${speech.isListening}');
    setState(() {
      lastStatus = status;
    });
  }


  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      debugPrint('$eventTime $eventDescription');
    }
  }


  void onTextChange(val){
      messagesController.isTextMessage.value = true;
      messagesController.isVoiceMessage.value = false;
  }

  void jumpToLastMessage(){
    Timer(const Duration(milliseconds: 500), () => scrollController.jumpTo(scrollController.position.maxScrollExtent));
  }
}


/// Controls to start and stop speech recognition
class SpeechControlWidget extends StatelessWidget {
  const SpeechControlWidget(this.hasSpeech, this.isListening,
      this.startRecording, this.stopRecording, this.cancelListening,
      this.textEditingController, this.focusNode,
      this.messagesController,
      this.isTextMessage,
      this.isVoiceMessage,
      this.onSendMessageClick,
      this.onTextChange,
      this.jumpToLastMessage,
      {Key? key})
      : super(key: key);

  final bool hasSpeech;
  final bool isListening;
  final void Function() startRecording;
  final void Function() stopRecording;
  final void Function() cancelListening;
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final MessagesController messagesController;
  final bool isTextMessage;
  final bool isVoiceMessage;
  final void Function() onSendMessageClick;
  final void Function(String x) onTextChange;
  final void Function() jumpToLastMessage;
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
      child: Row(
        children: [
          Expanded(
              child: TextField(
                style: GoogleFonts.manrope(fontSize: 14),
                controller: textEditingController,
                focusNode: focusNode,
                maxLines: null,
                onChanged: onTextChange,
                readOnly: isVoiceMessage,
                textInputAction: TextInputAction.done,
                onSubmitted: (val){
                  if(val.isNotEmpty){
                    messagesController.insertMessage(val, false, '');
                    textEditingController.clear();
                   jumpToLastMessage();
                  }
                },
                onTapOutside: (event) => focusNode.unfocus(),
                decoration: InputDecoration(
                    hintText: 'Type message',
                    hintStyle: GoogleFonts.manrope(fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(50))),
              )),
          const SizedBox(width: 10,),
          isTextMessage ? GestureDetector(
            onTap: onSendMessageClick,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.amber,
              child: Image.asset(icSend),
            ),
          ): GestureDetector(
            onTap: !hasSpeech || isListening ? stopRecording : startRecording,
            child:  SizedBox(
                width: 50,
                height: 50,
                child: isListening ? const AnimWidget(animation: 'assets/anims/voice_recording_anim.json',): const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.keyboard_voice),
                )),
          )

        ],
      ),
    );
  }
}