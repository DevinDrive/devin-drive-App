import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:developer';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:open_filex/open_filex.dart';
import 'package:unicons/unicons.dart';
import '../../const.dart';
import 'package:http/http.dart' as http;

class MediaIcon extends StatefulWidget {
  const MediaIcon({super.key, required this.folderName, required this.thumbnailUrl, required this.folderId, required this.deleteFun});
  final String folderName;
  final String folderId;
  final String thumbnailUrl;
  final Function() deleteFun;

  @override
  State<MediaIcon> createState() => _MediaIconState();
}

class _MediaIconState extends State<MediaIcon> {
  bool isDownloading=false;
  double progress = 0;
  String savedFilePath = "";

  Future<void> downloadFile(String fileName, String fileId) async {
    setState(() {
      isDownloading = true;
    });
    savedFilePath = await createLocalDir(fileName);
    Response res= await dio.get(
        getAFile,
        data: {'token': token, "fileId": fileId, "fileName": fileName},
        options: Options(
          responseType: ResponseType.stream,

        ),
        onReceiveProgress: (download, totalSize) {
      setState(() {

        progress = download / totalSize;
      });
    });
    print(res.data["data"]);
    List<int> bufferData = res.data["data"].cast<int>();
    await File(savedFilePath).writeAsBytes(bufferData);
    setState(() {
      isDownloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color appBackgroundColor = theme.brightness == Brightness.light
        ? Colors.white // Light theme color
        : Colors.black;
    final Color menuColor = theme.brightness == Brightness.light
        ? Colors.white // Light theme color
        : const Color.fromARGB(255, 24, 24, 24);

    return Material(
      color: Colors.transparent,
        child: FocusedMenuHolder(
      menuWidth: 200,
      openWithTap: false,
      onPressed: () {},
      menuItems: <FocusedMenuItem>[
        FocusedMenuItem(
            backgroundColor: menuColor,
            title: const Text("Favourites"),
            trailingIcon: const Icon(Icons.favorite_border),
            onPressed: () {}),
        FocusedMenuItem(
            backgroundColor: menuColor,
            title: const Text("Share"),
            trailingIcon: const Icon(UniconsLine.share_alt),
            onPressed: () {}),
        FocusedMenuItem(
            backgroundColor: menuColor,
            title: const Text("Delete"),
            trailingIcon: const Icon(UniconsLine.trash_alt),
            onPressed: widget.deleteFun),
        FocusedMenuItem(
            backgroundColor: menuColor,
            title: const Text("Rename"),
            trailingIcon: const Icon(UniconsLine.pen),
            onPressed: () {}),
        FocusedMenuItem(
            backgroundColor: menuColor,
            title: const Text("Hide"),
            trailingIcon: const Icon(UniconsLine.eye_slash),
            onPressed: () {}),
        FocusedMenuItem(
            backgroundColor: menuColor,
            title: const Text("Change cover image"),
            trailingIcon: const Icon(UniconsLine.image_edit),
            onPressed: () {}),
      ],
      child: InkWell(
        onTap: () async {
          await downloadFile(widget.folderName, widget.folderId).then((value) => OpenFilex.open(savedFilePath));
        },
        splashColor: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(15),
        radius: 70,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(widget.thumbnailUrl, height: 66, width: 66, fit: BoxFit.fill,)),
                  if (isDownloading) ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                      child: Container(
                        height: 66,
                        width: 66,
                          decoration: BoxDecoration(
                            // borderRadius: border,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 5,
                              backgroundColor: Colors.grey.shade400,
                              value: progress,
                              color: Colors.blue,
                            ),
                          )
                      ),
                    ),
                  )
                ],
              ),
              Container(
                alignment: Alignment.topCenter,
                height: 28,
                width: 90,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    widget.folderName,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700,),
                    softWrap: true,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
                ),
              )
            ],
          ),
        ),
      )
    ));
  }
}
