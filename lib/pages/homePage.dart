import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tele_drive_app/tools/commonWidgets/folder_icon.dart';
import 'package:unicons/unicons.dart';
import '../const.dart';
import '../tools/commonWidgets/media_icon.dart';
import '../tools/commonWidgets/rounded_image.dart';
import 'hidden.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  BorderRadiusGeometry border = const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25));
  final Dio dio = Dio();
  bool isFileLoaded = false;
  late List filesAndFolders = [];
  String parentFolderId="";
  double progress =0;

  Future<void> getAllFilesAndFolders() async {
    Map<String, dynamic> filesAndFoldersList = await getAllFilesFromCollection(token);
    setState(() {
      parentFolderId = filesAndFoldersList["id"].toString();
      filesAndFolders = filesAndFoldersList["files"];
      isFileLoaded =true;
    });
  }
  Future<void> sendFile(String docId) async {
    final formData = await uploadFile(docId);
    var response = await Dio().post(
        addToCollectionUrl,
        data: formData,
        onSendProgress: (download, totalSize) {
          setState(() {
            progress = download / totalSize;
          });
        }
    );
    setState(() {
      progress=0;
    });
  }


  @override
  void initState() {
    getAllFilesAndFolders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color menuColor = theme.brightness == Brightness.light
        ? Colors.white
        : const Color.fromARGB(255, 24, 24, 24);
    final Color appBackgroundColor = theme.brightness == Brightness.light
        ? const Color.fromARGB(255, 238, 238, 238)
        : const Color.fromARGB(255, 24, 24, 24);
    final Color appBarBackgroundColor =
        theme.brightness == Brightness.light ? Colors.white : Colors.black;
    var size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: appBackgroundColor,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CarouselSlider(
                    items: const [
                      RoundedImage(
                        imageUrl: 'assets/images/Untitled1.jpg',
                        fit: BoxFit.cover,
                      ),
                      RoundedImage(
                        imageUrl: 'assets/images/Untitled2.jpg',
                        fit: BoxFit.cover,
                      ),
                      RoundedImage(
                        imageUrl: 'assets/images/Untitled3.jpg',
                        fit: BoxFit.cover,
                      ),
                    ],
                    options: CarouselOptions(
                      height: (size.height) * 0.2,
                      viewportFraction: 1,
                      autoPlay: true,
                    )),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            boxShadow: [BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 6,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                            ],
                            borderRadius: border,
                            color: appBarBackgroundColor
                        ),
                        child: (isFileLoaded)
                            ? (filesAndFolders.isNotEmpty)
                            ? Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3),
                                    itemCount: filesAndFolders.length,
                                    itemBuilder: (BuildContext context, int i) {
                                      return (filesAndFolders[i]["type"] == "file")
                                          ? MediaIcon(
                                        folderName: filesAndFolders[i]["name"],
                                        thumbnailUrl: "assets/images/Untitled.jpg",
                                        folderId: filesAndFolders[i]["id"],
                                        deleteFun: () {deleteFile(filesAndFolders[i]["id"],filesAndFolders[i]["_id"],token).then((value) => getAllFilesAndFolders());},)
                                          : FolderIcon(
                                              folderName: filesAndFolders[i]["name"],
                                              folderId: filesAndFolders[i]["id"],
                                        onTap: () { deleteFolder(filesAndFolders[i]["id"], token).then((value) => getAllFilesAndFolders()); },
                                            );
                                    })
                        )
                            : Center(
                          child: Lottie.asset("assets/nothing.json", width: size.width),
                        )
                            : Center(
                              child: Lottie.asset("assets/loading.json", width: size.width/2),
                            )
                    ),
                    ClipRRect(
                      borderRadius: border,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: border,
                            color: Colors.white.withOpacity(0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  height: 15,
                                  width: 150,
                                  child: LinearProgressIndicator(
                                    backgroundColor: (progress==0) ? appBarBackgroundColor:Colors.grey.shade300,
                                    color: Colors.indigoAccent,
                                    value: progress,
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () async {
                                    await sendFile(token).then((value) => getAllFilesAndFolders());
                                    // addToCollection(token).then((value) => getAllFilesAndFolders());
                                  },
                                  icon: const Icon(UniconsLine.file_plus)),
                              IconButton(
                                  onPressed: () async {
                                    TextEditingController folderNameCtrl =
                                        TextEditingController();
                                    showFolderAddDialog(
                                        context,
                                        size.width * 0.8,
                                        folderNameCtrl, () async {
                                      if (folderNameCtrl.text != "") {
                                        await createFolder(
                                                folderNameCtrl.text, token)
                                            .then((value) =>
                                                getAllFilesAndFolders().then(
                                                    (value) => Navigator.pop(
                                                        context)));
                                        folderNameCtrl.clear();
                                      }
                                    });
                                  },
                                  icon: const Icon(UniconsLine.folder_plus)),
                              PopupMenuButton(
                                color: menuColor,
                                elevation: 4,
                                offset: Offset(
                                  0.0,
                                  size.height * 0.0070,
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                      child:
                                          const Text("Hide or un-hide albums"),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const hidden()),
                                        );
                                      }),
                                ],
                                onSelected: (value) {},
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
