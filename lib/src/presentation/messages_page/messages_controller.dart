import 'package:get/get.dart';
import 'package:messenger_type_app/src/config/app_controller.dart';
import 'package:messenger_type_app/src/constant/constants.dart';
import 'package:messenger_type_app/src/data/messages.dart';
import 'package:messenger_type_app/src/utils/utility.dart';

class MessagesController extends GetxController{
  var messagesList = Rx<List<Messages>>([]);
  AppController appController = Get.find();


  @override
  void onInit() {
    super.onInit();
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
}