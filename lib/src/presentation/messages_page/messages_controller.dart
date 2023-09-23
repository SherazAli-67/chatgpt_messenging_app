import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:messenger_type_app/src/config/app_controller.dart';
import 'package:messenger_type_app/src/constant/constants.dart';
import 'package:messenger_type_app/src/data/messages.dart';
import 'package:messenger_type_app/src/utils/utility.dart';

import 'package:record/record.dart';
class MessagesController extends GetxController{
  var messagesList = Rx<List<Messages>>([]);
  AppController appController = Get.find();

  RxDouble level = 0.0.obs;
  RxBool hasSpeech = false.obs;
  RxBool isListening = false.obs;
  RxBool isTextMessage = false.obs;
  RxBool isVoiceMessage = false.obs;

  late Record record;
  late AudioPlayer audioPlayer;
  var voiceDuration = Duration.zero.obs;
  var position = Duration.zero.obs;
  RxBool isAudioPlaying = false.obs;

  var recordedPath = ''.obs;
  @override
  void onInit() {
    super.onInit();
    record = Record();
    audioPlayer = AudioPlayer();

    _refreshList();
  }

  Future<void> insertMessage(String textMessage, bool isVoiceMessage, String path) async{
    String id = DateTime.now().millisecond.toString();
    String userID = (await Utility.getUserInfo(userIDKey))!;

    Messages message = Messages(
        id: id,
        message: textMessage,
        userID: userID,
        dateTime: Utility.getFormattedTime(),
        isVoiceMessage: isVoiceMessage,
        path: path);
    await appController.appDao.sendMessage(message);
    _refreshList();
  }

  void _refreshList() async{
    messagesList.value =await appController.appDao.getAllChatMessages();
    messagesList.refresh();
  }


  void startRecording() async{
    await record.start();
    isListening.value = true;
  }

  Future<void> stopRecording() async{
    String? path = await record.stop();
    if(path != null){
      debugPrint('Path is: $path');
     await insertMessage('', true, path);
    }

    isListening.value = false;
  }


  void toggleAudioPlaying() {
    isAudioPlaying.value = !isAudioPlaying.value;
  }
}