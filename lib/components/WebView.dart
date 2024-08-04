import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewBox extends StatefulWidget {
  final String url;
  final double width;
  final double height;

  const WebViewBox({super.key, required this.url, required this.width, required this.height});

  @override
  State<WebViewBox> createState() => _WebViewBoxState();
}

class _WebViewBoxState extends State<WebViewBox> {
  late WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Enable JavaScript
      ..loadRequest(
        Uri.parse(widget.url),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: WebViewWidget(controller: controller),
    );
  }
}
