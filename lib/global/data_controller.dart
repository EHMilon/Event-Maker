

import 'package:event_maker/constants/app_constants.dart';
import 'package:event_maker/services/storage_service.dart';
import 'package:get/get.dart';

class DataController extends GetxController{

    @override
    void onInit() {
      super.onInit();
      getUserType();
    }

   final userType = UserType.customer.obs;

  setUserType(UserType type){
    StorageService().saveUserType(type.toString());
    userType.value = type;
  }
  getUserType(){
     userType.value = StorageService().getUserType()==UserType.customer.toString()?UserType.customer:UserType.provider;
    return userType;
  }




} 
