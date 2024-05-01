
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tele_drive_app/const.dart';
import 'package:tele_drive_app/pages/folderPage.dart';
import 'package:tele_drive_app/pages/homePage.dart';
import 'package:tele_drive_app/pages/login_page.dart';
import 'package:tele_drive_app/pages/sign_up_page.dart';
import 'package:tele_drive_app/tools/States/nav_notifier.dart';
import 'package:tele_drive_app/tools/navigationbar.dart';
import 'Themes/theme.dart';
import 'package:http/http.dart' as http;
void main() {
  runApp(
      ProviderScope(child: MyApp())
  );
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLogin=false;

  // final Dio dio = Dio();

  Future<void> checkIfLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? myToken = prefs.getString("token");
    // String? mySessionId = prefs.getString("sessionId");
    // print(mySessionId);
    print(myToken);
    var res = await dio.post(
        checkLogin,
        data: {
          "token": myToken
        }
    );
    print(res.data);
    if(res.data["session"]!=""){
      setState(() {
        token =myToken!;
        // sessionId=mySessionId!;
        print(token);
        isLogin = true;
      });
    }
    else{
      setState(() {
        isLogin=false;
      });
    }
  }
  @override
  void initState() {
    checkIfLogin();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: (isLogin)? MyHomePage():LoginPage()
    );
  }
}


// class MyApp extends StatelessWidget {
//   MyApp({super.key});
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final appTheme = ref.watch(navProvider);
//     return MaterialApp(
//       themeMode: appTheme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
//       title: 'Flutter Demo',
//       theme: AppTheme.LightTheme,
//       darkTheme: AppTheme.darkTheme,
//       home: LoginPage(),
//       // home: MyHomePage(),
//     );
//   }
// }
