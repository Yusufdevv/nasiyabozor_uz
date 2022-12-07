import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NasiyaBozor.uz',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebViewController _contoller;
  double _progress = 0;
  bool isPageFinished = false;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  void dispose() {
    _contoller.clearCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _contoller.canGoBack()) {
          _contoller.goBack();

          /// Stay in app
          return false;
        } else {
          /// Leave in app
          var shouldPop = await _showDialog();
          return shouldPop ?? false;
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  if (_progress != 1.0)
                    LinearProgressIndicator(
                      value: _progress,
                      color: Colors.red,
                      backgroundColor: Colors.black12,
                    ),
                  Expanded(
                    child: WebView(
                        javascriptMode: JavascriptMode.unrestricted,
                        initialUrl: "nasiyabozor.uz",
                        onWebViewCreated: (controller) {
                          _contoller = controller;
                        },
                        onPageFinished: (url) {
                          setState(() {
                            isPageFinished = true;
                          });
                        },
                        onProgress: (progress) {
                          setState(() => _progress = progress / 100);
                        }),
                  ),
                ],
              ),
            ),
            if (!isPageFinished)
              Container(
                height: double.maxFinite,
                width: double.maxFinite,
                decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/logo.png",
                        height: 250,
                        width: 250,
                      ),
                      const CupertinoActivityIndicator(
                        color: Colors.greenAccent,
                        radius: 25,
                      ),
                     const SizedBox(height: 20),
                      Text('${_progress*100} %',style:const TextStyle(color: Colors.greenAccent, fontSize: 16),)
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Haqiqatdan dasturdan chiqishni xohlaysizmi?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("YO'Q")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(),
              onPressed: () {
                _contoller.clearCache();
                Navigator.pop(context, true);
              },
              child: const Text(
                "Ha",
              ),
            )
          ],
          actionsAlignment: MainAxisAlignment.spaceEvenly,
        ),
      );
}
