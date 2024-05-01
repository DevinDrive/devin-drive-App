
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tele_drive_app/tools/commonWidgets/buttons.dart';
import 'package:tele_drive_app/tools/commonWidgets/text_field.dart';

String ip = "172.23.16.176";
String apiUrl = "http://$ip:3000/v1";
String token = '';
// String apiUrl = "https://telebackend.onrender.com/v1";

String signUpUrl = "$apiUrl/signup";
String signInUrl = "$apiUrl/login";
String sendCodeUrl = "$apiUrl/sendCode";
String loginTelegramUrl = "$apiUrl/loginTelegram";
String checkLogin= "$apiUrl/checkLogin";

String getCollectionFiles= "$apiUrl/getAllFilesFromCollection";
String getAFile = "$apiUrl/getAFile";
String createCollection= "$apiUrl/createCollection";
String addToCollectionUrl= "$apiUrl/addToCollection";
String deleteFileUrl= "$apiUrl/deleteFile";
String deleteFolderUrl= "$apiUrl/deleteFolder";

final Dio dio = Dio();

Future<void> signUp(String phoneNo, String password) async {
  final dio = Dio();
  var res= await dio.post(
      signUpUrl,
      data: {
        'phoneNo': phoneNo,
        'password': password
      }
  );
  print(res.data);
}

Future<String> signIn(String phoneNo, String password) async {
  final dio = Dio();
  var res= await dio.post(
      signInUrl,
      data: {
        'phoneNo': phoneNo,
        'password': password
      }
  );
  return res.data;
}

Future<String> sendCode(String token) async {
  final dio = Dio();
  var res= await dio.post(
      sendCodeUrl,
      data: {
        'token': token
      }
  );

  return res.data["phoneCodeHash"];
}

Future<void> addToCollection(String docId) async {
  late List<String?> filePaths=[];
  List<MultipartFile> multiFiles=[];
  FilePickerResult? file = await FilePicker.platform.pickFiles(allowMultiple: true);
  if(file != null){filePaths = file.paths;}
  for(int i=0; i<filePaths.length; i++){
    MultipartFile f= await MultipartFile.fromFile(filePaths[i]!);
    multiFiles.add(f);
  }
  final formData = FormData.fromMap({
    'token': token,
    'files': multiFiles,
    'docId' : docId
  });
  var response = await Dio().post(
      addToCollectionUrl,
      data: formData,
  );
}

Future<FormData> uploadFile(String docId) async {
  late List<String?> filePaths=[];
  List<MultipartFile> multiFiles=[];
  FilePickerResult? file = await FilePicker.platform.pickFiles(allowMultiple: true);
  if(file != null){filePaths = file.paths;}
  for(int i=0; i<filePaths.length; i++){
    MultipartFile f= await MultipartFile.fromFile(filePaths[i]!);
    multiFiles.add(f);
  }
  final formData = FormData.fromMap({
    'token': token,
    'files': multiFiles,
    'docId' : docId
  });
  return formData;
}

Future<bool> requestPermission() async {
  var res = await Permission.manageExternalStorage.request();
  if(res.isGranted){
    return true;
  }
  else{
    return false;
  }
}

Future<Map<String, dynamic>> getAllFilesFromCollection(String docId) async {
  var res = await dio.get(
      getCollectionFiles,
      data:{
        'token': token,
        'docId' : docId
      }
  );
  return res.data;
}

Future<void> createFolder(String folderName, String docId) async {
  var res = await dio.post(
      createCollection,
      data : {
        'token' : token,
        'name' : folderName,
        'docId' : docId,
      }
  );
}

Future<void> deleteFile(String telegramId, String docId, String parentId) async {
  var res = await dio.get(
      deleteFileUrl,
      data: {
        "token": token,
        "telegramId": telegramId,
        "docId": docId,
        "parentId": parentId
      }
  );
}

Future<void> deleteFolder(String folderId, String parentFolderId) async {
  var res = await dio.get(
      deleteFolderUrl,
      data: {
        "token": token,
        "parentFolderId" :parentFolderId,
        "folderId": folderId,
      }
  );
  print(res.data);
}

Future<String> createLocalDir(String fileName) async {
  Directory? directory;
  try{
    if(await requestPermission()){
      directory = await getExternalStorageDirectory();
      List<String>? folders= directory?.path.split("/");
      String newPath= "";
      for(int x=1; x<folders!.length; x++){
        String folder = folders[x];
        if(folder!="Android"){
          newPath +="/"+folder;
        }
        else{
          break;
        }
      }
      newPath  = "$newPath/TeleDrive";
      directory = Directory(newPath);
    }
    else{
      print("cannot create a directory");
    }
    if(await directory?.exists()==false){
      await directory?.create(recursive: true);
    }
    if(await directory?.exists()==true){
      File saveFile = File("${directory?.path}/$fileName");
      return saveFile.path;
    }
  }
  catch(e){
    print(e);
  }
  return "";
}

void showFolderAddDialog(BuildContext context, double width,TextEditingController controller, Function() onTap, ){
  showDialog(
      context: context,
      builder: (BuildContext context){
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: width,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey.shade400,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 8),
                    child: Text("New Folder", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.grey.shade800),),
                  ),
                  TextField1(controller: controller, textInputType: TextInputType.text),
                  Button1(
                    buttonText: "✓ Create Folder",
                    onTap: onTap,
                    color: Colors.green,),
                  Button1(buttonText: "X Cancel", onTap: (){Navigator.pop(context);}, color: Colors.red.shade300,)
                ],
              ),
            ),
          ),
        );
      }
  );
}
