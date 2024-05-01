import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tele_drive_app/pages/folderPage.dart';
import 'package:unicons/unicons.dart';
class FolderIcon extends StatelessWidget {
  const FolderIcon({super.key,required this.folderName, required this.folderId, required this.onTap,});
  final String folderName;
  final String folderId;
  // final String parentFolderId;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {

    final ThemeData theme = Theme.of(context);

    final Color menuColor = theme.brightness == Brightness.light
        ? Colors.white // Light theme color
        : const Color.fromARGB(255, 24, 24, 24);
    return Material(
      color: Colors.transparent,
      child: FocusedMenuHolder(
        menuWidth: 200,
        openWithTap: false,
        onPressed: (){},
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
              // onPressed: () { deleteFolder(folderId,parentFolderId).then((value) => onTap);}),
              onPressed: onTap),
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
              onPressed: () {}
          ),
        ],
        child: InkWell(
          onTap: (){
            Navigator.push(context, PageTransition(
                child: FolderPage(folderId: folderId, folderName: folderName,),
                type: PageTransitionType.leftToRight),
            );
          },
          splashColor: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(15),
          radius: 70,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // alignment: Alignment.center,
              children: [
                Icon(UniconsLine.folder, color: Colors.grey.shade500, size: 82,),
                Container(
                  alignment: Alignment.topCenter,
                  width: 90,
                  child: Text(
                    folderName,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                    softWrap: true,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
