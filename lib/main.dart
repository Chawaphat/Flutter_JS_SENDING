import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final WebViewController _controller;
  String totalFromJS = "0";

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          setState(() {
            totalFromJS = message.message;
          });
        },
      )
      ..loadFlutterAsset('assets/note.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send)),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(child: WebViewWidget(controller: _controller)),
            Container(
              padding: const EdgeInsets.all(12.0),
              color: const Color.fromARGB(255, 219, 219, 219),
              width: double.infinity,
              child: Text(
                'Received from JavaScript: $totalFromJS',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    await _controller.runJavaScript(
      "showMessageFromFlutter('Hello from Flutter!');",
    );

    final result = await _controller.runJavaScriptReturningResult(
      "showMessageFromFlutter('Hello from Flutter! with return value');",
    );
    debugPrint('Result from JS: $result');
  }
}
