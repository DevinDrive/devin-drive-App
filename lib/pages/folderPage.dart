import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tele_drive_app/tools/commonWidgets/folder_icon.dart';
import 'package:unicons/unicons.dart';
import '../const.dart';
import '../tools/commonWidgets/media_icon.dart';
class FolderPage extends StatefulWidget {
  const FolderPage({super.key, required this.folderName, required this.folderId});
  final String folderName;
  final String folderId;

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {

  late List filesAndFolders =[];
  bool isFileLoaded= false;
  final Dio dio = Dio();
  int parentFolderId=-2;

  Future<void> getAllFilesAndFolders() async {

    Map<String, dynamic> filesAndFoldersList = await getAllFilesFromCollection(widget.folderId);
    setState(() {
      parentFolderId = filesAndFoldersList["id"];
      filesAndFolders = filesAndFoldersList["files"];
      isFileLoaded =true;
    });
  }

  Future<void> downloadFile(String fileName, String fileId) async {
    String saveFilePath = await createLocalDir(fileName);
    await dio.download(
        getAFile,
        data: {
          'token': token,
          "fileId" : fileId,
          "fileName": fileName
        },
        saveFilePath,
        onReceiveProgress: (download,totalSize){
          setState(() {
            // progress = download/totalSize;
          });
        });
  }

  @override
  void initState() {
    getAllFilesAndFolders();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
            child: const Icon(Icons.arrow_back_ios_new_rounded)
        ),
        title: Text(widget.folderName),
        actions: [
          IconButton(
              onPressed: (){
                TextEditingController folderNameCtrl = TextEditingController();
                showFolderAddDialog(
                    context,
                    size.width*0.8,
                    folderNameCtrl,
                    () async {
                  if(folderNameCtrl.text!=""){
                    await createFolder(folderNameCtrl.text, widget.folderId).then((value) => getAllFilesAndFolders().then((value) => Navigator.pop(context)));
                    folderNameCtrl.clear();
                  }
                }
                );
            },
              icon: const Icon(UniconsLine.folder_plus)),
          IconButton(
              onPressed: () async {await addToCollection(widget.folderId).then((value) => getAllFilesAndFolders());},
              icon: const Icon(UniconsLine.file_plus)),

        ],
      ),
      body: (isFileLoaded)
          ? (filesAndFolders.isNotEmpty)
          ? GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3
          ),
          itemCount:filesAndFolders.length,
          itemBuilder: (BuildContext context,int i){
            return (filesAndFolders[i]["type"]=="file")
                ? MediaIcon(
              folderName: filesAndFolders[i]["name"],
              thumbnailUrl: "assets/images/Untitled.jpg",
              folderId: filesAndFolders[i]["id"],
              deleteFun: () { deleteFile(filesAndFolders[i]["id"],filesAndFolders[i]["_id"], widget.folderId).then((value) => getAllFilesAndFolders());},)
                : FolderIcon(
              folderName: filesAndFolders[i]["name"],
              folderId: filesAndFolders[i]["id"],
              onTap: () { deleteFolder( filesAndFolders[i]["id"], parentFolderId.toString()).then((value) => getAllFilesAndFolders()); },
              );
          }
      )
      : Center(
        child: Lottie.asset("assets/nothing.json", width: size.width),
      )
          :
      Center(
        child: Lottie.asset("assets/loading.json", width: size.width/2),
      )
    );
  }
}
